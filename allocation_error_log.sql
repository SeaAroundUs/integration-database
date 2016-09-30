--------------------------------------------------------------------------------
drop view allocation.v_aa_fgi_check;            
create or replace view allocation.v_aa_fgi_check as
with dat as (
  select l.universal_data_id as error_id, l.fishing_entity_id fe, l.eez_id, aa.eez_name, l.year, aa.start_year as start, aa.end_year as end,
         aa.id as aa_id, aa.functional_group_id existing_aa_fgi, 
         (select rtrim(strings(distinct '{' || array_to_string(fga.fgi_block, ',') || '},'), ',') 
            from master.functional_groups fga
            join unnest(string_to_array(aa.functional_group_id, ';')::int[]) as a(fgi) on (a.fgi = fga.functional_group_id)) as existing_aa_fgi_block,
         t.functional_group_id taxon_fgi, fg.fgi_block taxon_fgi_block
    from allocation.allocation_error_log l 
    join master.access_agreement aa on (aa.fishing_entity_id = l.fishing_entity_id and aa.eez_id = l.eez_id and l.year between aa.start_year and aa.end_year)
    join master.taxon t on (t.taxon_key = l.taxon_key)
    join master.functional_groups fg on (fg.functional_group_id = t.functional_group_id)
    where error_message = 'No Access Agreement or undeclared EEZ matched this combination'
      and aa.functional_group_id is not null
      and length(coalesce(aa.functional_group_id, '')) > 0
   order by l.fishing_entity_id, l.eez_id, aa.start_year, aa.end_year
)
select d.*, (select array_to_string(array_agg(u.fgi order by u.fgi), ';') from unnest(string_to_array(existing_aa_fgi || ';' || taxon_fgi, ';')::int[]) as u(fgi)) proposed_aa_fgi 
  from dat d
 where position(taxon_fgi_block::text in existing_aa_fgi_block) != 0
   and taxon_fgi != all(string_to_array(existing_aa_fgi, ';')::int[]);
select admin.grant_access();
select * from allocation.v_aa_fgi_check;

create or replace function allocation.auto_update_aa(i_fishing_entity_id int) 
returns void as
$body$
  with upd as (
    update master.access_agreement aa
       set functional_group_id = v.proposed_aa_fgi
      from allocation.v_aa_fgi_check v
      join log.aa_ids_to_update aaid on (aaid.aa_id = v.aa_id) 
     where v.fe = i_fishing_entity_id
       and aa.id = v.aa_id
    returning v.aa_id, v.error_id, v.existing_aa_fgi, v.proposed_aa_fgi
  )
  update log.aa_ids_to_update l
     set merlin_error_id = upd.error_id,
         existing_aa_fgi = upd.existing_aa_fgi,
         updated_fgi = upd.proposed_aa_fgi,
         is_block_check = true
    from upd
   where l.aa_id = upd.aa_id;     
$body$
language sql;

--------------------------------------------------------------------------------
drop view allocation.v_aa_fgi_check_no_block_check;            
create or replace view allocation.v_aa_fgi_check_no_block_check as
with dat as (
  select l.universal_data_id as error_id, l.fishing_entity_id fe, l.eez_id, aa.eez_name, l.year, aa.start_year as start, aa.end_year as end,
         aa.id as aa_id, aa.functional_group_id existing_aa_fgi, 
         (select rtrim(strings(distinct '{' || array_to_string(fga.fgi_block, ',') || '},'), ',') 
            from master.functional_groups fga
            join unnest(string_to_array(aa.functional_group_id, ';')::int[]) as a(fgi) on (a.fgi = fga.functional_group_id)) as existing_aa_fgi_block,
         t.functional_group_id taxon_fgi, fg.fgi_block taxon_fgi_block
    from allocation.allocation_error_log l 
    join master.access_agreement aa on (aa.fishing_entity_id = l.fishing_entity_id and aa.eez_id = l.eez_id and l.year between aa.start_year and aa.end_year)
    join master.taxon t on (t.taxon_key = l.taxon_key)
    join master.functional_groups fg on (fg.functional_group_id = t.functional_group_id)
    where error_message = 'No Access Agreement or undeclared EEZ matched this combination'
      and aa.functional_group_id is not null
      and length(coalesce(aa.functional_group_id, '')) > 0
   order by l.fishing_entity_id, l.eez_id, aa.start_year, aa.end_year
)
select d.*, (select array_to_string(array_agg(u.fgi order by u.fgi), ';') from unnest(string_to_array(existing_aa_fgi || ';' || taxon_fgi, ';')::int[]) as u(fgi)) proposed_aa_fgi 
  from dat d
 where taxon_fgi != all(string_to_array(existing_aa_fgi, ';')::int[]);
select admin.grant_access();
select * from allocation.v_aa_fgi_check;

