
--1) Escribe un bloque PL/SQL que verifique el valor numérico de una tabla. 
--Si el valor es menor a algún bias, lanza una excepción personalizada.
--Maneja también NO_DATA_FOUND

DECLARE

    v_Productoprecio NUMBER;
    precio_bajo EXCEPTION;

BEGIN

    SELECT Precio INTO v_Productoprecio
    FROM Producto
    WHERE ProductoID = 2;

    IF v_Productoprecio >= 75 THEN
    RAISE precio_bajo;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Determinando valor...');
    DBMS_OUTPUT.PUT_LINE('Valor:' v_Productoprecio);

EXCEPTION
    WHEN precio_bajo THEN
    DBMS_OUTPUT.PUT_LINE('Error: El precio es muy bajo'(' v_Productoprecio').');
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Error: Producto no disponible.');
    WHEN memory_overflow THEN
    DBMS_OUTPUT.PUT_LINE('Error TimesTen: Falta de memoria(TT8000).');
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error inesperado:'  SQLERRM);
END;
/


--2) Escribe un bloque PL/SQL que intente insertar una tupla con ID duplicado
  
BEGIN
    INSERT INTO Producto (ProductoID, Nombre, Precio)
    VALUES (2, 'Producto Mouse duplicado', 50);

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: El ID ya existe.');

    WHEN memory_overflow THEN
    DBMS_OUTPUT.PUT_LINE('Error TimesTen: Falta de memoria(TT8000).');

    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error inesperado:'  SQLERRM);
END;
/
