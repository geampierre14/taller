-- =========================================================
-- 07_users.sql
-- Usuario y permisos (opcional, pero ayuda para evidencia)
-- =========================================================
-- Ejecuta esto con un usuario administrador (root)

CREATE USER IF NOT EXISTS 'appuser'@'localhost' IDENTIFIED BY 'App12345!';
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON RestauranteDB.* TO 'appuser'@'localhost';
FLUSH PRIVILEGES;
