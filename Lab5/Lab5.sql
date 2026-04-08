--1)Escribe un bloque anónimo que use un cursor explícito para listar 2 
   --atributos de alguna clase, ordenados por uno de los atributos.

DECLARE
    CURSOR producto_cursor IS 
    SELECT Precio, Nombre
    FROM Producto
    ORDER BY Nombre;

    v_productoprecio Producto.Precio%TYPE;
    v_productoNombre Producto.Nombre%TYPE;

BEGIN
    OPEN producto_cursor;
    LOOP
	FETCH producto_curso INTO v_productoprecio, v_productoNombre;
	EXIT WHEN producto_cursor%NOTFOUND;
	
	DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_productoNombre || ', Precio: ' || v_productoprecio);
    END LOOP;
    CLOSE producto_cursor; 
END;
/

--2) Escribe un bloque anónimo que use un cursor explícito con parámetro para
--aumentar un 10% el total de la suma de algún atributo numérico de un elemento
--de una tabla y muestre los valores originales y actualizados. Usa FOR UPDATE.


DECLARE
    CURSOR producto_cursor(p_producto_id NUMBER) IS 
    SELECT Precio, Nombre, ProductoID
    FROM Producto
    WHERE ProductoID = p_producto_id
    FOR UPDATE;

    v_productoprecio Producto.Precio%TYPE;
    v_productoNombre Producto.Nombre%TYPE;
    v_productoID Producto.ProductoID%TYPE;

BEGIN
    OPEN producto_cursor(1);
    LOOP
	FETCH producto_cursor INTO v_productoprecio, v_productoNombre, v_productoID;
	EXIT WHEN producto_cursor%NOTFOUND;
	
	
	v_precioFinal := v_productoprecio *1.10;
	
	UPDATE Producto
	SET Precio = v_precioFinal;
	WHERE CURRENT OF producto_cursor;
	
	DBMS_OUTPUT.PUT_LINE('Precio final actualizado');
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