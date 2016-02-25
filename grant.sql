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
  SELECT admin.grant_privilege('admin', 'web_int', false, false);
  SELECT admin.grant_privilege('log', 'web_int', false, false);
  SELECT admin.grant_privilege('recon', 'web_int', true, false);
  
  GRANT USAGE ON SCHEMA recon TO web_int;
  GRANT INSERT,UPDATE,SELECT,REFERENCES ON ALL TABLES IN SCHEMA recon TO web_int;
  GRANT USAGE,SELECT,UPDATE ON ALL SEQUENCES IN SCHEMA recon TO web_int;
  GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA recon TO web_int;
  
  GRANT USAGE ON SCHEMA distribution TO web_int;
  GRANT INSERT,UPDATE,SELECT,REFERENCES ON ALL TABLES IN SCHEMA distribution TO web_int;
  GRANT USAGE,SELECT,UPDATE ON ALL SEQUENCES IN SCHEMA distribution TO web_int;
  GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA distribution TO web_int;
  
  GRANT USAGE ON SCHEMA log TO web_int;
  GRANT INSERT,UPDATE,SELECT,REFERENCES ON ALL TABLES IN SCHEMA log TO web_int;
  GRANT USAGE,SELECT,UPDATE ON ALL SEQUENCES IN SCHEMA log TO web_int;
  GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA log TO web_int;
  
  GRANT USAGE ON SCHEMA catalog TO web_int;
  GRANT INSERT,UPDATE,SELECT,REFERENCES ON ALL TABLES IN SCHEMA catalog TO web_int;
  GRANT USAGE,SELECT,UPDATE ON ALL SEQUENCES IN SCHEMA catalog TO web_int;
  GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA catalog TO web_int;
  
  GRANT USAGE ON SCHEMA allocation TO web_int;
  GRANT INSERT,UPDATE,SELECT,REFERENCES ON ALL TABLES IN SCHEMA allocation TO web_int;
  GRANT USAGE,SELECT,UPDATE ON ALL SEQUENCES IN SCHEMA allocation TO web_int;
  GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA allocation TO web_int;
  
  GRANT USAGE ON SCHEMA geo TO web_int;
  GRANT INSERT,UPDATE,SELECT,REFERENCES ON ALL TABLES IN SCHEMA geo TO web_int;
  GRANT USAGE,SELECT,UPDATE ON ALL SEQUENCES IN SCHEMA geo TO web_int;
  GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA geo TO web_int;
  
  -- For user qc_int (user for UBC staff)
  GRANT USAGE ON SCHEMA master TO qc_int;
  GRANT SELECT,REFERENCES ON ALL TABLES IN SCHEMA master TO qc_int;
  GRANT USAGE,SELECT ON ALL SEQUENCES IN SCHEMA master TO qc_int;
  GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA master TO qc_int;
  
  GRANT USAGE ON SCHEMA recon TO qc_int;
  GRANT SELECT,REFERENCES ON ALL TABLES IN SCHEMA recon TO qc_int;
  GRANT USAGE,SELECT ON ALL SEQUENCES IN SCHEMA recon TO qc_int;
  GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA recon TO qc_int;
  
  GRANT USAGE ON SCHEMA distribution TO qc_int;
  GRANT SELECT,REFERENCES ON ALL TABLES IN SCHEMA distribution TO qc_int;
  GRANT USAGE,SELECT ON ALL SEQUENCES IN SCHEMA distribution TO qc_int;
  GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA distribution TO qc_int;
  
  GRANT USAGE ON SCHEMA admin TO qc_int;
  GRANT SELECT,REFERENCES ON ALL TABLES IN SCHEMA admin TO qc_int;
  GRANT USAGE,SELECT ON ALL SEQUENCES IN SCHEMA admin TO qc_int;
  GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA admin TO qc_int;
  
  GRANT USAGE ON SCHEMA allocation TO qc_int;
  GRANT SELECT,REFERENCES ON ALL TABLES IN SCHEMA allocation TO qc_int;
  GRANT USAGE,SELECT ON ALL SEQUENCES IN SCHEMA allocation TO qc_int;
  GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA allocation TO qc_int;
  
  GRANT USAGE ON SCHEMA log TO qc_int;
  GRANT SELECT,REFERENCES ON ALL TABLES IN SCHEMA log TO qc_int;
  GRANT USAGE,SELECT ON ALL SEQUENCES IN SCHEMA log TO qc_int;
  GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA log TO qc_int;
  
  -- For user recon_int
  GRANT USAGE ON SCHEMA admin TO recon_int;
  GRANT SELECT,REFERENCES ON ALL TABLES IN SCHEMA admin TO recon_int;
  GRANT USAGE,SELECT ON ALL SEQUENCES IN SCHEMA admin TO recon_int;
  GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA admin TO recon_int;
  
  GRANT USAGE ON SCHEMA master TO recon_int;
  GRANT SELECT,INSERT,UPDATE,DELETE,REFERENCES ON ALL TABLES IN SCHEMA master TO recon_int;
  GRANT ALL ON ALL SEQUENCES IN SCHEMA master TO recon_int;
  GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA master TO recon_int;
  
  GRANT USAGE ON SCHEMA log TO recon_int;
  GRANT INSERT,UPDATE,SELECT,REFERENCES ON ALL TABLES IN SCHEMA log TO recon_int;
  GRANT ALL ON ALL SEQUENCES IN SCHEMA log TO recon_int;
  GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA log TO recon_int;
  
  GRANT USAGE ON SCHEMA recon TO recon_int;
  GRANT ALL ON ALL TABLES IN SCHEMA recon TO recon_int;
  GRANT ALL ON ALL SEQUENCES IN SCHEMA recon TO recon_int;
  GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA recon TO recon_int;
  
  GRANT USAGE ON SCHEMA log TO recon_int;
  GRANT ALL ON ALL TABLES IN SCHEMA log TO recon_int;
  GRANT ALL ON ALL SEQUENCES IN SCHEMA log TO recon_int;
  GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA log TO recon_int;
  
  GRANT USAGE ON SCHEMA distribution TO recon_int;
  GRANT USAGE,SELECT ON ALL SEQUENCES IN SCHEMA distribution TO recon_int;
  GRANT INSERT,UPDATE,SELECT,DELETE,REFERENCES ON distribution.taxon_habitat TO recon_int;
  GRANT INSERT,UPDATE,SELECT,DELETE,REFERENCES ON distribution.taxon_distribution_substitute TO recon_int;
  
  -- For user distribution_int
  GRANT USAGE ON SCHEMA admin TO distribution_int;
  GRANT SELECT,REFERENCES ON ALL TABLES IN SCHEMA admin TO distribution_int;
  GRANT USAGE,SELECT ON ALL SEQUENCES IN SCHEMA admin TO distribution_int;
  GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA admin TO distribution_int;
  
  GRANT USAGE ON SCHEMA master TO distribution_int;
  GRANT SELECT,REFERENCES ON ALL TABLES IN SCHEMA master TO distribution_int;
  GRANT USAGE,SELECT ON ALL SEQUENCES IN SCHEMA master TO distribution_int;
  GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA master TO distribution_int;
  
  GRANT USAGE ON SCHEMA log TO distribution_int;
  GRANT INSERT,UPDATE,SELECT,REFERENCES ON ALL TABLES IN SCHEMA log TO distribution_int;
  GRANT ALL ON ALL SEQUENCES IN SCHEMA log TO distribution_int;
  GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA log TO distribution_int;
  
  GRANT USAGE ON SCHEMA distribution TO distribution_int;
  GRANT ALL ON ALL TABLES IN SCHEMA distribution TO distribution_int;
  GRANT ALL ON ALL SEQUENCES IN SCHEMA distribution TO distribution_int;
  GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA distribution TO distribution_int;
  
  GRANT USAGE ON SCHEMA recon TO distribution_int;
  GRANT SELECT,REFERENCES ON ALL TABLES IN SCHEMA recon TO distribution_int;
  GRANT USAGE,SELECT ON ALL SEQUENCES IN SCHEMA recon TO distribution_int;
  GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA recon TO distribution_int;

  GRANT USAGE ON SCHEMA log TO distribution_int;
  GRANT SELECT,REFERENCES ON ALL TABLES IN SCHEMA log TO distribution_int;
  GRANT USAGE,SELECT ON ALL SEQUENCES IN SCHEMA log TO distribution_int;
  GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA log TO distribution_int;
  
  -- For user gis_int
  GRANT USAGE ON SCHEMA distribution TO gis_int;
  GRANT INSERT,UPDATE,SELECT,DELETE,REFERENCES ON distribution.taxon_extent TO gis_int;
  GRANT USAGE,SELECT ON ALL SEQUENCES IN SCHEMA distribution TO gis_int;
  
  GRANT USAGE ON SCHEMA geo TO gis_int;
  GRANT INSERT,UPDATE,SELECT,DELETE,REFERENCES ON ALL TABLES IN SCHEMA geo TO gis_int;
  GRANT USAGE,SELECT ON ALL SEQUENCES IN SCHEMA geo TO gis_int;
$body$
LANGUAGE sql
SECURITY DEFINER;

SELECT admin.grant_access();
