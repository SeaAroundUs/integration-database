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
    
    SELECT admin.grant_access();
  END IF;
END
$$;
