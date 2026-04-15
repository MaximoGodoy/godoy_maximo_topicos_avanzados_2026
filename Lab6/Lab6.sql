--1)Escribe un bloque anónimo que use un cursor explícito basado 
--en un objeto para listar 2 atributos de alguna clase, ordenados por uno de los atributos.

CREATE OR REPLACE TYPE producto_obj AS OBJECT (
    nombre VARCHAR(50),
    precio NUMBER,
    MEMBER FUNCTION get_info RETURN VARCHAR2
    );
/

CREATE OR REPLACE TYPE BODY producto_obj AS
    MEMBER FUNCTION get_info RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Nombre: ' || nombre || ', Precio: ' || precio;
    END;
END;
/

DECLARE
    CURSOR producto_cursor IS 
    SELECT Precio, Nombre
    FROM Producto
    ORDER BY Nombre;

    v_producto = producto_obj;

BEGIN
    OPEN producto_cursor;
    LOOP
	FETCH producto_cursor INTO v_producto;
	EXIT WHEN producto_cursor%NOTFOUND;
	
	DBMS_OUTPUT.PUT_LINE(producto_obj.get_info());
    END LOOP;
    CLOSE producto_cursor; 
END;
/

--2) Escribe un bloque anónimo que use un cursor explícito con 
--parámetro basado en un objeto para aumentar un 10% el total de
--la suma de algún atributo numérico de un elemento de una tabla 
--y muestre los valores originales y actualizados. Usa FOR UPDATE o usa función dentro del objeto

CREATE OR REPLACE TYPE producto_obj2 AS OBJECT (
    nombre VARCHAR(50),
    precio NUMBER,
    producto_id NUMBER
    );
/

DECLARE
    CURSOR producto_cursor(p_producto_id NUMBER) IS 
    SELECT Precio, Nombre, ProductoID
    FROM Producto
    WHERE ProductoID = p_producto_id
    FOR UPDATE;

    v_producto = producto_obj2;

BEGIN
    OPEN producto_cursor(1);
    LOOP
	FETCH producto_cursor INTO v_producto;
	EXIT WHEN producto_cursor%NOTFOUND;
	
	v_precioFinal := v_producto.Precio *1.10;
	
	UPDATE Producto
	SET Precio = v_precioFinal;
	WHERE CURRENT OF producto_cursor;
	
	DBMS_OUTPUT.PUT_LINE('Precio original:'|| v_producto.Precio || 'Precio final actualizado: '|| v_precioFinal);
    END LOOP;
    CLOSE producto_cursor;

    COMMIT; 
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Finaliza el proceso'); 
        IF producto_cursor%ISOPEN THEN
            CLOSE producto_cursor; 
        END IF;
END;
/