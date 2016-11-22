TRUNCATE TABLE admin.datatransfer_tables;

INSERT INTO admin.datatransfer_tables(source_database_name, source_table_name, source_select_clause, source_where_clause, target_schema_name, target_table_name, target_excluded_columns)
VALUES
 ('Merlin', 'Log_Import_Raw', '*', NULL, 'allocation', 'log_import_raw', '{}'::TEXT[]) 
;

INSERT INTO admin.datatransfer_tables(source_database_name, source_table_name, source_select_clause, source_where_clause, target_schema_name, target_table_name, target_excluded_columns)
VALUES
 ('sau_geo', 'geo.simple_area_cell_assignment_raw', '*', NULL, 'geo', 'simple_area_cell_assignment_raw', '{}'::TEXT[]) 
,('sau_geo', 'geo.cell', '*', NULL, 'geo', 'cell', '{}'::TEXT[])
,('sau_geo', 'geo.EEZ', '*', NULL, 'geo', 'EEZ', '{}'::TEXT[])
,('sau_geo', 'geo.eez_big_cell_combo', '*', NULL, 'geo', 'eez_big_cell_combo', '{}'::TEXT[])
,('sau_geo', 'geo.eez_fao_combo', '*', NULL, 'geo', 'eez_fao_combo', '{}'::TEXT[])
,('sau_geo', 'geo.depth_adjustment_row_cell', '*', NULL, 'geo', 'depth_adjustment_row_cell', '{}'::TEXT[])
,('sau_geo', 'geo.ifa', '*', NULL, 'geo', 'ifa', '{}'::TEXT[])
,('sau_geo', 'geo.mariculture_entity', '*', NULL, 'geo', 'mariculture_entity', '{}'::TEXT[])
,('sau_geo', 'geo.area', '*', NULL, 'geo', 'area', '{}'::TEXT[])
,('sau_geo', 'geo.big_cell', '*', NULL, 'geo', 'big_cell', '{}'::TEXT[])
;
