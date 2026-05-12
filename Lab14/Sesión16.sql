--1) Analiza el plan de ejecución de la siguiente consulta y optimízala para que use índices y particiones.

EXPLAIN PLAN FOR
SELECT c.Nombre, COUNT(p.PedidoID) AS TotalPedidos
FROM Clientes c, Pedidos p
WHERE c.ClienteID = p.ClienteID
AND c.Ciudad = 'Santiago'
AND p.FechaPedido >= TO_DATE('2025-03-01', 'YYYY-MM-DD')
GROUP BY c.Nombre;

CREATE INDEX idx_clientes_ciudad ON Clientes(Ciudad);
EXPLAIN PLAN FOR
SELECT /*+ INDEX(c idx_clientes_ciudad) INDEX(p idx_pedidos_cld_fecha) */
    c.Nombre, COUNT(p.PedidoID) AS TotalPedidos FROM Clientes c JOIN Pedidos p ON c.ClienteID = p.ClienteID WHERE c.Ciudad = 'Santiago'
AND p.FechaPedido >= TO_DATE('2025-03-01', 'YYYY-MM-DD')
GROUP BY c.Nombre;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

--Consulta
SELECT c.Nombre, COUNT(p.PedidoID) AS TotalPedidos FROM Clientes c JOIN Pedidos p ON c.ClienteID = p.ClienteID WHERE c.Ciudad = 'Santiago' AND p.FechaPedido >= TO_DATE('2025-03-01', 'YYYY-MM-DD')
GROUP BY c.Nombre;

-- 2) Optimiza la siguiente consulta para evitar un FULL TABLE SCAN en DetallesPedidos y analiza el plan de ejecución antes y después de la optimización.

EXPLAIN PLAN FOR
SELECT p.Nombre, SUM(dp.Cantidad * p.Precio) AS TotalVentas
FROM Productos p, DetallesPedidos dp
WHERE p.ProductoID = dp.ProductoID
GROUP BY p.Nombre;

EXPLAIN PLAN FOR
SELECT /*+ INDEX(dp idx_detalles_productoid) */
   	p.Nombre, SUM(dp.Cantidad * p.Precio) AS TotalVentas FROM Productos p JOIN DetallesPedidos dp ON p.ProductoID = dp.ProductoID GROUP BY p.Nombre;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

--Consulta
SELECT p.Nombre, SUM(dp.Cantidad * p.Precio) AS TotalVentas FROM Productos p JOIN DetallesPedidos dp ON p.ProductoID = dp.ProductoID GROUP BY p.Nombre;
