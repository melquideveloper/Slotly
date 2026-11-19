
# Slotly — Padrão de DTOs

**Versão:** 1.0  
**Status:** Definido  
**Fase:** 2 — Arquitetura e padrões

## 1. Objetivo

Definir um padrão para transferência de dados entre
a API, os serviços e as demais partes da aplicação.

Os DTOs deverão proteger as entidades de domínio,
padronizar as entradas e saídas e permitir evolução
independente da estrutura de persistência.

## 2. Tecnologia adotada

- Java 21.
- Java Records.
- Jakarta Validation.
- Spring Boot 4.x.

Não será utilizada biblioteca adicional de mapeamento
neste momento.

As conversões serão realizadas manualmente,
com métodos explícitos e objetivos.

## 3. Organização dos pacotes

Os DTOs deverão ficar organizados dentro
do respectivo domínio.

Exemplo:

appointment/
    controller/
    service/
    repository/
    entity/
    dto/
        request/
        response/

Exemplo de arquivos:

dto/request/
    CreateAppointmentRequest.java
    UpdateAppointmentRequest.java

dto/response/
    AppointmentResponse.java

A organização deverá acompanhar a evolução
dos respectivos domínios.

## 4. DTOs de entrada — Request

Os DTOs de entrada deverão representar
exclusivamente os dados aceitos pela API.

Utilizar Java Records sempre que possível.

Exemplo:

public record CreateCustomerRequest(
    @NotBlank
    @Size(max = 150)
    String name,

    @NotBlank
    @Email
    @Size(max = 254)
    String email
) {}

Regras:

- Utilizar nomes com o sufixo Request.
- Aplicar validações Jakarta Validation.
- Definir limites de tamanho.
- Validar formatos e valores obrigatórios.
- Não incluir identificadores gerados pelo servidor
  quando não forem necessários na operação.
- Não aceitar campos administrativos sem autorização.
- Não receber entidades JPA.

## 5. DTOs de saída — Response

Os DTOs de saída representarão os dados
disponibilizados pela API.

Exemplo:

public record CustomerResponse(
    UUID id,
    String name,
    String email
) {}

Regras:

- Utilizar nomes com o sufixo Response.
- Retornar somente os campos necessários.
- Não expor senhas, hashes, tokens ou informações
  internas de persistência.
- Não retornar entidades JPA.
- Evitar relacionamentos bidirecionais.
- Evitar estruturas excessivamente aninhadas.

## 6. Validação de dados

Utilizar Jakarta Validation.

Anotações disponíveis incluem:

- @NotNull
- @NotBlank
- @NotEmpty
- @Size
- @Email
- @Min
- @Max
- @Positive
- @PositiveOrZero
- @Past
- @Future
- @Pattern
- @DecimalMin
- @DecimalMax

A validação deverá ocorrer na entrada da API,
utilizando @Valid nos parâmetros dos controllers.

Exemplo:

@PostMapping
public ResponseEntity<CustomerResponse> create(
    @Valid @RequestBody CreateCustomerRequest request
) {
    // Delegação ao serviço
}

As regras de negócio deverão continuar
sendo verificadas na camada de serviço.

Validação de DTO não substitui validação de domínio.

## 7. Conversão entre DTOs e entidades

A conversão será explícita.

Responsabilidade inicial:

- Controller recebe Request.
- Service executa as regras de negócio.
- Entity representa o estado persistido.
- Response representa os dados de saída.

A conversão poderá ocorrer no serviço ou em
uma classe específica de mapeamento, conforme
a complexidade do domínio.

Não utilizar reflexão ou conversões genéricas
sem necessidade.

## 8. Atualizações e operações PATCH

Requests de criação e atualização deverão
ser separados quando possuírem regras diferentes.

Para PUT, representar os dados necessários
à atualização completa.

Para PATCH, considerar cuidadosamente
a diferença entre:

- Campo não enviado.
- Campo enviado com valor null.
- Campo enviado com valor válido.

Não utilizar um Record simples como solução
universal para atualizações parciais quando
for necessário distinguir esses estados.

## 9. Tipos de dados

Utilizar tipos adequados ao domínio.

Identificadores:
- UUID.

Valores monetários:
- BigDecimal.

Datas:
- LocalDate.

Horários:
- LocalTime.

Instantes:
- Instant.

Datas e horários com offset:
- OffsetDateTime.

Fuso horário:
- ZoneId.

Não utilizar double ou float para valores
monetários.

Datas e horários de agendamentos deverão
considerar o fuso horário do estabelecimento.

## 10. Segurança

Os DTOs deverão aplicar o princípio
de exposição mínima de informações.

Não retornar:

- Senhas.
- Hashes de senhas.
- Refresh Tokens.
- Segredos de autenticação.
- Dados internos de segurança.
- Informações desnecessárias de persistência.

Os dados recebidos deverão ser validados
e submetidos às regras de autorização.

## 11. Nomenclatura

Requests:

- CreateUserRequest
- RegisterUserRequest
- UpdateOrganizationRequest
- CreateAppointmentRequest
- RescheduleAppointmentRequest

Responses:

- UserResponse
- AuthResponse
- OrganizationResponse
- AppointmentResponse
- AvailabilityResponse

Utilizar nomes que expressem claramente
a operação e a finalidade do objeto.

## 12. Testes

Os DTOs deverão possuir testes quando
houver regras de validação relevantes.

Os testes deverão verificar:

- Campos obrigatórios.
- Formatos inválidos.
- Limites de tamanho.
- Valores negativos ou inválidos.
- Regras específicas de cada operação.

Também deverão existir testes dos endpoints
para verificar a aplicação de @Valid.

## 13. Bibliotecas de mapeamento

Não será adotado MapStruct nesta etapa.

A conversão manual será utilizada enquanto
permanecer simples e legível.

A adoção de MapStruct poderá ser avaliada
quando o volume de DTOs e mapeamentos justificar.

## 14. Diretriz geral

Os DTOs deverão representar contratos da API,
não estruturas de banco de dados.

Cada DTO deverá possuir finalidade clara,
responsabilidade específica e validações adequadas.

A implementação deverá priorizar segurança,
clareza, simplicidade e manutenção.
