\echo
\echo Creating SAU_INT Database and its users...
\echo

DROP DATABASE IF EXISTS sau_int;
CREATE DATABASE sau_int;

DO 
$$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_user WHERE usename = 'sau_int' LIMIT 1) THEN
    CREATE USER sau_int WITH PASSWORD 'sau_int';
    GRANT postgres TO sau_int;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_user WHERE usename = 'web_int' LIMIT 1) THEN
    CREATE USER web_int WITH PASSWORD 'web_int';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_user WHERE usename = 'recon_int' LIMIT 1) THEN
    CREATE USER recon_int WITH PASSWORD 'recon_int';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_user WHERE usename = 'distribution_int' LIMIT 1) THEN
    CREATE USER distribution_int WITH PASSWORD 'distribution_int';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_user WHERE usename = 'qc_int' LIMIT 1) THEN
    CREATE USER qc_int WITH PASSWORD 'qc_int';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_user WHERE usename = 'gis_int' LIMIT 1) THEN
    CREATE USER gis_int WITH PASSWORD 'gis_int';
  END IF;
END
$$;

ALTER DATABASE sau_int OWNER TO sau_int;
GRANT postgres TO sau_int;

