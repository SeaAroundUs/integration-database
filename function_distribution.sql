CREATE OR REPLACE FUNCTION distribution.st_create_fishnet(nrow integer, ncol integer, xsize float8, ysize float8)
RETURNS TABLE("seq" integer, "row" integer, col integer, geom geometry) AS
$body$
  SELECT (i*ncol + j + 1) as seq, i+1 AS row, j+1 AS col, ST_Translate(cell, -180 + j * $3, 90 - i * $4) AS geom
    FROM generate_series(0, $1-1 ) AS i,
         generate_series(0, $2-1 ) AS j,
         (
           SELECT ST_SETSRID(('POLYGON((0 0, 0 '||(-1*$4)||', '||$3||' '||(-1*$4)||', '||$3||' 0,0 0))')::geometry, 4326) AS cell
         ) AS foo;
$body$ 
LANGUAGE sql;

create or replace function distribution.load_taxon_extent(i_shape_table text) returns setof smallint as
$body$
declare
  ins_sql text;
  tk int := replace(i_shape_table, 'te_', '')::int;                            
begin
  if exists (select 1 from distribution.taxon_extent where taxon_key = tk limit 1) then
    delete from distribution.taxon_extent where taxon_key = tk;
  end if;
  
  ins_sql := format(
    'with dat as (
      insert into distribution.taxon_extent(taxon_key,geom)
      select %s, public.ST_ForceRHR(d.geom)
        from taxon_dis.%s d
      returning 1
    )
    select count(*)::smallint from dat', tk, i_shape_table);

  return query execute ins_sql;
end;
$body$                    
language plpgsql;

create or replace function distribution.get_rollup_taxon_list(i_for_taxon_level_id int) 
returns table(taxon_key int, children_distributions_found int, children_taxon_keys int[]) as
$body$
  select tp.taxon_key, count(*)::int, array_agg(tc.taxon_key) 
    from master.v_taxon_lineage tp
    join master.v_taxon_lineage tc 
      on (tc.parent = tp.lineage and tc.is_extent_available)
   where tp.level = i_for_taxon_level_id
     and not tp.is_extent_available
   group by tp.taxon_key
   order by 2 desc;
$body$
language sql;

create or replace function distribution.get_taxon_child_extents(i_parent_taxon_key int) 
returns table(taxon_key int, children_distributions_found int, children_taxon_keys int[]) as
$body$
  /* 
     Note this function returns child extents even when the input parent taxon already has an extent. 
     This is a departure from the get_rollup_taxon_list function above, which does not return 
     a parent taxon if it already has an extent available 
  */
  select tp.taxon_key, count(*)::int, array_agg(tc.taxon_key) 
    from master.v_taxon_lineage tp
    join master.v_taxon_lineage tc on (tc.lineage <@ tp.lineage and tc.level = (tp.level + 1) and tc.is_extent_available)
   where tp.taxon_key = i_parent_taxon_key
   group by tp.taxon_key;
$body$
language sql;

create or replace function distribution.extent_and_habitat_fao_overlap(i_taxon_key int) 
returns table(taxon_key int, fao_area_id int, contained boolean, overlaped boolean) as
$body$
  select h.taxon_key, f.fao_area_id, st_contains(f.geom, e.geom), st_overlaps(f.geom, e.geom)
    from distribution.taxon_extent e
    join distribution.taxon_habitat h on (h.taxon_key = e.taxon_key)
    join geo.fao f on (f.fao_area_id = any(h.found_in_fao_area_id))
   where e.taxon_key = i_taxon_key
   order by h.taxon_key, f.fao_area_id;
$body$     
language sql;

create or replace function distribution.extent_rollup_dumpout_polygons(i_parent_taxon_key int, i_descendant_taxon_key int[]) 
returns int as
$body$
  delete from distribution.taxon_extent_rollup_polygon where taxon_key = i_parent_taxon_key;
  
  with geo as (
    select (st_dump(geom)).geom from distribution.taxon_extent where taxon_key = any(i_descendant_taxon_key)
  )
  insert into distribution.taxon_extent_rollup_polygon(taxon_key, seq, geom)
  select i_parent_taxon_key, row_number() over(order by st_area(geom::geography, false)), geom from geo;
  
  select max(seq) from distribution.taxon_extent_rollup_polygon where taxon_key = i_parent_taxon_key;
$body$
language sql;

create or replace function distribution.extent_rollup_purge_contained_polygons(i_parent_taxon_key int, i_anchor_seq int) 
returns int as
$body$
  delete from distribution.taxon_extent_rollup_polygon rp
   using distribution.taxon_extent_rollup_polygon ap
   where ap.taxon_key = i_parent_taxon_key 
     and ap.seq = i_anchor_seq
     and rp.taxon_key = i_parent_taxon_key
     and rp.seq < i_anchor_seq
     and st_contains(ap.geom, rp.geom);
  
  select max(seq) from distribution.taxon_extent_rollup_polygon where taxon_key = i_parent_taxon_key and seq < i_anchor_seq;
$body$
language sql;

create or replace function distribution.taxon_extent_backfill() 
returns table(td_inserted int, log_inserted int) as       
$body$
  with old_dist(taxon_key) as (
    select distinct d.taxon_key
      from allocation.taxon_distribution_old d
      join master.taxon t on (t.taxon_key = d.taxon_key)
    except
    select distinct d.taxon_key
      from distribution.taxon_distribution d
  ),
  ins_td as (
  insert into distribution.taxon_distribution(taxon_key, cell_id, relative_abundance, is_backfilled)
  select d.taxon_key, d.cell_id, d.relative_abundance, true
    from allocation.taxon_distribution_old d
    join old_dist od on (od.taxon_key = d.taxon_key)
  returning 1
  ),               
  ins_log as (
  insert into distribution.taxon_distribution_log(taxon_key)
  select od.taxon_key  
    from old_dist od
    left join distribution.taxon_distribution_log l on (l.taxon_key = od.taxon_key)
   where l.taxon_key is null
  returning 1
  )
  select (select count(*)::int from ins_td), (select count(*)::int from ins_log);
$body$
language sql;

create or replace function distribution.taxon_lineage_tree(i_taxon_key int) 
returns table(taxon_key int, scientific_name varchar(256), common_name varchar(256), d boolean, e boolean, h boolean, lineage ltree, parent ltree) as       
$body$
  select c.taxon_key, c.scientific_name, c.common_name, c.is_distribution_available d, c.is_extent_available e,
         (e.taxon_key is not null) h, c.lineage, c.parent 
    from master.taxon p
    join master.v_taxon_lineage c on (c.lineage <@ p.lineage)
    left join distribution.taxon_extent e on (e.taxon_key = c.taxon_key)
   where p.taxon_key = i_taxon_key;
$body$
language sql;

/*
The command below should be maintained as the last command in this entire script.
*/
SELECT admin.grant_access();
