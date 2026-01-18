-- =========================================================
-- 01_schema.sql
-- Proyecto: Ordermaster pro (RestauranteDB)
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

-- Tabla Producto (se usa en el CRUD del frontend)
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

-- Auditoría (para triggers)
CREATE TABLE AuditoriaProducto (
  AuditoriaID INT AUTO_INCREMENT PRIMARY KEY,
  ProductoID INT NOT NULL,
  Accion VARCHAR(20) NOT NULL,
  Fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  Usuario VARCHAR(100) NULL,
  Detalle VARCHAR(255) NULL
);

-- Índices (justificación: aceleran búsquedas por FK y reportes)
CREATE INDEX idx_producto_categoria ON Producto (CategoriaID);
CREATE INDEX idx_pedido_cliente_fecha ON Pedido (ClienteID, Fecha);
CREATE INDEX idx_detalle_producto ON DetallePedido (ProductoID);

