-- =========================================================
-- 06_queries.sql
-- Consultas complejas (reportes) requeridas por la rúbrica
-- =========================================================
USE RestauranteDB;

-- Q1) Top 5 productos más vendidos (por cantidad)
SELECT
  p.ProductoID,
  p.Nombre,
  SUM(d.Cantidad) AS UnidadesVendidas
FROM DetallePedido d
JOIN Producto p ON p.ProductoID = d.ProductoID
JOIN Pedido pe ON pe.PedidoID = d.PedidoID
WHERE pe.Estado IN ('PAGADO','CREADO')
GROUP BY p.ProductoID, p.Nombre
ORDER BY UnidadesVendidas DESC
LIMIT 5;

-- Q2) Ingresos por mes (solo pedidos pagados)
SELECT
  DATE_FORMAT(pe.Fecha, '%Y-%m') AS AnioMes,
  SUM(pe.Total) AS Ingresos
FROM Pedido pe
WHERE pe.Estado = 'PAGADO'
GROUP BY DATE_FORMAT(pe.Fecha, '%Y-%m')
ORDER BY AnioMes;

-- Q3) Clientes que nunca han hecho pedidos
SELECT
  cl.ClienteID,
  cl.Nombre,
  cl.Email
FROM Cliente cl
LEFT JOIN Pedido pe ON pe.ClienteID = cl.ClienteID
WHERE pe.PedidoID IS NULL
ORDER BY cl.ClienteID;

-- Q4) Productos nunca vendidos
SELECT
  p.ProductoID,
  p.Nombre,
  p.Stock
FROM Producto p
LEFT JOIN DetallePedido d ON d.ProductoID = p.ProductoID
WHERE d.ProductoID IS NULL
ORDER BY p.ProductoID;

-- Q5) Ticket promedio por cliente (promedio de total de pedidos pagados)
SELECT
  cl.ClienteID,
  cl.Nombre,
  AVG(pe.Total) AS TicketPromedio
FROM Cliente cl
JOIN Pedido pe ON pe.ClienteID = cl.ClienteID
WHERE pe.Estado = 'PAGADO'
GROUP BY cl.ClienteID, cl.Nombre
ORDER BY TicketPromedio DESC;
