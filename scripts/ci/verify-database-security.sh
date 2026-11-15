
#!/usr/bin/env bash

set -Eeuo pipefail

echo "===== DATABASE SECURITY VALIDATION ====="

: "${POSTGRES_USER:?POSTGRES_USER is required}"
: "${DB_NAME:?DB_NAME is required}"

docker compose exec -T postgres \
    psql -U "$POSTGRES_USER" -d "$DB_NAME" \
    -v ON_ERROR_STOP=1 <<'SQL'

DO $$
DECLARE
    table_name TEXT;
BEGIN

    -- Verify runtime role
    IF NOT EXISTS (
        SELECT 1
        FROM pg_roles
        WHERE rolname = 'slotly_app'
          AND rolcanlogin
    ) THEN
        RAISE EXCEPTION
            'Runtime role slotly_app does not exist or cannot login';
    END IF;

    -- Verify migrator role
    IF NOT EXISTS (
        SELECT 1
        FROM pg_roles
        WHERE rolname = 'slotly_migrator'
          AND rolcanlogin
    ) THEN
        RAISE EXCEPTION
            'Migrator role slotly_migrator does not exist or cannot login';
    END IF;

    -- Verify application roles are not privileged
    IF EXISTS (
        SELECT 1
        FROM pg_roles
        WHERE rolname IN ('slotly_app', 'slotly_migrator')
          AND (
              rolsuper
              OR rolcreatedb
              OR rolcreaterole
              OR rolreplication
              OR rolbypassrls
          )
    ) THEN
        RAISE EXCEPTION
            'Application roles have excessive privileges';
    END IF;

    -- Runtime user must not create objects
    IF has_schema_privilege(
        'slotly_app',
        'public',
        'CREATE'
    ) THEN
        RAISE EXCEPTION
            'Runtime user must not CREATE objects';
    END IF;

    -- Runtime user must access schema
    IF NOT has_schema_privilege(
        'slotly_app',
        'public',
        'USAGE'
    ) THEN
        RAISE EXCEPTION
            'Runtime user must have schema USAGE';
    END IF;

    -- Migrator must create objects
    IF NOT has_schema_privilege(
        'slotly_migrator',
        'public',
        'CREATE'
    ) THEN
        RAISE EXCEPTION
            'Migrator must have schema CREATE';
    END IF;

    -- Verify CRUD permissions on business tables
    FOREACH table_name IN ARRAY ARRAY[
        'organizations',
        'users',
        'memberships'
    ]
    LOOP
        IF NOT has_table_privilege(
            'slotly_app',
            'public.' || table_name,
            'SELECT'
        )
        OR NOT has_table_privilege(
            'slotly_app',
            'public.' || table_name,
            'INSERT'
        )
        OR NOT has_table_privilege(
            'slotly_app',
            'public.' || table_name,
            'UPDATE'
        )
        OR NOT has_table_privilege(
            'slotly_app',
            'public.' || table_name,
            'DELETE'
        ) THEN
            RAISE EXCEPTION
                'Runtime privileges are incomplete for table %',
                table_name;
        END IF;
    END LOOP;

    -- Runtime must not access Flyway history
    IF has_table_privilege(
        'slotly_app',
        'public.flyway_schema_history',
        'SELECT'
    )
    OR has_table_privilege(
        'slotly_app',
        'public.flyway_schema_history',
        'INSERT'
    )
    OR has_table_privilege(
        'slotly_app',
        'public.flyway_schema_history',
        'UPDATE'
    )
    OR has_table_privilege(
        'slotly_app',
        'public.flyway_schema_history',
        'DELETE'
    ) THEN
        RAISE EXCEPTION
            'Runtime user must not access Flyway history';
    END IF;

    -- Migrator must retain Flyway history permissions
    IF NOT has_table_privilege(
        'slotly_migrator',
        'public.flyway_schema_history',
        'SELECT'
    )
    OR NOT has_table_privilege(
        'slotly_migrator',
        'public.flyway_schema_history',
        'INSERT'
    )
    OR NOT has_table_privilege(
        'slotly_migrator',
        'public.flyway_schema_history',
        'UPDATE'
    ) THEN
        RAISE EXCEPTION
            'Migrator privileges on Flyway history are incomplete';
    END IF;

    RAISE NOTICE
        'Database roles and privileges validated successfully.';

END
$$;

SQL

echo "SUCCESS: Database security validated."
