\echo
\echo Creating allocation Schema...
-- sau public (global) schema objects
\i aggregate.sql
\i table_public.sql
\i view.sql
\cd util
\i initialize.sql
\cd ..

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

DROP SCHEMA IF EXISTS validation_partition CASCADE;
CREATE SCHEMA validation_partition;

\i table_admin.sql
--\i populate_admin.sql

\echo
\echo Creating All tables first to avoid dependency problems later on
\echo
\i table_master.sql
\i table_allocation.sql
\i table_recon.sql
\i table_distribution.sql
\i table_geo.sql
\i table_log.sql
\i table_catalog.sql

\echo
\echo Creating DB Objects for the Master schema...
\echo
\i trigger_master.sql
\i function_master.sql
--\i mat_view_master.sql
--\i populate_master.sql

\echo
\echo Creating DB Objects for the Recon schema...
\echo
\i function_recon.sql
\i trigger_recon.sql

\echo
\echo Creating DB Objects for the Distribution schema...
\echo
\i function_habitat.sql
\i trigger_distribution.sql

\echo
\echo Creating DB Objects for the Log schema...
\echo

\echo
\echo Creating DB Objects for the Catalog schema...
\echo

\echo
\echo Creating DB Objects for the Allocation schema...
\echo
\i view_allocation.sql

\echo
\echo Creating DB Objects for the Geo schema...
\echo
\i view_geo.sql
\i function_geo.sql

\i view_recon.sql
\i view_distribution.sql
\i view_master.sql

\i function_distribution.sql

\i grant.sql
