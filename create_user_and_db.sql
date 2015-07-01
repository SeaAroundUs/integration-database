\echo
\echo Creating SAU Database...
\echo

DROP DATABASE IF EXISTS sau_int;
CREATE DATABASE sau_int;

DROP USER IF EXISTS sau_int;
CREATE USER sau_int WITH PASSWORD 'sau_int';
DROP USER IF EXISTS web_int;
CREATE USER web_int WITH PASSWORD 'web_int';

ALTER DATABASE sau_int OWNER TO sau_int;
GRANT postgres TO sau_int;

ALTER USER sau_int SET search_path TO admin, master, recon, distribution, log, tiger, topology, tiger_data, public;
ALTER USER web_int SET search_path TO master, recon, distribution, log, admin, tiger, topology, tiger_data, public;
