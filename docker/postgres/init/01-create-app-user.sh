
#!/bin/sh

set -eu

: "${DB_USERNAME:?DB_USERNAME não definida}"
: "${DB_PASSWORD:?DB_PASSWORD não definida}"
: "${MIGRATOR_USERNAME:?MIGRATOR_USERNAME não definida}"
: "${MIGRATOR_PASSWORD:?MIGRATOR_PASSWORD não definida}"

psql \
    --username="$POSTGRES_USER" \
    --dbname="$POSTGRES_DB" \
    --set=app_user="$DB_USERNAME" \
    --set=app_password="$DB_PASSWORD" \
    --set=migrator_user="$MIGRATOR_USERNAME" \
    --set=migrator_password="$MIGRATOR_PASSWORD" \
    --set=db_name="$POSTGRES_DB" \
    --set=ON_ERROR_STOP=1 <<'SQL'

-- Create application roles
SELECT format(
    'CREATE ROLE %I LOGIN PASSWORD %L',
    :'app_user',
    :'app_password'
) \gexec

SELECT format(
    'CREATE ROLE %I LOGIN PASSWORD %L',
    :'migrator_user',
    :'migrator_password'
) \gexec

-- Database access
GRANT CONNECT ON DATABASE :"db_name" TO :"app_user";
GRANT CONNECT ON DATABASE :"db_name" TO :"migrator_user";

\connect :db_name

-- Flyway permissions
GRANT USAGE, CREATE ON SCHEMA public TO :"migrator_user";

-- Application permissions
GRANT USAGE ON SCHEMA public TO :"app_user";

-- Default privileges for future business tables
ALTER DEFAULT PRIVILEGES
    FOR ROLE :"migrator_user"
    IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO :"app_user";

-- Default privileges for future sequences
ALTER DEFAULT PRIVILEGES
    FOR ROLE :"migrator_user"
    IN SCHEMA public
    GRANT USAGE, SELECT ON SEQUENCES TO :"app_user";

SQL
