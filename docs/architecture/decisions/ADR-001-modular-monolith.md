
# ADR-001 — Arquitetura de Monólito Modular

- **Status:** Aceita
- **Data:** 18/11/2026
- **Projeto:** Slotly
- **Versão:** 1.0

## 1. Contexto

O Slotly é uma plataforma de gerenciamento de agendamentos
destinada a pequenos negócios, como barbearias, clínicas,
salões de beleza e profissionais autônomos.

A aplicação precisa oferecer organização, manutenibilidade,
segurança e capacidade de evolução, sem introduzir
complexidade arquitetural desnecessária.

O projeto utilizará uma arquitetura de monólito modular,
com responsabilidades organizadas por domínio.

## 2. Decisão arquitetural

Adotar uma arquitetura de monólito modular utilizando
Spring Boot.

A aplicação será executada como um único serviço,
com uma única inicialização Spring e uma única unidade
principal de implantação.

Os módulos serão organizados por responsabilidade
de negócio, mas poderão colaborar diretamente por meio
de classes Java e injeção de dependência do Spring.

Não serão criadas APIs HTTP internas para comunicação
entre módulos.

Também não será exigida uma estrutura de contratos
públicos ou interfaces para todas as dependências
entre módulos.

A arquitetura deverá priorizar simplicidade,
clareza e baixo acoplamento.

## 3. Organização por domínio

Os pacotes serão organizados de acordo com os domínios
funcionais da aplicação.

Domínios previstos:

- identity: identidade, autenticação e usuários.
- organization: estabelecimentos e organizações.
- customer: clientes e seus relacionamentos.
- professional: profissionais.
- catalog: serviços e preços.
- availability: disponibilidade e horários.
- appointment: agendamentos.
- notification: notificações e processamento de eventos.
- shared: componentes realmente compartilhados.

A organização definitiva será implementada na entrega 2.2.

## 4. Separação de responsabilidades

Cada domínio deverá manter suas responsabilidades
bem definidas.

Quando necessário, poderão existir separações internas
entre:

- controller: entrada e exposição dos endpoints HTTP.
- service: execução das regras e casos de uso.
- repository: acesso e persistência de dados.
- entity: representação das entidades persistidas.
- dto: objetos utilizados na comunicação da API.

Essa separação não deverá ser aplicada mecanicamente
quando não houver necessidade.

Não serão criadas interfaces, abstrações ou camadas
adicionais sem justificativa técnica.

## 5. Comunicação entre domínios

A comunicação entre os domínios ocorrerá por chamadas
Java convencionais.

A injeção de dependência será realizada pelo Spring,
preferencialmente utilizando injeção por construtor.

Exemplo conceitual:

AppointmentService
    -> AvailabilityService

A comunicação não utilizará HTTP, REST ou mensageria
para chamadas internas da aplicação.

As dependências deverão ser claras e evitar ciclos
entre serviços.

## 6. Persistência e banco de dados

O PostgreSQL será utilizado como banco principal.

O Spring Data JPA e o Hibernate serão responsáveis
pelo mapeamento objeto-relacional.

O Flyway será utilizado para versionamento e execução
das migrations.

As alterações estruturais do banco deverão ser
realizadas por migrations versionadas.

O Hibernate não deverá modificar automaticamente
a estrutura do banco em produção.

A estratégia de multi-tenancy definida no roadmap
será preservada:

- Schema global compartilhado.
- Schema isolado por estabelecimento.

## 7. Eventos e processamento assíncrono

Eventos serão utilizados quando houver necessidade
de desacoplamento temporal ou processamento assíncrono.

Na Fase 8, serão avaliados:

- Spring Events.
- Transactional Outbox.
- Processamento assíncrono.
- Idempotência.
- Kafka ou RabbitMQ.

A introdução de mensageria dependerá de uma necessidade
real do produto.

## 8. Evolução para microsserviços

O projeto não será dividido em microsserviços
nesta etapa.

A possibilidade de extração futura será considerada
principalmente para o domínio de notificações.

Essa avaliação ocorrerá na Fase 8, considerando
benefícios operacionais e técnicos.

Uma eventual extração deverá ser justificada por
necessidade real de escalabilidade, independência
de implantação ou isolamento operacional.

## 9. Testabilidade

Os componentes deverão ser desenvolvidos considerando
testabilidade desde o início.

Serão utilizados:

- JUnit 5.
- Mockito.
- Spring Boot Test.
- MockMvc.
- Testcontainers.
- PostgreSQL para testes de integração.

As regras de negócio deverão ser testáveis
independentemente da camada HTTP.

## 10. Princípios de desenvolvimento

O desenvolvimento deverá observar:

- Simplicidade antes de abstrações desnecessárias.
- Responsabilidades bem definidas.
- Baixo acoplamento.
- Alta coesão.
- Injeção de dependência por construtor.
- Código legível e sustentável.
- Validação de entradas.
- Tratamento consistente de exceções.
- Testes automatizados.
- Segurança por padrão.

## 11. Consequências da decisão

### Benefícios

- Menor complexidade operacional.
- Facilidade de desenvolvimento e manutenção.
- Implantação simplificada.
- Comunicação interna eficiente.
- Facilidade de testes.
- Possibilidade de evolução gradual.

### Limitações

- Os domínios compartilham o mesmo processo.
- Uma falha crítica pode afetar toda a aplicação.
- Os módulos não possuem implantação independente.
- A escalabilidade inicial ocorre principalmente
  pela aplicação como um todo.

Essas limitações são aceitáveis para o estágio atual
do Slotly.

## 12. Revisão da decisão

Esta decisão poderá ser revisada quando surgirem
necessidades concretas de escalabilidade, isolamento
ou independência operacional.

Qualquer mudança arquitetural relevante deverá
ser documentada por meio de um novo ADR.
