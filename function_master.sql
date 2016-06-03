create or replace function master.lookup_rfb(i_name varchar, i_long_name text, i_profile_url text) returns int as
$body$
declare
  rtn_val int;
begin
  select rfb_id into rtn_val from master.rfb where lower(name) = lower(i_name);
  
  if not found then
    begin
      insert into master.rfb(name, long_name, profile_url) values(i_name, i_long_name, i_profile_url)
        returning rfb_id into rtn_val;
    exception
      when unique_violation then
        select rfb_id into rtn_val from master.rfb where lower(name) = lower(i_name);
    end;
  end if;
  
  return rtn_val;
end;
$body$
language plpgsql;

create or replace function master.lookup_fao_country(i_un_id smallint, i_name text, i_iso3 char(3), i_fid smallint) returns smallint as
$body$
declare
  rtn_val smallint;
begin
  select un_id into rtn_val from master.fao_country where un_id = i_un_id;
  
  if not found then
    begin
      insert into master.fao_country(un_id, country_iso3, name, fid) values(i_un_id, i_iso3, i_name, i_fid)
        returning un_id into rtn_val;
    exception
      when unique_violation then
        select un_id into rtn_val from master.fao_country where un_id = i_un_id;
    end;
  end if;
  
  return rtn_val;
end;
$body$
language plpgsql;

create or replace function master.fao_country_rfb_membership_crud(i_country_iso3 char(3), i_rfb_members int[]) 
returns table(deleted int, inserted int) as
$body$
  with mem(rfb_fid, mtype) as (
    select distinct m.fid::int, 'Full'::varchar from unnest(i_rfb_members) as m(fid)
  ),
  crm as (
    select crm.id, rfb_fid, membership_type from master.fao_country_rfb_membership crm where country_iso3 = i_country_iso3
  ),
  diff as (
    select crm.id,
           m.*, 
           (case 
              when m.rfb_fid is null then 'delete' 
              when crm.rfb_fid is null then 'insert' 
              else 'update' 
            end)::varchar as action
      from crm 
      full join mem m on (m.rfb_fid = crm.rfb_fid and m.mtype = crm.membership_type)
  ),
  del as (
    delete from master.fao_country_rfb_membership crm
     using diff d
     where d.action = 'delete'::varchar
       and d.id = crm.id
    returning 1
  ),
  ins as (
    insert into master.fao_country_rfb_membership(country_iso3, rfb_fid, membership_type)
    select i_country_iso3, i.rfb_fid, i.mtype
      from diff i
     where i.action = 'insert'::varchar
    returning 1
  )
  select (select count(*)::int from del), (select count(*)::int from ins);
$body$
language sql;

create or replace function master.taxon_child_tree(parent ltree) returns json as 
$body$
    var rows = plv8.execute("SELECT taxon_key as key,common_name as name, level, lineage, parent::text, " +
                            "       is_distribution_available as is_dist, is_extent_available as is_extent, " +
                            "       to_char(total_catch, '999,999,999,999,999.99') as total_catch, " +
                            "       to_char(total_value, '999,999,999,999,999.99') as total_value " +
                            "  FROM master.v_taxon_lineage "+ 
                            " WHERE parent <@ $1 " + 
                            " ORDER BY nlevel(parent),common_name", 
                            [parent]);
    
    var all = {},
        out = [],
        top,r,i;
        
    for(i=0; i<rows.length; i++){
        r = rows[i];
        r.children = [];
        //all[r.id] = r;
        all[r.lineage] = r;
        if(r.parent == parent){
            out.push(r);
        }
    }
    
    for(i=0; i<rows.length; i++){
        r = rows[i];
        if(all[ r.parent ]){
            all[ r.parent ].children.push(r);
        }
    }
    
    return JSON.stringify(out,null,0);
$body$ 
language plv8;

create or replace function master.replace_taxon(i_old_taxon_key int) returns void as
$body$
declare
  repl log.taxon_replacement%ROWTYPE;
  prec record;
