USE RestauranteDB;

SELECT ClienteID, Nombre, Email
FROM Cliente;
USE RestauranteDB;
SELECT ClienteID, Nombre, Email FROM Cliente;
CREATE USER 'appuser'@'localhost' IDENTIFIED BY 'App12345!';
GRANT ALL PRIVILEGES ON RestauranteDB.* TO 'appuser'@'localhost';
FLUSH PRIVILEGES;
