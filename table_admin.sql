
/*
Forward declaration of this function to allow for its inclusion in each scripts below
*/
--- Granting access to user is very important to enable insert/delete/update 
--- operations on the tables

CREATE OR REPLACE FUNCTION admin.grant_access() RETURNS void AS
$body$
  GRANT USAGE ON SCHEMA admin TO web_int, qc_int, recon_int, distribution_int, gis_int;
$body$
LANGUAGE sql
SECURITY DEFINER;
