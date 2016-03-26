create or replace function geo.update_cell_fao_area_id() returns int as
$body$
  with asi(cell_id, fao_area_id) as (
    select cell_id, (array_agg(fao_area_id order by water_area desc))[1] 
      from geo.simple_area_cell_assignment_raw
     group by cell_id
  ),
  upd as (
    update master.cell c
       set fao_area_id = a.fao_area_id
      from asi a
     where c.cell_id = a.cell_id
       and c.fao_area_id is distinct from a.fao_area_id
    returning 1
  )
  select count(*)::int from upd;
$body$
language sql;
