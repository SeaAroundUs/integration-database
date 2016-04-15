CREATE OR REPLACE VIEW geo.v_test_cell_assigned_water_area_exceeds_entire_cell_area AS SELECT rw.marine_layer_id,
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
