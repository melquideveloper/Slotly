
# ==========================================
# Stage 1: Build
# ==========================================
FROM eclipse-temurin:21-jdk AS build

WORKDIR /workspace

# Copia arquivos necessários para o Maven Wrapper
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./

RUN chmod +x mvnw

# Copia o código-fonte
COPY src/ src/

# Compila e empacota a aplicação
RUN ./mvnw -B clean package -DskipTests

# ==========================================
# Stage 2: Runtime
# ==========================================
FROM eclipse-temurin:21-jre

WORKDIR /app

# Cria usuário sem privilégios administrativos
RUN groupadd --system spring && \
    useradd --system --gid spring spring

# Copia o JAR gerado no estágio de build
COPY --from=build /workspace/target/*.jar app.jar

# Executa com usuário não privilegiado
USER spring

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
