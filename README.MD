#add shared libs
shared_preload_libraries = 'pg_cron'
# Enable pg_cron
SET autocommit = 1;
CREATE EXTENSION pg_cron;
GRANT USAGE ON SCHEMA cron TO regular_pgsql_user;