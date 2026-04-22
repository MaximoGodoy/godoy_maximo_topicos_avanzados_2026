--R1) La relación de muchos a muchos es una forma de decir que en la base de datos 
--una lista o tabla X puede contener una conexión con una tabla Y. En la base de 
--datos podemos ver esto en la conexión de agentes con los incidentes, al igual que
--la asignación de estos mismos, un mismo agente puede estar en más de un incidente,
--y un incidente puede tener más de un agente.


--R2) Una vista nos sirve para tener un esquema más ordenado de los datos dentro de las tablas, 
--en vez de ejecutar la tabla al completo, creo una vista para que me arroje solo los datos que yo
--le solicito.

CREATE VIEW total_horas SELECT AS Horas, IncidenteID from Asignaciones WHERE Horas = IncidenteID;

SELECT * from total_horas;

--R3) Una excepción predefinida es aquella que nos permite la determinación de errores en el código,
--en dado caso que un dato no sea encontrado o no se muestre explcítamente dentro de la base de datos
--Ejemplo: 

DECLARE 
    v_totalhoras NUMBER;

BEGIN 
    SELECT Horas INTO v_totalhoras
    FROM Asignaciones
    WHERE Horas >= 50;

    DBMS_OUTPUT.PUT_LINE('Determinando horas...');
    DBMS_OUTPUT.PUT_LINE('Total horas:' v_totalhoras);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Error: Horas totales no disponibles no disponible.');
    WHEN memory_overflow THEN
    DBMS_OUTPUT.PUT_LINE('Error TimesTen: Falta de memoria(TT8000).');
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error inesperado:'  SQLERRM);
END;
/

--R4) Es una forma de unir varias tablas y variables en una sola con tal de que todas lean 
--es información, %NOTFOUND nos muestra que dicha información no se encuentra listada,
--el otro es %ISOPEN, que nos permite manejar una excepción si se abre por error.


--5)Escribe un bloque PL/SQL con un cursor explícito que liste las especialidades de agentes cuyo 
--promedio de horas asignadas a incidentes sea mayor a 30, mostrando la especialidad y el 
--promedio de horas. Usa un JOIN entre Agentes y Asignaciones.
DECLARE 
    CURSOR especialidades IS
    SELECT Horas, AgenteID
    FROM Asignaciones
    ORDER BY IncidenteID

    v_agente.AgenteID%TYPE;
    v_promedio.Horas%TYPE;
BEGIN 
    OPEN especialidades;
    LOOP
    FETCH v_agente INTO v_promedio;
    EXIT WHEN especialidades%NO_DATA_FOUND;;
    SELECT Horas INTO v_agente
    
    DBMS_OUTPUT.PUT_LINE('ID del Agente:' || v_agente || ', Horas' || v_promedio);
    END LOOP
    CLOSE especialidades;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Error: Horas totales no disponibles no disponible.');
    WHEN memory_overflow THEN
    DBMS_OUTPUT.PUT_LINE('Error TimesTen: Falta de memoria(TT8000).');
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error inesperado:'  SQLERRM);
END;
/

--6)Escribe un bloque PL/SQL con un cursor explícito que aumente en 10 las horas de todas las asignaciones 
--asociadas a incidentes con severidad 'Critical'. Usa FOR UPDATE y maneja excepciones.

DECLARE 
    CURSOR especialidades IS
    SELECT Horas, AgenteID
    FROM Asignaciones
    ORDER BY IncidenteID
    FOR UPDATE;

    v_agente.AgenteID%TYPE;
    v_promedio.Horas%TYPE;
    v_totalHoras.Horas%TYPE;
BEGIN 
    OPEN especialidades;
    LOOP
    FETCH v_agente INTO v_promedio;
    EXIT WHEN especialidades%NO_DATA_FOUND;;
    SELECT Horas INTO v_agente

    v_promedio := v_totalHoras *1.10;

    UPDATE Horas
    SET Horas = v_horasFinales;
    WHERE CURRENT OF especialidades;
    DBMS_OUTPUT.PUT_LINE('Horas finales actualizadas')

    DBMS_OUTPUT.PUT_LINE('ID del Agente:' || v_agente || ', Horas' || v_promedio);
    END LOOP
    CLOSE especialidades;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Finaliza el proceso'); 
        IF especialidades%ISOPEN THEN
            CLOSE especialidades; 
        END IF;
END;
/


--7)Tipo de Objeto (20 pts) Crea un tipo de objeto incidente_obj con atributos incidente_id, descripcion, y 
--un método get_reporte. Luego, crea una tabla basada en ese tipo y transfiere los datos de Incidentes a esa tabla.
--Finalmente, escribe un cursor explícito que liste la información de los incidentes usando el método get_reporte.

CREATE OR REPLACE TYPE incidente_obj AS OBJECT (
    indicente_id NUMBER,
    depcipcion VARCHAR(50),
    MEMBER FUNCTION get_reporte RETURN VARCHAR2
    );
/

CREATE OR REPLACE TYPE BODY incidente_obj AS
    MEMBER FUNCTION get_reporte RETURN VARCHAR2 IS
    BEGIN
        RETURN 'ID incidente: ' || incidente_id || ', Descripcion: ' || descripcion;
    END;
END;
/

DECLARE 
    CURSOR especialidades IS
    SELECT Horas, AgenteID
    FROM Asignaciones
    ORDER BY IncidenteID

    v_incidenteID = incidente_obj
    v_descripcion = incidente_obj
BEGIN 
    OPEN especialidades;
    LOOP
    FETCH v_agente INTO v_promedio;
    EXIT WHEN especialidades%NO_DATA_FOUND;;
    SELECT Horas INTO v_agente
    	DBMS_OUTPUT.PUT_LINE(incidente_obj.get_reporte());
    END LOOP;
    CLOSE especialidades; 
END;
/


