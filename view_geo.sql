CREATE MATERIALIZED view geo.v_fao                
as
  with gf(fao_area_id, ocean, sub_ocean, ymax, ymin, geom_geojson) as (
    select f.fao_area_id,
           min(f.ocean),
           min(f.sub_ocean),
           st_ymax(st_extent(f.geom)),      
           st_ymin(st_extent(f.geom)),
           st_asgeojson(st_simplify(min(f.geom), 0.02::double precision), 3)::json
      from geo.fao f
     group by f.fao_area_id
  )
  select gf.fao_area_id,
         w.name AS title,
         w.alternate_name AS alternate_title,
         gf.ocean,
         gf.sub_ocean,
         0::numeric AS area,
         0::numeric AS shape_length,
         0::numeric AS shape_area,
         ymax as lat_north,
         ymin as lat_south,
         gf.geom_geojson
    from gf                                     
    join master.fao_area w on (w.fao_area_id = gf.fao_area_id)
with no data;

CREATE OR REPLACE VIEW geo.v_test_cell_assigned_water_area_exceeds_entire_cell_area AS 
SELECT rw.marine_layer_id,                      
       rw.area_id,
       rw.fao_area_id,
       rw.cell_id,
       rw.water_area AS this_cell_assignment_water_area,
       c.water_area AS entire_water_area_of_this_cell
  FROM (simple_area_cell_assignment_raw rw
  JOIN cell c ON ((rw.cell_id = c.cell_id)))
 WHERE ((rw.water_area > (c.water_area * (1.02)::double precision))
       -- 1.02 is used instead of 1.0 to allow some tolerance
   AND (rw.marine_layer_id <> 0)); 

/*
The command below should be maintained as the last command in this entire script.
*/
select admin.grant_access();
