
#!/usr/bin/env bash

set -Eeuo pipefail

echo "===== FLYWAY MIGRATION VALIDATION ====="

: "${POSTGRES_USER:?POSTGRES_USER is required}"
: "${DB_NAME:?DB_NAME is required}"

docker compose exec -T postgres \
    psql -U "$POSTGRES_USER" -d "$DB_NAME" \
    -v ON_ERROR_STOP=1 <<'SQL'

DO $$
DECLARE
    table_name TEXT;
BEGIN

    -- Verify Flyway history table
    IF to_regclass('public.flyway_schema_history') IS NULL THEN
        RAISE EXCEPTION
            'Flyway schema history table does not exist';
    END IF;

    -- Verify V1 migration
    IF NOT EXISTS (
        SELECT 1
        FROM flyway_schema_history
        WHERE version = '1'
          AND success = TRUE
          AND type = 'SQL'
    ) THEN
        RAISE EXCEPTION
            'Flyway migration V1 was not successfully applied';
    END IF;

    -- Verify V2 migration
    IF NOT EXISTS (
        SELECT 1
        FROM flyway_schema_history
        WHERE version = '2'
          AND success = TRUE
          AND type = 'SQL'
    ) THEN
        RAISE EXCEPTION
            'Flyway migration V2 was not successfully applied';
    END IF;

    -- Verify expected application tables
    FOREACH table_name IN ARRAY ARRAY[
        'organizations',
        'users',
        'memberships'
    ]
    LOOP
        IF to_regclass('public.' || table_name) IS NULL THEN
            RAISE EXCEPTION
                'Expected table does not exist: %',
                table_name;
        END IF;
    END LOOP;

    RAISE NOTICE
        'Flyway migrations validated successfully.';

END
$$;

-- Display applied migrations
SELECT
    installed_rank,
    version,
    description,
    success
FROM flyway_schema_history
ORDER BY installed_rank;

-- Display application tables
SELECT
    tablename
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN (
      'organizations',
      'users',
      'memberships'
  )
ORDER BY tablename;

SQL

echo "SUCCESS: Flyway migrations validated."
