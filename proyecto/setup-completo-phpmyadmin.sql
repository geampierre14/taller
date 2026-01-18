-- =========================================================
-- SCRIPT COMPLETO PARA PHPMYADMIN
-- RestauranteDB - Ejecutar todo este archivo en phpMyAdmin
-- =========================================================
-- INSTRUCCIONES:
-- 1. Abre XAMPP Control Panel
-- 2. Inicia MySQL
-- 3. Haz clic en "Admin" de MySQL (abre phpMyAdmin)
-- 4. Ve a la pestaña "SQL"
-- 5. Copia y pega TODO este archivo
-- 6. Haz clic en "Ejecutar"
-- =========================================================

-- =========================================================
-- 01. SCHEMA - Crear base de datos y tablas
-- =========================================================

DROP DATABASE IF EXISTS RestauranteDB;
CREATE DATABASE RestauranteDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE RestauranteDB;

-- Tabla Cliente (se usa en login/register)
CREATE TABLE Cliente (
  ClienteID INT AUTO_INCREMENT PRIMARY KEY,
  Nombre VARCHAR(100) NOT NULL,
  Email VARCHAR(120) NOT NULL,
  PasswordHash VARCHAR(255) NULL,
  Telefono VARCHAR(25) NULL,
  FechaRegistro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_cliente_email UNIQUE (Email)
);

-- Tabla Categoria
CREATE TABLE Categoria (
  CategoriaID INT AUTO_INCREMENT PRIMARY KEY,
  Nombre VARCHAR(80) NOT NULL,
  CONSTRAINT uq_categoria_nombre UNIQUE (Nombre)
);

