-- =========================================================
-- 05_views.sql
-- 4 vistas requeridas por la rúbrica
-- =========================================================
USE RestauranteDB;

-- 1) Productos con su categoría
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

-- 2) Resumen de pedidos (cabecera) con datos del cliente
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

-- 3) Total gastado por cliente (solo pedidos pagados)
CREATE OR REPLACE VIEW v_total_gastado_cliente AS
SELECT
  cl.ClienteID,
  cl.Nombre,
  cl.Email,
  COALESCE(SUM(CASE WHEN pe.Estado = 'PAGADO' THEN pe.Total ELSE 0 END), 0) AS TotalGastado
FROM Cliente cl
LEFT JOIN Pedido pe ON pe.ClienteID = cl.ClienteID
GROUP BY cl.ClienteID, cl.Nombre, cl.Email;

-- 4) Productos con stock bajo (umbral 5)
CREATE OR REPLACE VIEW v_productos_stock_bajo AS
SELECT
  p.ProductoID,
  p.Nombre,
  p.Stock,
  c.Nombre AS Categoria
FROM Producto p
JOIN Categoria c ON c.CategoriaID = p.CategoriaID
WHERE p.Stock <= 5 AND p.Activo = 1;
