--1) Crea una función calcular_edad_cliente que reciba un ClienteID (parámetro IN) y 
--devuelva la edad del cliente en años (basado en FechaNacimiento). Maneja excepciones si el cliente no existe.

CREATE OR REPLACE FUNCTION calcular_edad_cliente(p_cliente_id IN NUMBER) RETURN NUMBER AS
    v_edad NUMBER;
BEGIN
    SELECT FLOOR(MONTHS_BETWEEN(SYSDATE, FechaNacimiento) / 12)
    INTO v_edad
    FROM Clientes
    WHERE ClienteID = p_cliente_id;

    RETURN v_edad;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Cliente con ID ' || p_cliente_id || ' no encontrado.');
END;
/

-- 2)Crea una función obtener_precio_promedio que devuelva el precio promedio de todos 
--los productos. Úsala en una consulta SQL para listar los productos cuyo precio está por encima del promedio.

CREATE OR REPLACE FUNCTION obtener_precio_promedio RETURN NUMBER AS
	v_promedio NUMBER;
BEGIN
	SELECT AVG(Precio) INTO v_promedio from Productos;
	RETURN v_promedio;
END;
/

--Consulta
SELECT Nombre, Precio FROM Productos WHERE Precio > obtener_precio_promedio();


