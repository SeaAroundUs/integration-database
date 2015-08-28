--- Granting access to user is very important to enable insert/delete/update 
--- operations on the tables

-- For user web_int
GRANT USAGE ON SCHEMA admin TO web_int;
GRANT SELECT,REFERENCES ON ALL TABLES IN SCHEMA admin TO web_int;
GRANT USAGE,SELECT ON ALL SEQUENCES IN SCHEMA admin TO web_int;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA admin TO web_int;

GRANT USAGE ON SCHEMA master TO web_int;
GRANT SELECT,REFERENCES ON ALL TABLES IN SCHEMA master TO web_int;
GRANT USAGE,SELECT ON ALL SEQUENCES IN SCHEMA master TO web_int;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA master TO web_int;

GRANT USAGE ON SCHEMA log TO web_int;
GRANT INSERT,UPDATE,SELECT,REFERENCES ON ALL TABLES IN SCHEMA log TO web_int;
GRANT USAGE,SELECT,UPDATE ON ALL SEQUENCES IN SCHEMA log TO web_int;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA log TO web_int;

GRANT USAGE ON SCHEMA recon TO web_int;
GRANT INSERT,UPDATE,SELECT,REFERENCES ON ALL TABLES IN SCHEMA recon TO web_int;
GRANT USAGE,SELECT,UPDATE ON ALL SEQUENCES IN SCHEMA recon TO web_int;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA recon TO web_int;

GRANT USAGE ON SCHEMA distribution TO web_int;
GRANT INSERT,UPDATE,SELECT,REFERENCES ON ALL TABLES IN SCHEMA distribution TO web_int;
GRANT USAGE,SELECT,UPDATE ON ALL SEQUENCES IN SCHEMA distribution TO web_int;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA distribution TO web_int;

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
