
# Slotly — Convenções de nomenclatura

**Versão:** 1.0  
**Status:** Definido  
**Fase:** 2 — Arquitetura e padrões

## 1. Objetivo

Estabelecer um padrão consistente de nomenclatura
para todo o código-fonte do Slotly.

As convenções devem facilitar leitura, manutenção,
identificação de responsabilidades e colaboração
entre desenvolvedores.

## 2. Pacotes Java

Utilizar exclusivamente letras minúsculas.

Não utilizar espaços, hífens ou letras maiúsculas.

Exemplos:

- identity
- organization
- customer
- professional
- catalog
- availability
- appointment
- notification
- config
- shared

O pacote raiz existente será preservado.

## 3. Classes Java

Utilizar PascalCase, com nomes descritivos.

Exemplos:

- Appointment
- AppointmentService
- AppointmentController
- AppointmentRepository
- CreateAppointmentRequest
- AppointmentResponse
- AppointmentNotFoundException

Evitar abreviações desnecessárias.

## 4. Interfaces

Utilizar PascalCase.

O nome deverá representar claramente
a responsabilidade da interface.

Não utilizar prefixos como I.

Exemplos:

- PaymentGateway
- NotificationSender

Interfaces somente serão criadas quando
existir uma justificativa técnica.

## 5. Métodos

Utilizar camelCase.

Os nomes devem representar ações ou comportamentos.

Exemplos:

- createAppointment()
- findAppointmentById()
- cancelAppointment()
- calculateAvailability()
- validateMembership()

Preferir verbos que expressem claramente
a intenção do método.

## 6. Variáveis e atributos

Utilizar camelCase.

Exemplos:

- appointmentId
- customerName
- startDateTime
- serviceDuration
- organizationId

Evitar nomes genéricos como:

- data
- object
- value
- temp

Quando houver um nome mais específico disponível.

## 7. Constantes

Utilizar letras maiúsculas e separar palavras
com underscore.

Exemplos:

- MAX_APPOINTMENTS_PER_DAY
- DEFAULT_APPOINTMENT_DURATION
- TOKEN_EXPIRATION_TIME

Constantes deverão utilizar final.

## 8. Entidades JPA

Utilizar nomes no singular e PascalCase.

Exemplos:

- User
- Organization
- Membership
- Customer
- Professional
- Service
- Appointment

Os nomes deverão representar conceitos do domínio.

## 9. Repositórios

Utilizar o sufixo Repository.

Exemplos:

- UserRepository
- OrganizationRepository
- AppointmentRepository

Os repositórios deverão representar
o acesso e a persistência das entidades.

## 10. Serviços

Utilizar o sufixo Service.

Exemplos:

- UserService
- OrganizationService
- AppointmentService
- AvailabilityService

Os serviços deverão representar operações
e regras de negócio.

## 11. Controllers

Utilizar o sufixo Controller.

Exemplos:

- UserController
- OrganizationController
- AppointmentController

Os controllers deverão ser responsáveis
pela exposição dos endpoints HTTP.

## 12. DTOs

Utilizar nomes que indiquem claramente
a finalidade do objeto.

Para requisições:

- CreateAppointmentRequest
- UpdateAppointmentRequest
- LoginRequest
- RegisterUserRequest

Para respostas:

- AppointmentResponse
- UserResponse
- OrganizationResponse
- AuthResponse

Evitar nomes genéricos como:

- AppointmentDTO
- UserDTO
- GenericResponse

## 13. Exceções

Utilizar nomes descritivos com o sufixo Exception.

Exemplos:

- AppointmentNotFoundException
- OrganizationNotFoundException
- InvalidCredentialsException
- DuplicateAppointmentException

## 14. Configurações

Utilizar o sufixo Config para classes
de configuração do Spring.

Exemplos:

- CorsConfig
- SecurityConfig
- JacksonConfig
- JpaConfig

## 15. Testes

Os testes deverão acompanhar a estrutura
de pacotes do código principal.

Testes unitários e testes de integração:

- AppointmentServiceTest
- AppointmentControllerTest
- AppointmentRepositoryTest

Testes de integração identificados para
execução pelo Maven Failsafe:

- AppointmentIntegrationIT
- AppointmentPostgresIT

Os nomes deverão permitir identificar
facilmente a classe ou funcionalidade testada.

## 16. Banco de dados

Utilizar snake_case para tabelas e colunas.

Preferir nomes de tabelas no plural.

Exemplos de tabelas:

- users
- organizations
- memberships
- appointments
- customers
- professionals

Exemplos de colunas:

- created_at
- updated_at
- organization_id
- start_date_time
- appointment_status

### Constraints e índices

Utilizar prefixos padronizados:

- pk_ — Primary Key
- fk_ — Foreign Key
- uk_ — Unique Key
- idx_ — Index
- ck_ — Check Constraint

Exemplos:

- pk_appointments
- fk_appointments_customers
- uk_users_email
- idx_appointments_start_date_time
- ck_appointments_status

## 17. Migrations Flyway

Seguir o padrão:

V{versão}__{descricao_em_snake_case}.sql

Exemplos:

- V1__create_initial_schema.sql
- V2__restrict_flyway_history_access.sql
- V3__create_appointments_table.sql
- V4__create_customers_table.sql

As migrations já executadas não deverão
ser modificadas.

Novas alterações deverão ser adicionadas
em arquivos versionados.

## 18. Endpoints REST

Utilizar substantivos no plural e kebab-case
quando houver nomes compostos.

Exemplos:

- /api/users
- /api/organizations
- /api/appointments
- /api/appointment-services

Utilizar métodos HTTP conforme a operação:

- GET: consulta
- POST: criação
- PUT: atualização completa
- PATCH: atualização parcial
- DELETE: remoção

## 19. Idioma

O código-fonte deverá utilizar inglês para:

- Classes
- Métodos
- Variáveis
- Pacotes
- Entidades
- DTOs
- Endpoints
- Migrations

Comentários e documentação poderão utilizar
português quando isso facilitar a compreensão
da equipe.

## 20. Diretriz geral

A nomenclatura deverá priorizar clareza,
consistência e significado de negócio.

Não criar abstrações ou nomenclaturas
desnecessariamente complexas.

Estas convenções serão aplicadas progressivamente
aos novos módulos e às alterações realizadas
no código existente.
