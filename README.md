# Slotly

Plataforma inteligente de agendamentos para pequenos negócios, como barbearias, clínicas, salões de beleza e profissionais autônomos.

O objetivo do Slotly é centralizar o gerenciamento de estabelecimentos, profissionais, clientes, serviços, disponibilidade e agendamentos, reduzindo conflitos de horários e tarefas manuais.

> **Status do projeto:** em desenvolvimento. A infraestrutura Docker/PostgreSQL e a base inicial do banco estão implementadas. Os módulos funcionais de identidade, multi-tenancy e agendamentos ainda fazem parte do roadmap.

## Stack tecnológica

- Java 21
- Spring Boot 4.1.2
- Maven Wrapper
- PostgreSQL 17
- Flyway para versionamento do schema
- Docker e Docker Compose
- JUnit, Spring Test e Testcontainers
- GitHub Actions para integração contínua

## Pré-requisitos

Para executar a aplicação em containers:

- Git
- Docker Engine ou Docker Desktop
- Docker Compose v2 (`docker compose`)

Para executar o build/testes Maven localmente:

- JDK 21
- Docker em execução para os testes de integração que utilizam Testcontainers

## Configuração local

1. Clone o repositório e entre na pasta do projeto:

   ```bash
   git clone https://github.com/melquideveloper/Slotly.git
   cd Slotly
   ```

2. Crie seu arquivo de ambiente local:

   ```bash
   cp .env.example .env
   ```

3. Edite o `.env` e substitua todos os valores `SUBSTITUA_...` por senhas fortes e diferentes. O arquivo `.env` contém credenciais e não deve ser versionado.

   O ambiente utiliza três papéis distintos no PostgreSQL:

   | Variável | Finalidade |
   | --- | --- |
   | `POSTGRES_USER` / `POSTGRES_PASSWORD` | Usuário administrativo usado na inicialização do container PostgreSQL |
   | `DB_USERNAME` / `DB_PASSWORD` | Usuário de execução da aplicação, com permissões de operação sobre as tabelas de negócio |
   | `MIGRATOR_USERNAME` / `MIGRATOR_PASSWORD` | Usuário utilizado pelo Flyway para aplicar migrations |

   `DB_NAME` define o banco, `DB_PORT` define a porta publicada no host (padrão `5432`) e `CORS_ALLOWED_ORIGINS` define as origens autorizadas pelo CORS.

## Executar com Docker Compose

Com o arquivo `.env` configurado, execute:

```bash
docker compose up -d --build
```

Verifique o estado dos serviços:

```bash
docker compose ps
```

Acompanhe os logs:

```bash
docker compose logs -f postgres app
```

A aplicação fica disponível em `http://localhost:8080`.

### Health check

O endpoint da aplicação verifica também a conectividade com o banco:

```bash
curl --fail http://localhost:8080/api/health
```

Resposta esperada quando aplicação e banco estão disponíveis:

```json
{
  "application": "Slotly",
  "status": "UP",
  "database": "UP"
}
```

O endpoint de saúde do Spring Actuator também está habilitado em `/actuator/health`.

## Banco de dados e migrations

O PostgreSQL utiliza o volume nomeado `slotly-postgres-data`, declarado no `docker-compose.yaml`, para persistir os dados fora do ciclo de vida dos containers.

As migrations SQL ficam em `src/main/resources/db/migration` e são aplicadas pelo Flyway na inicialização da aplicação:

- `V1__create_initial_schema.sql`: cria as tabelas iniciais `organizations`, `users` e `memberships`, além de suas constraints e índices.
- `V2__restrict_flyway_history_access.sql`: remove as permissões do usuário de execução sobre a tabela de histórico do Flyway.

O Hibernate está configurado com `ddl-auto=none`; a evolução do schema deve ocorrer por novas migrations Flyway, sem editar migrations que já tenham sido aplicadas em ambientes compartilhados.

## Persistência dos dados

Para reiniciar os containers preservando o volume:

```bash
docker compose down
docker compose up -d
```

