\echo
\echo Creating allocation Schema...
\echo
\echo Adding usefull extensions...
-- sau public (global) schema objects
\i aggregate.sql
\i table_public.sql
\i view.sql
\cd util
\i initialize.sql
\cd ..

--These extensions are not supported by RDS
--CREATE EXTENSION adminpack;
--CREATE EXTENSION xml2;

DROP EXTENSION IF EXISTS dblink CASCADE;
DROP EXTENSION IF EXISTS hstore CASCADE;
DROP EXTENSION IF EXISTS intarray CASCADE;
DROP EXTENSION IF EXISTS tablefunc CASCADE;
DROP EXTENSION IF EXISTS "uuid-ossp" CASCADE;
DROP EXTENSION IF EXISTS fuzzystrmatch CASCADE;
DROP EXTENSION IF EXISTS postgis CASCADE;

CREATE EXTENSION dblink;
CREATE EXTENSION hstore;
CREATE EXTENSION intarray;
CREATE EXTENSION tablefunc;
CREATE EXTENSION "uuid-ossp";
CREATE EXTENSION fuzzystrmatch;
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;
CREATE EXTENSION postgis_tiger_geocoder;
--CREATE EXTENSION postgres_fdw;

\echo
\echo Creating Admin DB Objects...
\echo
\c sau_int sau_int
--- Create a project schema (namespace) for ease of maintenance (backup)
DROP SCHEMA IF EXISTS admin CASCADE;
CREATE SCHEMA admin;

DROP SCHEMA IF EXISTS master CASCADE;
CREATE SCHEMA master;

DROP SCHEMA IF EXISTS recon CASCADE;
CREATE SCHEMA recon;

DROP SCHEMA IF EXISTS distribution CASCADE;
CREATE SCHEMA distribution;

DROP SCHEMA IF EXISTS log CASCADE;
CREATE SCHEMA log;

DROP SCHEMA IF EXISTS catalog CASCADE;
CREATE SCHEMA catalog;

DROP SCHEMA IF EXISTS allocation CASCADE;
CREATE SCHEMA allocation;

DROP SCHEMA IF EXISTS geo CASCADE;
CREATE SCHEMA geo;

\i table_admin.sql
--\i populate_admin.sql

\echo
\echo Creating DB Objects for the Master schema...
\echo
\i table_master.sql
\i function_master.sql
--\i mat_view_master.sql
--\i populate_master.sql
\i view_master.sql

\echo
\echo Creating DB Objects for the Recon schema...
\echo
\i table_recon.sql

\echo
\echo Creating DB Objects for the Distribution schema...
\echo
\i table_distribution.sql
\i trigger_distribution.sql
\i function_distribution.sql

\echo
\echo Creating DB Objects for the Log schema...
\echo
\i table_log.sql

\echo
\echo Creating DB Objects for the Catalog schema...
\echo
\i table_catalog.sql

\echo
\echo Creating DB Objects for the Allocation schema...
\echo
\i table_allocation.sql

\echo
\echo Creating DB Objects for the Geo schema...
\echo
\i table_geo.sql

\i view_recon.sql

\i grant.sql
