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
