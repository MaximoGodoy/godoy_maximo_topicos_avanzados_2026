-- 1) Crea un procedimiento actualizar_total_pedidos que reciba un ClienteID (parámetro IN) y
--un porcentaje de aumento (parámetro IN con valor por defecto 10%). Aumenta el total de todos 
--los pedidos del cliente en el porcentaje especificado. Usa un bucle para iterar sobre los pedidos.

CREATE OR REPLACE PROCEDURE actualizar_total_pedidos(p_clienteID IN NUMBER, p_porcentaje IN NUMBER DEFAULT 10) AS
	CURSOR pedido_cursor IS
    	SELECT PedidoID, Total
    	FROM Pedidos
    	WHERE ClienteID = p_clienteID
    	FOR UPDATE;
BEGIN
	FOR pedido IN pedido_cursor LOOP
    	UPDATE Pedidos
    	SET Total = pedido.Total * (1 + p_porcentaje / 100)
    	WHERE CURRENT OF pedido_cursor;
    	DBMS_OUTPUT.PUT_LINE('Pedido ' || pedido.PedidoID || ': Nuevo total: ' || (pedido.Total * (1 + p_porcentaje / 100)));
	END LOOP;
	IF SQL%ROWCOUNT = 0 THEN
    	DBMS_OUTPUT.PUT_LINE('Cliente ' || p_clienteID || ' no tiene pedidos.');
	ELSE
    	COMMIT;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
    	DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    	ROLLBACK;
END;
/

-- 2) Crea un procedimiento calcular_costo_detalle que reciba un DetalleID (parámetro IN) y devuelva el costo total
--del detalle (parámetro IN OUT). El costo se calcula como Precio * Cantidad (usando las tablas DetallesPedidos
-- y Productos). Maneja excepciones si el detalle no existe.

CREATE OR REPLACE PROCEDURE calcular_costo_detalle(p_detalle_id IN NUMBER, p_costo IN OUT NUMBER
) AS
BEGIN
	SELECT (p.Precio * d.Cantidad)  
	INTO p_costo 
	FROM DetallesPedidos d
	JOIN Productos p ON d.ProductoID = p.ProductoID
	WHERE d.DetalleID = p_detalle_id;
	DBMS_OUTPUT.PUT_LINE('Costo del detalle ' || p_detalle_id);

EXCEPTION
	WHEN NO_DATA_FOUND THEN
    	RAISE_APPLICATION_ERROR(-20003, 'Detalle con ID ' || p_detalle_id || ' no encontrado.');
	WHEN OTHERS THEN
    	DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/