#!/usr/bin/env bash

set -Eeuo pipefail

# Valida que o volume nomeado do PostgreSQL preserve dados após a remoção
# e recriação dos containers. Este teste NÃO deve ser executado em produção.
# Importante: usa `docker compose down` sem `-v`, preservando os volumes.

COMPOSE=(docker compose)
TEST_SLUG="persistence-check-$(date +%s)-$$"
RECORD_CREATED=false
STACK_STOPPED=false

run_psql() {
    "${COMPOSE[@]}" exec -T postgres sh -ec \
        'psql -X -qAt -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB"'
}

wait_for_postgres() {
    echo "Aguardando PostgreSQL ficar disponível..."

    for attempt in $(seq 1 30); do
        if "${COMPOSE[@]}" exec -T postgres \
            sh -ec 'pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB"' \
            >/dev/null 2>&1; then
            echo "PostgreSQL está disponível."
            return 0
        fi
        sleep 2
    done

    echo "ERRO: PostgreSQL não ficou disponível dentro do tempo esperado." >&2
    "${COMPOSE[@]}" logs --no-color postgres || true
    return 1
}

wait_for_application() {
    echo "Aguardando endpoint /api/health..."

    for attempt in $(seq 1 30); do
        if curl --fail --silent --show-error \
            http://localhost:8080/api/health >/dev/null 2>&1; then
            echo "Aplicação respondeu em /api/health."
            return 0
        fi
        sleep 3
    done

    echo "ERRO: aplicação não respondeu em /api/health." >&2
    "${COMPOSE[@]}" logs --no-color app || true
    return 1
}

cleanup_on_error() {
    local exit_code=$?
    trap - EXIT

    if [[ $exit_code -ne 0 ]]; then
        echo "ERRO: validação de persistência falhou." >&2

        if [[ "$STACK_STOPPED" == "true" ]]; then
            echo "Tentando restaurar os serviços..." >&2
            "${COMPOSE[@]}" up -d || true
            wait_for_postgres || true
        fi

        if [[ "$RECORD_CREATED" == "true" ]] && \
            "${COMPOSE[@]}" ps --services --filter status=running | grep -qx postgres; then
            echo "Tentando remover o registro temporário..." >&2
            run_psql <<SQL || true
DELETE FROM public.organizations WHERE slug = '${TEST_SLUG}';
SQL
        fi

        "${COMPOSE[@]}" ps -a || true
    fi

    exit "$exit_code"
}
trap cleanup_on_error EXIT

if ! docker info >/dev/null 2>&1; then
    echo "ERRO: Docker não está disponível. Inicie o Docker Desktop/Engine." >&2
    exit 1
fi

if ! "${COMPOSE[@]}" ps --services --filter status=running | grep -qx postgres; then
    echo "ERRO: serviço postgres não está em execução." >&2
    echo "Execute primeiro: docker compose up -d --build" >&2
    exit 1
fi

if ! "${COMPOSE[@]}" ps --services --filter status=running | grep -qx app; then
    echo "ERRO: serviço app não está em execução." >&2
    echo "Execute primeiro: docker compose up -d --build" >&2
    exit 1
fi

wait_for_postgres
wait_for_application

# Confirma que a tabela necessária existe antes de alterar o estado do ambiente.
TABLE_EXISTS=$(run_psql <<'SQL'
SELECT COUNT(*)
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name = 'organizations';
SQL
)

if [[ "$(printf '%s' "$TABLE_EXISTS" | tr -d '[:space:]')" != "1" ]]; then
    echo "ERRO: tabela public.organizations não encontrada. Verifique as migrations Flyway." >&2
    exit 1
fi

# Cria um registro isolado para esta execução.
echo "Criando registro temporário de prova..."
run_psql <<SQL
INSERT INTO public.organizations (id, name, slug)
VALUES (gen_random_uuid(), 'Slotly Persistence Check', '${TEST_SLUG}');
SQL
RECORD_CREATED=true

# Remove containers e rede, preservando o volume nomeado.
echo "Removendo containers sem remover volumes..."
STACK_STOPPED=true
"${COMPOSE[@]}" down

echo "Recriando containers..."
"${COMPOSE[@]}" up -d
STACK_STOPPED=false

wait_for_postgres
wait_for_application

echo "Verificando se o registro sobreviveu à recriação dos containers..."
FOUND_COUNT=$(run_psql <<SQL
SELECT COUNT(*)
FROM public.organizations
WHERE slug = '${TEST_SLUG}';
SQL
)
FOUND_COUNT="$(printf '%s' "$FOUND_COUNT" | tr -d '[:space:]')"

if [[ "$FOUND_COUNT" != "1" ]]; then
    echo "ERRO: esperado 1 registro persistido; encontrado: ${FOUND_COUNT:-vazio}." >&2
    exit 1
fi

# Remove somente o registro criado pelo próprio teste.
run_psql <<SQL
DELETE FROM public.organizations
WHERE slug = '${TEST_SLUG}';
SQL
RECORD_CREATED=false

trap - EXIT

echo "SUCESSO: o registro permaneceu no PostgreSQL após remover e recriar os containers."
echo "SUCESSO: registro temporário removido; volume persistente preservado."
