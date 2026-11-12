
#!/usr/bin/env bash

set -Eeuo pipefail

echo "===== RUNTIME CRUD VALIDATION ====="

: "${DB_NAME:?DB_NAME is required}"
: "${DB_USERNAME:?DB_USERNAME is required}"
: "${DB_PASSWORD:?DB_PASSWORD is required}"

# Execute CRUD operations using the runtime user.
# Everything runs inside a transaction and is rolled back.

docker compose exec -T \
    -e PGPASSWORD="$DB_PASSWORD" \
    postgres \
    psql \
        -h 127.0.0.1 \
        -U "$DB_USERNAME" \
        -d "$DB_NAME" \
        -v ON_ERROR_STOP=1 <<'SQL'

BEGIN;

-- ORGANIZATIONS
INSERT INTO organizations (
    id,
    name,
    slug
)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    'CI Test',
    'ci-test'
);

UPDATE organizations
SET name = 'CI Test Updated'
WHERE slug = 'ci-test';

-- USERS
INSERT INTO users (
    id,
    name,
    email,
    password_hash
)
VALUES (
    '00000000-0000-0000-0000-000000000002',
    'CI User',
    'ci-user@example.com',
    'ci-test-hash'
);

UPDATE users
SET name = 'CI User Updated'
WHERE email = 'ci-user@example.com';

-- MEMBERSHIPS
INSERT INTO memberships (
    id,
    organization_id,
    user_id,
    role
)
VALUES (
    '00000000-0000-0000-0000-000000000003',
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000002',
    'OWNER'
);

UPDATE memberships
SET role = 'ADMIN'
WHERE id = '00000000-0000-0000-0000-000000000003';

-- DELETE operations
DELETE FROM memberships
WHERE id = '00000000-0000-0000-0000-000000000003';

DELETE FROM users
WHERE id = '00000000-0000-0000-0000-000000000002';

DELETE FROM organizations
WHERE id = '00000000-0000-0000-0000-000000000001';

ROLLBACK;

SQL

echo "SUCCESS: Runtime CRUD permissions validated."

# Verify runtime cannot create database objects.
echo "===== VERIFYING CREATE RESTRICTION ====="

set +e

OUTPUT=$(
    docker compose exec -T \
        -e PGPASSWORD="$DB_PASSWORD" \
        postgres \
        psql \
            -h 127.0.0.1 \
            -U "$DB_USERNAME" \
            -d "$DB_NAME" \
            -v ON_ERROR_STOP=1 \
            -c "CREATE TABLE public.runtime_forbidden_test (id integer)" \
            2>&1
)

EXIT_CODE=$?

set -e

if [ "$EXIT_CODE" -eq 0 ]; then
    echo "ERROR: Runtime user unexpectedly created a table."
    exit 1
fi

if [[ "$OUTPUT" != *"permission denied"* ]]; then
    echo "ERROR: CREATE TABLE failed for an unexpected reason."
    echo "$OUTPUT"
    exit 1
fi

echo "SUCCESS: Runtime user cannot create tables."
echo "SUCCESS: Runtime security validated."