create or replace function allocation.auto_update_aa_no_block_check(i_fishing_entity_id int) 
returns void as
$body$
  with upd as (
    update master.access_agreement aa
       set functional_group_id = v.proposed_aa_fgi
      from allocation.v_aa_fgi_check_no_block_check v
      join log.aa_ids_to_update aaid on (aaid.aa_id = v.aa_id) 
     where v.fe = i_fishing_entity_id
       and aa.id = v.aa_id
    returning v.aa_id, v.error_id, v.existing_aa_fgi, v.proposed_aa_fgi
  )
  update log.aa_ids_to_update l
     set merlin_error_id = upd.error_id,
         existing_aa_fgi = upd.existing_aa_fgi,
         updated_fgi = upd.proposed_aa_fgi
    from upd
   where l.aa_id = upd.aa_id;     
$body$
language sql;

--------------------------------------------------------------------------------
select count(*) /*c.fishing_entity_id, c.eez_id, c.taxon_key,*/  
  from recon.catch c
  join master.eez e on (c.eez_id = e.eez_id and c.year < e.declaration_year)
  join master.fishing_entity fe on (fe.fishing_entity_id=c.fishing_entity_id and fe.is_allowed_to_fish_pre_eez_by_default) 
 where c.layer = 2;

create or replace function allocation.validate_catch_against_aa(i_start_catch_id int, i_end_catch_id int) 
returns table(id int, is_passed boolean) as 
$body$
declare
  mmf_taxa int[] := array[100039, 100139, 100239, 100339];
  cat record;
  eligible_aa master.access_agreement%ROWTYPE;
  fao_eezs int[];
  allowed_eezs int[] :=  '{}';
begin
  for cat in select c.*, t.functional_group_id as fgi 
               from log.catch c, master.taxon t 
              where c.taxon_key = t.taxon_key
                and c.layer = 2
                and c.id between i_start_catch_id and i_end_catch_id
  loop
    if cat.eez_id in (0, 999) then
      return query select cat.id, true;
      continue;
    end if;
    
    select array_agg(distinct reconstruction_eez_id) 
      into fao_eezs 
      from geo.eez_fao_combo 
     where fao_area_id = cat.fao_area_id;
     
    if array_length(coalesce(fao_eezs, '{}'::int[]), 1) > 0 then
      for eligible_aa in 
        select a.* 
          from master.Access_Agreement a
         where a.Fishing_Entity_ID = cat.fishing_Entity_ID
           and cat.year between a.Start_Year and a.End_Year
           and (a.Functional_Group_ID is null or cat.taxon_key = any(mmf_taxa) or cat.fgi = any(string_to_array(a.Functional_Group_ID, ';')::int[]))
      loop
        if allowed_eezs is null or eligible_aa.eez_id != all(allowed_eezs) then
          allowed_eezs := allowed_eezs || eligible_aa.eez_id;
        end if;
      end loop;
    end if;
    
    if cat.eez_id = any(coalesce(allowed_eezs, '{}'::int[])) then
      return query select cat.id, true;
    else
      return query select cat.id, false;
    end if;
    
    allowed_eezs :=  '{}';
    fao_eezs := null;
  end loop;
  
  return;
end
$body$
language plpgsql;

delete from log.catch c
 using master.eez e, master.fishing_entity fe
 where c.eez_id = e.eez_id and c.year < e.declaration_year
   and fe.fishing_entity_id=c.fishing_entity_id and fe.is_allowed_to_fish_pre_eez_by_default;
delete from log.catch where eez_id = 0;
delete from log.catch c using eez e where c.eez_id = e.eez_id and not e.is_currently_used_for_reconstruction;

select c.fishing_entity_id, c.fao_area_id, c.year, c.taxon_key
  from log.catch c;


drop view allocation.v_aa_addition_suggestions;            
create or replace view allocation.v_aa_addition_suggestions as
with dat as (
  select l.universal_data_id as error_id, l.fishing_entity_id fe, l.eez_id, aa.eez_name, l.year, aa.start_year as start, aa.end_year as end,
         aa.id as aa_id, aa.functional_group_id existing_aa_fgi, 
         (select rtrim(strings(distinct '{' || array_to_string(fga.fgi_block, ',') || '},'), ',') 
            from master.functional_groups fga
            join unnest(string_to_array(aa.functional_group_id, ';')::int[]) as a(fgi) on (a.fgi = fga.functional_group_id)) as existing_aa_fgi_block,
         t.functional_group_id taxon_fgi, fg.fgi_block taxon_fgi_block
    from allocation.allocation_error_log l 
    join master.access_agreement aa on (aa.fishing_entity_id = l.fishing_entity_id and aa.eez_id = l.eez_id and l.year between aa.start_year and aa.end_year)
    join master.taxon t on (t.taxon_key = l.taxon_key)
    join master.functional_groups fg on (fg.functional_group_id = t.functional_group_id)
    where error_message = 'No Access Agreement or undeclared EEZ matched this combination'
      and aa.functional_group_id is not null
      and length(coalesce(aa.functional_group_id, '')) > 0
   order by l.fishing_entity_id, l.eez_id, aa.start_year, aa.end_year
)
select d.*, (select array_to_string(array_agg(u.fgi order by u.fgi), ';') from unnest(string_to_array(existing_aa_fgi || ';' || taxon_fgi, ';')::int[]) as u(fgi)) proposed_aa_fgi 
  from dat d
 where taxon_fgi != all(string_to_array(existing_aa_fgi, ';')::int[]);
select admin.grant_access();
select * from allocation.v_aa_addition_suggestions;
