CREATE TABLE admin.version (
  id serial primary key,
  name varchar(50),
  major int not null,
  minor int not null,
  revision int,
  is_active boolean not null default false,
  released_to_qa timestamp,
  released_to_staging timestamp,
  released_to_production timestamp,
  last_modified timestamp not null default now(),
  description text
);

/* For transfering of external data to the integration db from either postgres or SQL Server sources */
CREATE TABLE admin.datatransfer_tables(
  id SERIAL PRIMARY KEY,
  source_database_name VARCHAR(256),
  source_table_name VARCHAR(256),
  source_key_column VARCHAR(256),
  source_select_clause TEXT,
  source_where_clause TEXT,
  target_schema_name VARCHAR(256),
  target_table_name VARCHAR(256),
  target_excluded_columns TEXT[],
  number_of_threads INT NOT NULL DEFAULT 1,
  last_transferred TIMESTAMP,
  last_transfer_success BOOLEAN
);

CREATE TABLE admin.database_foreign_key (
  drop_fk_cmd TEXT,
  add_fk_cmd TEXT,
  modified TIMESTAMP NOT NULL DEFAULT current_timestamp,
  one_row_condition BOOLEAN PRIMARY KEY DEFAULT TRUE,
  CONSTRAINT database_foreign_key_one_row_condition_uk CHECK(one_row_condition)
);

/*
Forward declaration of this function to allow for its inclusion in each scripts below
*/
--- Granting access to user is very important to enable insert/delete/update 
--- operations on the tables

DO 
$$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'grant_access' LIMIT 1) THEN
    CREATE OR REPLACE FUNCTION admin.grant_access() RETURNS void AS
    $body$
      GRANT USAGE ON SCHEMA admin TO web_int, qc_int, recon_int, distribution_int, gis_int;
    $body$
    LANGUAGE sql
    SECURITY DEFINER;
    
    PERFORM admin.grant_access();
  END IF;
END
$$;
