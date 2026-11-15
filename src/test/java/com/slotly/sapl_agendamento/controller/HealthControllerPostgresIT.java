
package com.slotly.sapl_agendamento.controller;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;

import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;

@SpringBootTest
@ActiveProfiles("test")
@Testcontainers
class HealthControllerPostgresIT {

    @Container
    static final PostgreSQLContainer<?> postgres =
            new PostgreSQLContainer<>("postgres:17-alpine")
                    .withDatabaseName("slotly_test")
                    .withUsername("slotly_test")
                    .withPassword("slotly_test_password")
                    .withInitScript("db/test/init-roles.sql");

    @DynamicPropertySource
    static void configureDatabase(DynamicPropertyRegistry registry) {

        registry.add(
                "DB_URL",
                postgres::getJdbcUrl
        );

        registry.add(
                "DB_USERNAME",
                postgres::getUsername
        );

        registry.add(
                "DB_PASSWORD",
                postgres::getPassword
        );

        registry.add(
                "spring.flyway.enabled",
                () -> true
        );
    }

    @Autowired
    private HealthController healthController;

    @Test
    void shouldReturnUpWhenPostgresIsAvailable() {

        ResponseEntity<Map<String, String>> response =
                healthController.health();

        assertEquals(HttpStatus.OK, response.getStatusCode());

        assertEquals(
                "Slotly",
                response.getBody().get("application")
        );

        assertEquals(
                "UP",
                response.getBody().get("status")
        );

        assertEquals(
                "UP",
                response.getBody().get("database")
        );
    }
}