**Importante:** não acrescente `-v` ao comando `docker compose down` se quiser preservar o banco. O comando abaixo remove também os volumes nomeados e, consequentemente, os dados persistidos:

```bash
docker compose down -v
```

Para executar a validação automatizada de persistência (insere um registro temporário, remove e recria os containers sem apagar o volume, confirma o registro e o remove ao final):

```bash
bash scripts/ci/verify-persistence.sh
```

Esse teste reinicia os serviços definidos no Compose e pode causar indisponibilidade temporária. Execute-o em ambiente local de desenvolvimento, não em um ambiente compartilhado ou de produção. Ele não usa `docker compose down -v` e não deve apagar os dados existentes.

## Build e testes

Execute a suíte completa com o Maven Wrapper:

```bash
./mvnw -B clean verify
```

No Windows (PowerShell):

```powershell
.\mvnw.cmd -B clean verify
```

Os testes de integração com PostgreSQL utilizam Testcontainers e precisam de um Docker Engine acessível. O perfil `test` configura o contexto de testes; o teste `HealthControllerPostgresIT` sobe um PostgreSQL temporário e habilita as migrations.

## Verificações de infraestrutura e banco

Com a stack iniciada por `docker compose up -d --build`, execute:

```bash
bash scripts/ci/verify-database-security.sh
bash scripts/ci/verify-flyway.sh
bash scripts/ci/verify-runtime-crud.sh
bash scripts/ci/verify-persistence.sh
```

Esses scripts verificam, respectivamente, papéis/permissões do banco, migrations e tabelas esperadas, permissões CRUD do usuário de execução e persistência do volume após recriação dos containers.

## Estrutura relevante

```text
.
├── .github/workflows/ci.yml
├── docker/
│   └── postgres/init/              # Inicialização dos papéis PostgreSQL
├── scripts/ci/                     # Verificações de infraestrutura e banco
├── src/
│   ├── main/
│   │   ├── java/com/slotly/sapl_agendamento/
│   │   └── resources/db/migration/  # Migrations Flyway
│   └── test/
│       ├── java/                    # Testes unitários e de integração
│       └── resources/               # Configurações de teste
├── .env.example
├── Dockerfile
├── docker-compose.yaml
├── mvnw
└── pom.xml
```

## Roadmap

O desenvolvimento está organizado em fases:

1. Infraestrutura — Docker, PostgreSQL, migrations e documentação de execução.
2. Arquitetura e padrões — monólito modular, organização por domínio, DTOs, serviços, validações e tratamento de erros.
3. Identidade e segurança — usuários, autenticação, JWT, refresh tokens e autorização.
4. Multi-tenancy e estabelecimentos — isolamento por schema e associação de usuários.
5. Cadastros e gerenciamento — estabelecimentos, profissionais, clientes e serviços.
6. Disponibilidade e horários — expediente, intervalos, exceções e bloqueios.
7. Agendamentos — criação, consulta, cancelamento, reagendamento e concorrência.
8. Eventos e notificações — eventos de domínio, Transactional Outbox e notificações.
9. Administração e indicadores — dashboards e métricas por estabelecimento.
10. Qualidade e testes — testes unitários, integração, isolamento e concorrência.
11. Documentação e entrega — OpenAPI, CI/CD, deploy e observabilidade.

As fases e entregas são acompanhadas no roadmap do projeto e devem ser atualizadas conforme as validações forem concluídas.

## Convenções de desenvolvimento

- Java 21 como versão da linguagem.
- Migrations Flyway para alterações de schema.
- UUID como estratégia de identificadores.
- Valores monetários representados por `BigDecimal` quando o domínio financeiro for implementado.
- Segredos e credenciais mantidos fora do Git.
- Testes automatizados junto com cada funcionalidade.
- Commits seguindo Conventional Commits.

## Segurança e contribuição

Não publique `.env`, senhas, tokens ou credenciais em commits, issues ou logs. Para contribuir, crie uma branch específica para a alteração, implemente os testes correspondentes e execute `./mvnw -B clean verify` antes de abrir um pull request.

---

**Slotly** — agendamentos mais simples, organizados e inteligentes.
