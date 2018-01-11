## Project for synchronization remote databases on tmp tables and loops. Also creating OLAP storage.
#### add shared libs
shared_preload_libraries = 'pg_cron'
cron.database_name = 'center'
#### Enable pg_cron
SET autocommit = 1;
CREATE EXTENSION pg_cron;
GRANT USAGE ON SCHEMA cron TO regular_pgsql_user;
#### Enable dblink in schema dblink
CREATE EXTENSION dblink;
