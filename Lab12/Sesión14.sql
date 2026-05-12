--1) Crea un supertipo Vehiculo con atributos Marca y Año, y un método obtener_antiguedad.
-- Luego, crea un subtipo Automovil que herede de Vehiculo, con un atributo adicional NumeroPuertas
-- y un método descripcion que devuelva una cadena con los detalles del automóvil.

CREATE OR REPLACE TYPE Vehiculo AS OBJECT (Marca VARCHAR2(50), Año NUMBER, MEMBER FUNCTION obtener_antiguedad RETURN NUMBER
) NOT FINAL;
/

CREATE OR REPLACE TYPE BODY Vehiculo AS
	MEMBER FUNCTION obtener_antiguedad RETURN NUMBER IS
	BEGIN
    	RETURN Año;
	END;
END;
/

CREATE OR REPLACE TYPE Automovil UNDER Vehiculo (
	NumPuertas NUMBER, MEMBER FUNCTION descripcion RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY Automovil AS
	MEMBER FUNCTION descripcion RETURN VARCHAR2 IS
	BEGIN
    	RETURN 'Automóvil: ' || Marca || ', Año: ' || Año || ', Puertas: ' || NumPuertas;
	END;
END;
/


-- 2) Crea un subtipo Camion que herede de Vehiculo, con un atributo adicional CapacidadCarga (en toneladas) 
-- y sobrescriba el método obtener_antiguedad para sumar 2 años adicionales (los camiones envejecen más rápido). 
-- Inserta un camión en la tabla Vehiculos y consulta su antigüedad y descripción.

CREATE OR REPLACE TYPE Camion UNDER Vehiculo ( CapacidadCarga NUMBER, OVERRIDING MEMBER FUNCTION obtener_antiguedad RETURN NUMBER);
/

CREATE OR REPLACE TYPE BODY Camion AS
	OVERRIDING MEMBER FUNCTION obtener_antiguedad RETURN NUMBER IS
	BEGIN
    	RETURN Año + 2; 
	END;
END;
/

-- Insertar
INSERT INTO Vehiculos VALUES (Camion('Mercedes-Benz', 2022, 18));
SELECT v.Marca, v.obtener_antiguedad() AS Antiguedad FROM Vehiculos v WHERE VALUE(v) IS OF (Camion);



