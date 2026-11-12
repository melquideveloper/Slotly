#!/bin/sh

set -eu

: "${DB_USERNAME:?DB_USERNAME não definida}"
: "${DB_PASSWORD:?DB_PASSWORD não definida}"

psql \
    --username "$POSTGRES_USER" \
    --dbname "$POSTGRES_DB" \
    --set=app_user="$DB_USERNAME" \
    --set=app_password="$DB_PASSWORD" \
    --set=db_name="$POSTGRES_DB" \
    --set=ON_ERROR_STOP=1 <<'SQL'

SELECT format(
    'CREATE ROLE %I LOGIN PASSWORD %L',
    :'app_user',
    :'app_password'
) \gexec

GRANT CONNECT ON DATABASE :"db_name" TO :"app_user";

\connect :db_name

GRANT USAGE, CREATE ON SCHEMA public TO :"app_user";

SQL