-- =========================================================
-- 04_triggers.sql
-- Al menos 4 triggers funcionales (validación/auditoría/integridad)
-- =========================================================
USE RestauranteDB;

DELIMITER $$

-- 1) Validar precio y stock en Producto
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

-- 2) Auditoría al crear producto
CREATE TRIGGER trg_producto_ai_auditoria
AFTER INSERT ON Producto
FOR EACH ROW
BEGIN
  INSERT INTO AuditoriaProducto (ProductoID, Accion, Detalle)
  VALUES (NEW.ProductoID, 'INSERT', CONCAT('Creado: ', NEW.Nombre));
END$$

-- 3) Validar stock suficiente antes de agregar detalle
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

-- 4) Descontar stock cuando se agrega detalle
CREATE TRIGGER trg_detalle_ai_descuento_stock
AFTER INSERT ON DetallePedido
FOR EACH ROW
BEGIN
  UPDATE Producto
  SET Stock = Stock - NEW.Cantidad
  WHERE ProductoID = NEW.ProductoID;
END$$

DELIMITER ;
