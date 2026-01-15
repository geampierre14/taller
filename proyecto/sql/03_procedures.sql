-- =========================================================
-- 03_procedures.sql
-- Procedimientos almacenados con parámetros, transacciones,
-- control de errores y bloqueo.
-- =========================================================
USE RestauranteDB;

DELIMITER $$

-- 1) Inserta producto (lo puedes llamar desde MySQL Workbench)
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

-- 2) Actualiza stock con bloqueo (SELECT ... FOR UPDATE)
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

-- 3) Crear pedido con detalle (transacción + handler)
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

  -- bloquear producto para evitar carreras
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

  -- el trigger AFTER INSERT de DetallePedido descuenta stock
  UPDATE Pedido
  SET Total = (SELECT SUM(Cantidad * PrecioUnitario) FROM DetallePedido WHERE PedidoID = v_pedidoId)
  WHERE PedidoID = v_pedidoId;

  COMMIT;
END$$

DELIMITER ;
