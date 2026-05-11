--1) Crea una función calcular_total_con_descuento que reciba un 
-- PedidoID (parámetro IN) y devuelva el total del pedido con un 
-- descuento del 10% si el total supera 1000. Usa la función en 
-- un procedimiento aplicar_descuento_pedido que actualice el total del pedido.


CREATE OR REPLACE FUNCTION calcular_total_con_descuento(p_pedidoID IN NUMBER) RETURN NUMBER AS v_total NUMBER;

BEGIN
	SELECT Total_Pedido INTO v_total
	FROM Pedidos
	WHERE PedidoID = p_pedidoID;
	IF v_total > 1000 THEN
    	v_total := v_total * 0.9; 
	END IF;
	RETURN v_total;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
    	RAISE_APPLICATION_ERROR(-20004, 'ID del pedido no encontrada ' || p_pedidoID || ' no encontrado.');
END;
/

CREATE OR REPLACE PROCEDURE aplicar_descuento_pedido(p_pedidoID IN NUMBER) AS v_ActualizarTotal NUMBER;

BEGIN
	v_ActualizarTotal := calcular_total_con_descuento(p_pedidoID);
	UPDATE Pedidos
	SET Total = v_ActualizarTotal
	WHERE PedidoID = p_pedidoID;
	DBMS_OUTPUT.PUT_LINE('Total anterior: ' || p_pedidoID || ' Total actualizado: ' || v_ActualizarTotal);
	COMMIT;

EXCEPTION
	WHEN OTHERS THEN
    	DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    	ROLLBACK;
END;
/

-- 2) Crea un trigger validar_cantidad_detalle que se dispare antes de insertar
-- o actualizar en DetallesPedidos y verifique que la Cantidad sea mayor a 0. Si no, lanza un error.


CREATE OR REPLACE TRIGGER validad_cantidad_detalle 
BEFORE INSERT ON DetallesPedidos
FOR EACH ROW

BEGIN
    IF :NEW.VerificarCantidad <= 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Tiene que ser mayor a 0');
    END IF;
END;
/



