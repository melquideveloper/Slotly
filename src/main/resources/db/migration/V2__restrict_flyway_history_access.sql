
-- Prevent the runtime application from accessing Flyway metadata.
-- The migrator remains the owner and retains its migration privileges.

REVOKE ALL PRIVILEGES
ON TABLE public.flyway_schema_history
FROM slotly_app;
