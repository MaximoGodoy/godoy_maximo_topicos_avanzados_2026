--1) Crea un índice compuesto en la tabla DetallesPedidos para las columnas PedidoID y ProductoID.
-- Luego, escribe una consulta que use este índice y analiza su plan de ejecución.

CREATE INDEX idx_detalles_pedido_producto ON DetallesPedidos(PedidoID, ProductoID);

EXPLAIN PLAN FOR
SELECT * FROM DetallesPedidos
WHERE PedidoID = 108 AND ProductoID = 1;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

--Consulta
SELECT * FROM DetallesPedidos WHERE PedidoID = 108 AND ProductoID = 1;


-- 2) Crea una tabla Ventas particionada por hash usando la columna ClienteID (4 particiones).
-- Inserta datos de Pedidos y escribe una consulta que muestre el total de ventas por cliente, verificando que las particiones se usen.

CREATE TABLE Ventas (VentaID NUMBER PRIMARY KEY, ClienteID NUMBER, Total NUMBER, FechaVenta DATE)

PARTITION BY HASH (ClienteID)
PARTITIONS 4;

INSERT INTO Ventas (VentaID, ClienteID, Total, FechaVenta)
SELECT PedidoID, ClienteID, Total, FechaPedido FROM Pedidos;

EXPLAIN PLAN FOR
SELECT ClienteID, SUM(Total) AS TotalVentas
FROM Ventas
GROUP BY ClienteID;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

--Consulta
SELECT ClienteID, SUM(Total) AS TotalVentas FROM Ventas GROUP BY ClienteID;






