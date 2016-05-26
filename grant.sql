--- Granting access to user is very important to enable insert/delete/update 
--- operations on the tables

CREATE OR REPLACE FUNCTION admin.grant_privilege(i_schema text, i_user text, i_is_read_write boolean = false, i_is_delete boolean = false) RETURNS void AS
$body$
BEGIN
  -- For all
  EXECUTE format('GRANT USAGE ON SCHEMA %s TO %s', i_schema, i_user);
  
  IF i_is_read_write THEN
    IF i_is_delete THEN
      EXECUTE format('GRANT SELECT,INSERT,UPDATE,DELETE,REFERENCES ON ALL TABLES IN SCHEMA %s TO %s', i_schema, i_user);
    ELSE
      EXECUTE format('GRANT INSERT,UPDATE,SELECT,REFERENCES ON ALL TABLES IN SCHEMA %s TO %s', i_schema, i_user);
    END IF;
    
    EXECUTE format('GRANT ALL ON ALL SEQUENCES IN SCHEMA %s TO %s', i_schema, i_user);
    EXECUTE format('GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA %s TO %s', i_schema, i_user);
  ELSE
    EXECUTE format('GRANT SELECT,REFERENCES ON ALL TABLES IN SCHEMA %s TO %s', i_schema, i_user);
    EXECUTE format('GRANT USAGE,SELECT ON ALL SEQUENCES IN SCHEMA %s TO %s', i_schema, i_user);
    EXECUTE format('GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA %s TO %s', i_schema, i_user);
  END IF;
     
  RETURN;
END
$body$
LANGUAGE plpgsql
SECURITY DEFINER;

CREATE OR REPLACE FUNCTION admin.grant_access() RETURNS void AS
$body$
  -- For user web_int
  SELECT admin.grant_privilege('master', 'web_int', false, false);
  SELECT admin.grant_privilege('admin', 'web_int', false, false);
  SELECT admin.grant_privilege('log', 'web_int', false, false);
  SELECT admin.grant_privilege('recon', 'web_int', false, false);
  SELECT admin.grant_privilege('distribution', 'web_int', false, false);
  SELECT admin.grant_privilege('catalog', 'web_int', false, false);
  SELECT admin.grant_privilege('allocation', 'web_int', false, false);
  SELECT admin.grant_privilege('geo', 'web_int', false, false);
  SELECT admin.grant_privilege('validation_partition', 'web_int', false, false);
  
  -- For user qc_int (user for UBC staff)
  SELECT admin.grant_privilege('master', 'qc_int', false, false);
  SELECT admin.grant_privilege('admin', 'qc_int', false, false);
  SELECT admin.grant_privilege('log', 'qc_int', false, false);
  SELECT admin.grant_privilege('recon', 'qc_int', false, false);
  SELECT admin.grant_privilege('distribution', 'qc_int', false, false);
  SELECT admin.grant_privilege('catalog', 'qc_int', true, false);
  SELECT admin.grant_privilege('allocation', 'qc_int', false, false);
  SELECT admin.grant_privilege('geo', 'qc_int', false, false);
  SELECT admin.grant_privilege('catalog', 'qc_int', false, false);
  SELECT admin.grant_privilege('validation_partition', 'qc_int', false, false);

  -- For user recon_int
  SELECT admin.grant_privilege('master', 'recon_int', true, true);
  SELECT admin.grant_privilege('admin', 'recon_int', false, false);
  SELECT admin.grant_privilege('log', 'recon_int', true, true);
  SELECT admin.grant_privilege('recon', 'recon_int', true, true);
  SELECT admin.grant_privilege('distribution', 'recon_int', false, false);
  SELECT admin.grant_privilege('catalog', 'recon_int', true, false);
  SELECT admin.grant_privilege('allocation', 'recon_int', false, false);
  SELECT admin.grant_privilege('validation_partition', 'recon_int', false, false);

  -- more granular access for the following tables:
  GRANT INSERT,UPDATE,SELECT,DELETE,REFERENCES ON distribution.taxon_habitat TO recon_int;
  GRANT INSERT,UPDATE,SELECT,DELETE,REFERENCES ON distribution.taxon_distribution_substitute TO recon_int;
  
  -- For user distribution_int
  SELECT admin.grant_privilege('master', 'distribution_int', false, false);
  SELECT admin.grant_privilege('admin', 'distribution_int', false, false);
  SELECT admin.grant_privilege('log', 'distribution_int', false, false);
  SELECT admin.grant_privilege('recon', 'distribution_int', false, false);
  SELECT admin.grant_privilege('distribution', 'distribution_int', true, true);
  SELECT admin.grant_privilege('geo', 'distribution_int', false, false);
  SELECT admin.grant_privilege('allocation', 'distribution_int', false, false);
   
  -- For user gis_int
  SELECT admin.grant_privilege('master', 'gis_int', false, false);
  SELECT admin.grant_privilege('admin', 'gis_int', false, false);
  SELECT admin.grant_privilege('log', 'gis_int', false, false);
  SELECT admin.grant_privilege('recon', 'gis_int', false, false);
  SELECT admin.grant_privilege('distribution', 'gis_int', false, false);
  SELECT admin.grant_privilege('geo', 'gis_int', true, true);
$body$
LANGUAGE sql
SECURITY DEFINER;

SELECT admin.grant_access();