begin
  for repl in select * from log.taxon_replacement where old_taxon_key = i_old_taxon_key and replaced_timestamp is null loop
    raise info 'Replacing old taxon % with the new taxon %', i_old_taxon_key, repl.new_taxon_key;
    
    if exists (select 1 from master.taxon where taxon_key = repl.new_taxon_key limit 1) then
      update master.taxon set is_retired = true, comments_names = repl.comments_names, date_updated = now() where taxon_key = i_old_taxon_key;
    else
      update master.taxon 
         set is_retired = false, taxon_key = repl.new_taxon_key, taxon_level_id = substr(repl.new_taxon_key::text,1,1)::int, 
             comments_names = repl.comments_names, date_updated = now() 
       where taxon_key = i_old_taxon_key;
    end if;
    
    if exists (select 1 from allocation.catch_by_taxon where taxon_key = repl.new_taxon_key limit 1) then
      delete from allocation.catch_by_taxon where taxon_key = i_old_taxon_key;
    else
      update allocation.catch_by_taxon t set taxon_key = repl.new_taxon_key where t.taxon_key = i_old_taxon_key;
    end if;
    
    if not exists (select 1 from allocation.taxon_distribution_old where taxon_key = repl.new_taxon_key limit 1) then
      update allocation.taxon_distribution_old t set taxon_key = repl.new_taxon_key where t.taxon_key = i_old_taxon_key;
    end if;
    
    update distribution.taxon_extent t set taxon_key = repl.new_taxon_key where t.taxon_key = i_old_taxon_key;
    
    if exists (select 1 from distribution.taxon_habitat where taxon_key = repl.new_taxon_key limit 1) then
      delete from distribution.taxon_habitat where taxon_key = i_old_taxon_key;
    else
      update distribution.taxon_habitat t set taxon_key = repl.new_taxon_key where t.taxon_key = i_old_taxon_key;
    end if;
                                                                
    update geo.mariculture t set taxon_key = repl.new_taxon_key where t.taxon_key = i_old_taxon_key;
    update geo.mariculture_entity t set taxon_key = repl.new_taxon_key where t.taxon_key = i_old_taxon_key;
    update geo.mariculture_points t set taxon_key = repl.new_taxon_key where t.taxon_key = i_old_taxon_key;
    update master.excluded_taxon t set taxon_key = repl.new_taxon_key where t.taxon_key = i_old_taxon_key;
    update master.layer3_taxon t set taxon_key = repl.new_taxon_key where t.taxon_key = i_old_taxon_key;
    update master.rare_taxon t set taxon_key = repl.new_taxon_key where t.taxon_key = i_old_taxon_key;
    update recon.raw_catch t set taxon_key = repl.new_taxon_key where t.taxon_key = i_old_taxon_key;
    update recon.catch t set original_taxon_name_id = repl.new_taxon_key where t.original_taxon_name_id = i_old_taxon_key;
    update recon.catch t set taxon_key = repl.new_taxon_key where t.taxon_key = i_old_taxon_key;
    
    for prec in select p.year, p.fishing_entity_id, p.price
                  from master.price p
                 where p.taxon_key = i_old_taxon_key             
    loop
      if exists (select 1 from master.price where year = prec.year and fishing_entity_id = prec.fishing_entity_id and taxon_key = repl.new_taxon_key limit 1) then
        delete from master.price where year = prec.year and fishing_entity_id = prec.fishing_entity_id and taxon_key = i_old_taxon_key;
      else
        update master.price set taxon_key = repl.new_taxon_key where year = prec.year and fishing_entity_id = prec.fishing_entity_id and taxon_key = i_old_taxon_key;
      end if;
    end loop;
   
   update master.rfmo_managed_taxon t 
      set primary_taxon_keys = 
            (select array_agg(case when u.taxon_key is distinct from i_old_taxon_key then u.taxon_key else repl.new_taxon_key end) 
               from unnest(t.primary_taxon_keys) as u(taxon_key)
            );
     
   update master.rfmo_managed_taxon t 
      set secondary_taxon_keys = 
            (select array_agg(case when u.taxon_key is distinct from i_old_taxon_key then u.taxon_key else repl.new_taxon_key end) 
               from unnest(t.secondary_taxon_keys) as u(taxon_key)
            );
   
   update distribution.taxon_extent_rollup t set taxon_key = repl.new_taxon_key where t.taxon_key = i_old_taxon_key;
   
   update distribution.taxon_extent_rollup t 
      set children_taxon_keys = 
            (select array_agg(case when u.taxon_key is distinct from i_old_taxon_key then u.taxon_key else repl.new_taxon_key end) 
              from unnest(t.children_taxon_keys) as u(taxon_key)
            );
     
    update log.taxon_replacement set replaced_timestamp = current_timestamp where old_taxon_key = i_old_taxon_key;
  end loop;
