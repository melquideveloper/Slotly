
package com.slotly.sapl_agendamento.health;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;

@SpringBootTest
@ActiveProfiles("test")
class HealthControllerTest {

    @Autowired
    private HealthController healthController;

    @Test
    void shouldReturnUpWhenDatabaseIsAvailable() {

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
