
package com.slotly.sapl_agendamento.controller;

import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api")
public class HealthController {

    private final JdbcTemplate jdbcTemplate;

    public HealthController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {

        try {
            Integer result = jdbcTemplate.queryForObject(
                    "SELECT 1",
                    Integer.class
            );

            if (result == null || result != 1) {
                return databaseUnavailable();
            }

            return ResponseEntity.ok(
                    Map.of(
                            "application", "Slotly",
                            "status", "UP",
                            "database", "UP"
                    )
            );

        } catch (DataAccessException exception) {
            return databaseUnavailable();
        }
    }

    private ResponseEntity<Map<String, String>> databaseUnavailable() {

        return ResponseEntity
                .status(HttpStatus.SERVICE_UNAVAILABLE)
                .body(
                        Map.of(
                                "application", "Slotly",
                                "status", "DOWN",
                                "database", "DOWN"
                        )
                );
    }
}
