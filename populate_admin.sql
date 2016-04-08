TRUNCATE TABLE admin.datatransfer_tables;

INSERT INTO admin.datatransfer_tables(source_database_name, source_table_name, source_where_clause, target_schema_name, target_table_name, target_excluded_columns)
VALUES
 ('Merlin', 'Log_Import_Raw', NULL, 'allocation', 'log_import_raw', '{}'::TEXT[]) 
--,('Merlin', 'AreaInvisible', NULL, 'web', 'area_invisible', '{}'::TEXT[])
;