end
$body$
language plpgsql;
                                                                                
create or replace function master.taxon_functional_group_rollup_candidates(i_target_taxon_level int) 
returns table(spec_type text, taxon_key int, taxon_name text, existing_functional_group_id smallint, proposed_functional_group_id smallint) as
$body$
begin                                         
  if i_target_taxon_level < 1 then
    raise exception 'Input level should be greater than or equal to 1.';
    return;
  end if;     

  return query
  with rays as (
    select tc.taxon_key, tc.taxon_level_id, tc.lineage 
      from log.taxon_catalog tc
     where tc."type" = 'superorder' and tc.superorder = 'Batoidea'
  ),
  sharks as (
    select tc.taxon_key, tc.taxon_level_id, (tc.lineage::text || '.NA')::ltree as lineage 
      from log.taxon_catalog tc 
     where tc."type" = 'class' and tc.class = 'Elasmobranchii'
  ),
  flats as (
    select tc.taxon_key, tc.taxon_level_id, tc.lineage
      from log.taxon_catalog tc where tc.type = 'order' and tc."order" = 'Pleuronectiformes'
  ),
  other as (
    (select lp.taxon_key, cat_c.functional_group_id, count(*) rec_count
       from log.taxon_catalog lp
       join catalog.taxon_catalog cat_p on (cat_p.taxon_key = lp.taxon_key)
       join log.taxon_catalog lc on (lc.lineage <@ lp.lineage and lc.taxon_level_id = (i_target_taxon_level + 1) and not lc.is_retired)
       join catalog.taxon_catalog cat_c on (cat_c.taxon_key = lc.taxon_key and cat_c.functional_group_id is not null)
      where lp.taxon_level_id = i_target_taxon_level and not lp.is_retired
        and not exists (select 1 from rays where lp.lineage <@ rays.lineage limit 1) 
        and not exists (select 1 from sharks where lp.lineage <@ sharks.lineage limit 1) 
      group by lp.taxon_key, cat_c.functional_group_id)
  ),
  candidate as (
    (select 'catch_all' as spec_type, t.taxon_key, max(tc.taxon_name) as taxon_name, 
            max(tc.functional_group_id) as existing_functional_group_id, 
            (array_agg(t.functional_group_id order by t.rec_count desc))[1] as proposed_functional_group_id
       from other t
       join catalog.taxon_catalog tc on (tc.taxon_key = t.taxon_key)
      group by t.taxon_key)
    union all
    (select 'rays', t.taxon_key, t.taxon_name, cat.functional_group_id, fg.functional_group_id
       from rays r
       join log.taxon_catalog t on (t.lineage <@ r.lineage and t.taxon_level_id = i_target_taxon_level)
       join catalog.taxon_catalog cat on (cat.taxon_key = t.taxon_key)
       join master.functional_groups fg on (fg.name ilike 'ray%' and fg.size_range @> cat.sl_max::numeric))
    union all
    (select 'sharks', t.taxon_key, t.taxon_name, cat.functional_group_id, fg.functional_group_id
       from sharks r
       join log.taxon_catalog t on (t.lineage <@ r.lineage and t.taxon_level_id = i_target_taxon_level)
       join catalog.taxon_catalog cat on (cat.taxon_key = t.taxon_key)
       join master.functional_groups fg on (fg.name ilike 'shark%' and fg.size_range @> cat.sl_max::numeric))
    union all
    (select 'flats', t.taxon_key, t.taxon_name, cat.functional_group_id, fg.functional_group_id
       from flats r
       join log.taxon_catalog t on (t.lineage <@ r.lineage and t.taxon_level_id = i_target_taxon_level)
       join catalog.taxon_catalog cat on (cat.taxon_key = t.taxon_key)
       join master.functional_groups fg on (fg.name ilike 'flatfish%' and fg.size_range @> cat.sl_max::numeric))
  )
  select * from candidate c where c.existing_functional_group_id is distinct from c.proposed_functional_group_id;
end
$body$
language plpgsql;

create or replace function master.lineage_pretty(i_value varchar) returns text as
$body$
  SELECT CASE WHEN COALESCE(upper(i_value), '') = 'NA' THEN 'NA' ELSE COALESCE(REPLACE(REPLACE(INITCAP(TRIM(i_value)), ' ', ''), '-', ''), 'NA') END;
$body$
language sql;

/*
The command below should be maintained as the last command in this entire script.
*/
SELECT admin.grant_access();
