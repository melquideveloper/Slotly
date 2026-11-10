package com.slotly.sapl_agendamento.controller;

import org.junit.jupiter.api.Test;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;

class HealthControllerTest {

    private final HealthController controller = new HealthController();

    @Test
    void shouldReturnApplicationNameAndUpStatus() {

        Map<String, String> response = controller.health();

        assertEquals("Slotly", response.get("application"));
        assertEquals("UP", response.get("status"));
    }
}
