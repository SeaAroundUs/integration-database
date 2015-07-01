/*
CREATE TABLE admin.datatransfer_tables(
  id SERIAL PRIMARY KEY,
  source_database_name VARCHAR(256),
  source_table_name VARCHAR(256),
  source_key_column VARCHAR(256),
  source_where_clause TEXT,
  target_schema_name VARCHAR(256),
  target_table_name VARCHAR(256),
  target_excluded_columns TEXT[],
  number_of_threads INT NOT NULL DEFAULT 1,
  last_transferred TIMESTAMP,
  last_transfer_success BOOLEAN
);
*/