-- Tabla Producto
CREATE TABLE Producto (
  ProductoID INT AUTO_INCREMENT PRIMARY KEY,
  Nombre VARCHAR(120) NOT NULL,
  Precio DECIMAL(10,2) NOT NULL,
  Stock INT NOT NULL DEFAULT 0,
  CategoriaID INT NOT NULL,
  Imagen VARCHAR(255) NULL,
  Activo TINYINT(1) NOT NULL DEFAULT 1,
  FechaCreacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_producto_categoria FOREIGN KEY (CategoriaID)
    REFERENCES Categoria(CategoriaID)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

-- Tabla Pedido
CREATE TABLE Pedido (
  PedidoID INT AUTO_INCREMENT PRIMARY KEY,
  ClienteID INT NOT NULL,
  Fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  Estado ENUM('CREADO','PAGADO','CANCELADO') NOT NULL DEFAULT 'CREADO',
  Total DECIMAL(10,2) NOT NULL DEFAULT 0,
  CONSTRAINT fk_pedido_cliente FOREIGN KEY (ClienteID)
    REFERENCES Cliente(ClienteID)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

-- Tabla DetallePedido
CREATE TABLE DetallePedido (
  PedidoID INT NOT NULL,
  ProductoID INT NOT NULL,
  Cantidad INT NOT NULL,
  PrecioUnitario DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (PedidoID, ProductoID),
  CONSTRAINT fk_detalle_pedido FOREIGN KEY (PedidoID)
    REFERENCES Pedido(PedidoID)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT fk_detalle_producto FOREIGN KEY (ProductoID)
    REFERENCES Producto(ProductoID)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

-- Auditoría
CREATE TABLE AuditoriaProducto (
  AuditoriaID INT AUTO_INCREMENT PRIMARY KEY,
  ProductoID INT NOT NULL,
  Accion VARCHAR(20) NOT NULL,
  Fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  Usuario VARCHAR(100) NULL,
  Detalle VARCHAR(255) NULL
);

-- Índices
CREATE INDEX idx_producto_categoria ON Producto (CategoriaID);
CREATE INDEX idx_pedido_cliente_fecha ON Pedido (ClienteID, Fecha);
CREATE INDEX idx_detalle_producto ON DetallePedido (ProductoID);

-- =========================================================
-- 02. INSERTS - Datos de ejemplo
-- =========================================================

-- Categorías base
INSERT INTO Categoria (Nombre) VALUES
 ('Desayunos'),
 ('Almuerzos'),
 ('Bebidas');

-- Clientes de ejemplo
INSERT INTO Cliente (Nombre, Email, Telefono) VALUES
 ('Admin', 'admin@correo.com', '0999999999'),
 ('Juan Perez', 'juan@correo.com', '0988888888');

-- Productos (IDs 1..24) con imágenes
INSERT INTO Producto (Nombre, Precio, Stock, CategoriaID, Imagen) VALUES
 ('Sanduche de Jamón', 2.50, 30, 1, 'img/image1.jpg'),
 ('Tostada con Queso', 1.75, 25, 1, 'img/image2.jpg'),
 ('Ensalada de Frutas', 2.20, 20, 1, 'img/image3.jpg'),
 ('Café Americano', 1.20, 50, 3, 'img/image4.jpg'),
 ('Café con Leche', 1.50, 45, 3, 'img/image5.jpg'),
 ('Jugo de Naranja', 1.80, 35, 3, 'img/image6.jpg'),
 ('Yogurt con Granola', 2.40, 15, 1, 'img/image7.jpg'),
 ('Huevos Revueltos', 2.80, 18, 1, 'img/image8.jpg'),
 ('Pan de Ajo', 1.60, 22, 1, 'img/image9.jpg'),
 ('Arroz con Pollo', 4.50, 20, 2, 'img/image10.jpg'),
 ('Seco de Carne', 5.25, 15, 2, 'img/image11.jpg'),
 ('Menestra con Carne', 4.80, 18, 2, 'img/image12.jpg'),
 ('Pasta Boloñesa', 4.90, 16, 2, 'img/image13.jpg'),
 ('Pollo a la Plancha', 5.10, 14, 2, 'img/image14.jpg'),
 ('Encebollado', 4.25, 20, 2, 'img/image15.jpg'),
 ('Ceviche', 4.75, 12, 2, 'img/image17.jpg'),
 ('Sopa de Lentejas', 3.60, 20, 2, 'img/image18.jpg'),
 ('Arroz Marinero', 5.90, 10, 2, 'img/image19.jpg'),
 ('Cola', 1.25, 60, 3, 'img/image20.jpg'),
 ('Agua', 1.00, 80, 3, 'img/image21.jpg'),
 ('Té Helado', 1.50, 40, 3, 'img/image22.jpg'),
 ('Limonada', 1.40, 45, 3, 'img/image23.jpg'),
 ('Batido de Fresa', 2.10, 25, 3, 'img/image24.jpg'),
 ('Batido de Mora', 2.10, 25, 3, 'img/image25.jpg');

-- =========================================================
-- 03. PROCEDURES - Procedimientos almacenados
-- =========================================================

DELIMITER $$

CREATE PROCEDURE sp_insertar_producto(
  IN p_nombre VARCHAR(120),
  IN p_precio DECIMAL(10,2),
  IN p_stock INT,
  IN p_categoriaId INT
)
BEGIN
  IF p_precio <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Precio debe ser mayor a 0';
  END IF;
  IF p_stock < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock no puede ser negativo';
  END IF;

  INSERT INTO Producto (Nombre, Precio, Stock, CategoriaID)
  VALUES (p_nombre, p_precio, p_stock, p_categoriaId);
END$$

CREATE PROCEDURE sp_ajustar_stock(
  IN p_productoId INT,
  IN p_delta INT
)
BEGIN
  DECLARE v_stock INT;

  START TRANSACTION;

  SELECT Stock INTO v_stock
  FROM Producto
  WHERE ProductoID = p_productoId
  FOR UPDATE;

  IF v_stock IS NULL THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Producto no existe';
  END IF;

  IF v_stock + p_delta < 0 THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente';
  END IF;

  UPDATE Producto
  SET Stock = Stock + p_delta
  WHERE ProductoID = p_productoId;

  COMMIT;
END$$

CREATE PROCEDURE sp_crear_pedido(
  IN p_clienteId INT,
  IN p_productoId INT,
  IN p_cantidad INT
)
BEGIN
  DECLARE v_precio DECIMAL(10,2);
  DECLARE v_pedidoId INT;
  DECLARE v_stock INT;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  IF p_cantidad <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cantidad debe ser > 0';
  END IF;

  START TRANSACTION;

  SELECT Precio, Stock INTO v_precio, v_stock
  FROM Producto
  WHERE ProductoID = p_productoId
  FOR UPDATE;

  IF v_precio IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Producto no existe';
  END IF;
  IF v_stock < p_cantidad THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente para el pedido';
  END IF;

  INSERT INTO Pedido (ClienteID, Estado, Total)
  VALUES (p_clienteId, 'CREADO', 0);

  SET v_pedidoId = LAST_INSERT_ID();

  INSERT INTO DetallePedido (PedidoID, ProductoID, Cantidad, PrecioUnitario)
  VALUES (v_pedidoId, p_productoId, p_cantidad, v_precio);

  UPDATE Pedido
  SET Total = (SELECT SUM(Cantidad * PrecioUnitario) FROM DetallePedido WHERE PedidoID = v_pedidoId)
  WHERE PedidoID = v_pedidoId;

  COMMIT;
END$$

DELIMITER ;

-- =========================================================
-- 04. TRIGGERS
-- =========================================================

DELIMITER $$

CREATE TRIGGER trg_producto_bi_validar
BEFORE INSERT ON Producto
FOR EACH ROW
BEGIN
  IF NEW.Precio <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Precio inválido';
  END IF;
  IF NEW.Stock < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock inválido';
  END IF;
END$$

CREATE TRIGGER trg_producto_ai_auditoria
AFTER INSERT ON Producto
FOR EACH ROW
BEGIN
  INSERT INTO AuditoriaProducto (ProductoID, Accion, Detalle)
  VALUES (NEW.ProductoID, 'INSERT', CONCAT('Creado: ', NEW.Nombre));
END$$

CREATE TRIGGER trg_detalle_bi_validar_stock
BEFORE INSERT ON DetallePedido
FOR EACH ROW
BEGIN
  DECLARE v_stock INT;
  SELECT Stock INTO v_stock FROM Producto WHERE ProductoID = NEW.ProductoID;
  IF v_stock IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Producto no existe';
  END IF;
  IF NEW.Cantidad <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cantidad inválida';
  END IF;
  IF v_stock < NEW.Cantidad THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente';
  END IF;
END$$

CREATE TRIGGER trg_detalle_ai_descuento_stock
AFTER INSERT ON DetallePedido
FOR EACH ROW
BEGIN
  UPDATE Producto
  SET Stock = Stock - NEW.Cantidad
  WHERE ProductoID = NEW.ProductoID;
END$$

DELIMITER ;

-- =========================================================
-- 05. VIEWS - Vistas
-- =========================================================

CREATE OR REPLACE VIEW v_productos_con_categoria AS
SELECT
  p.ProductoID,
  p.Nombre       AS Producto,
  c.Nombre       AS Categoria,
  p.Precio,
  p.Stock,
  p.Activo,
  p.FechaCreacion
FROM Producto p
JOIN Categoria c ON c.CategoriaID = p.CategoriaID;

CREATE OR REPLACE VIEW v_pedidos_resumen AS
SELECT
  pe.PedidoID,
  pe.Fecha,
  pe.Estado,
  pe.Total,
  cl.ClienteID,
  cl.Nombre AS Cliente,
  cl.Email  AS Email
FROM Pedido pe
JOIN Cliente cl ON cl.ClienteID = pe.ClienteID;

CREATE OR REPLACE VIEW v_total_gastado_cliente AS
SELECT
  cl.ClienteID,
  cl.Nombre,
  cl.Email,
  COALESCE(SUM(CASE WHEN pe.Estado = 'PAGADO' THEN pe.Total ELSE 0 END), 0) AS TotalGastado
FROM Cliente cl
LEFT JOIN Pedido pe ON pe.ClienteID = cl.ClienteID
GROUP BY cl.ClienteID, cl.Nombre, cl.Email;

CREATE OR REPLACE VIEW v_productos_stock_bajo AS
SELECT
  p.ProductoID,
  p.Nombre,
  p.Stock,
  c.Nombre AS Categoria
FROM Producto p
JOIN Categoria c ON c.CategoriaID = p.CategoriaID
WHERE p.Stock <= 5 AND p.Activo = 1;

-- =========================================================
-- 07. USERS - Crear usuario para la aplicación
-- =========================================================

CREATE USER IF NOT EXISTS 'appuser'@'localhost' IDENTIFIED BY 'App12345!';
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON RestauranteDB.* TO 'appuser'@'localhost';
FLUSH PRIVILEGES;

-- =========================================================
-- ¡LISTO! Base de datos configurada completamente
-- =========================================================
-- Ahora puedes cerrar phpMyAdmin e iniciar el servidor:
-- npm run dev
-- =========================================================
