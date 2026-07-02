--Respuesta 1) Una transacción en una base de datos es una unidad de trabajo que se ejecuta de manera completa o no se ejecuta en absoluto. 
--Las propiedades ACID son:
--Atomicidad: Garantiza que todas las operaciones dentro de la transacción se completen con éxito o ninguna de ellas se aplique.
--Consistencia: Asegura que la base de datos pase de un estado válido a otro estado válido después de la transacción.
--Aislamiento: Garantiza que las operaciones de una transacción sean invisibles para otras transacciones hasta que se complete.
--Durabilidad: Asegura que una vez que una transacción se ha confirmado, sus cambios se mantendrán incluso en caso de fallos del sistema.

-- Respuesta 2) Un Data Warehouse es un sistema de almacenamiento de datos diseñado para consultas y análisis, 
-- mientras que una base de datos transaccional está optimizada para operaciones de lectura y escritura frecuentes.
-- Para diseñar un modelo dimensional para analizar las horas trabajadas por agente y por severidad de incidente, 
-- se podría crear una tabla de hechos llamada "HorasTrabajadas" que contenga las columnas: ID_Agente, ID_Severidad, 
-- Fecha, Horas. Además, se podrían crear dos tablas de dimensiones: "Agente" con atributos como Nombre, Departamento y
-- "Severidad" con atributos como Nivel y Descripción. Este modelo permite realizar consultas analíticas más eficientes, 
-- ya que las tablas de hechos y dimensiones están optimizadas para agregaciones y análisis, mientras 
-- que las tablas transaccionales están diseñadas para operaciones de inserción, actualización y eliminación 
-- frecuentes, lo que puede afectar el rendimiento de las consultas analíticas.

--Respuesta 3) En Oracle, la herencia se implementa mediante tipos de objetos. Un tipo de objeto puede heredar atributos 
-- y métodos de otro tipo de objeto.
-- Ejemplo de jerarquía de dos niveles:
CREATE OR REPLACE TYPE Agente AS OBJECT (
    id_agente NUMBER,
    nombre VARCHAR2(100),
    MEMBER FUNCTION calcular_costo RETURN NUMBER
);

--Respuesta 4) 
-- Ventajas de usar índices:
-- Mejoran el rendimiento de las consultas al permitir un acceso más rápido a los datos.
-- Permiten búsquedas eficientes y ordenamiento de resultados.
-- Desventajas de usar índices:
-- Pueden aumentar el tiempo de inserción, actualización y eliminación de datos debido a la necesidad
-- de mantener los índices actualizados.
-- Ocupan espacio adicional en disco.
-- Ventajas de usar particiones:
-- Mejoran el rendimiento de consultas al permitir que solo se escaneen las particiones relevantes
-- Facilitan la gestión de grandes volúmenes de datos.
-- Desventajas de usar particiones:
-- Pueden complicar la administración de la base de datos.
-- Para mejorar el rendimiento de consultas en la tabla Incidentes filtradas por Severidad y FechaDeteccion, 
-- se podría crear un índice compuesto en las columnas Severidad y FechaDeteccion, y particionar la tabla por
-- rango en la columna FechaDeteccion. Esto permitiría que las consultas que filtren por estas columnas se beneficien 
-- del índice y solo escaneen las particiones relevantes. El partition pruning es una técnica que permite al optimizador 
-- de consultas identificar y acceder solo a las particiones necesarias para una consulta, lo que reduce el tiempo de 
-- ejecución y mejora el rendimiento de las consultas. 



-- 5) Escribe un procedimiento registrar_asignacion que reciba un AgenteID, IncidenteID, Horas y Rol (parámetros IN). 
-- El procedimiento debe:
-- Insertar una nueva asignación en Asignaciones (usa el próximo AsignacionID disponible).
-- Validar que el agente no supere 100 horas totales asignadas en incidentes con Estado 'Abierto'.
-- Validar que el incidente no tenga ya 3 o más agentes asignados.
-- Usar savepoints independientes para cada validación, de modo que un fallo en una no deshaga operaciones previas válidas.
-- Manejar todas las excepciones con mensajes descriptivos. 

-- Respuesta 5) 
CREATE OR REPLACE PROCEDURE registrar_asignacion (
    p_AgenteID IN NUMBER,
    p_IncidenteID IN NUMBER,
    p_Horas IN NUMBER,
    p_Rol IN VARCHAR2
) AS
    v_TotalHoras NUMBER;
    v_NumAgentes NUMBER;
    v_AsignacionID NUMBER;
    savepoint sp_horas;
    savepoint sp_agentes;
BEGIN
    -- Validar que el agente no supere 100 horas totales asignadas en incidentes con Estado 'Abierto'
    SAVEPOINT sp_horas;
    SELECT SUM(Horas) INTO v_TotalHoras
    FROM Asignaciones a
    JOIN Incidentes i ON a.IncidenteID = i.IncidenteID
    WHERE a.AgenteID = p_AgenteID AND i.Estado = 'Abierto';
    -- validar que el incidente no tenga ya 3 o más agentes asignados
    SAVEPOINT sp_agentes;
    SELECT COUNT(*) INTO v_NumAgentes
    FROM Asignaciones
    WHERE IncidenteID = p_IncidenteID;
    IF v_TotalHoras + p_Horas > 100 THEN
        ROLLBACK TO sp_horas;
        RAISE_APPLICATION_ERROR(-20001, 'El agente supera las 100 horas totales asignadas en incidentes abiertos.');
    END IF;

    IF v_NumAgentes >= 3 THEN
        ROLLBACK TO sp_agentes;
        RAISE_APPLICATION_ERROR(-20002, 'El incidente ya tiene 3 o más agentes asignados.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END registrar_asignacion;

    -- Insertar nueva asignación
SELECT NVL(MAX(AsignacionID), 0) + 1 INTO v_AsignacionID FROM Asignaciones;
INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Rol)
VALUES (v_AsignacionID, p_AgenteID, p_IncidenteID, p_Horas, p_Rol);

COMMIT;

-- 6) Diseña las tablas Fact_Asignaciones, Dim_Agente y Dim_Incidente para un Data Warehouse basado 
-- en la base de datos de la prueba. Luego, escribe una consulta analítica sobre las tablas
-- transaccionales que muestre, para cada agente, el total de horas trabajadas y el número de 
-- incidentes atendidos, ordenado de mayor a menor por total de horas. 

-- Respuesta 6)
CREATE TABLE Dim_Agente (
    AgenteID NUMBER PRIMARY KEY,
    Nombre VARCHAR2(100),
    Especialidad VARCHAR2(100)
);

CREATE TABLE Dim_Incidente (
    IncidenteID NUMBER PRIMARY KEY,
    Descripcion VARCHAR2(255),
    Severidad VARCHAR2(50)
); 

CREATE TABLE Fact_Asignaciones (
    AsignacionID NUMBER PRIMARY KEY,
    AgenteID NUMBER,
    IncidenteID NUMBER,
    Horas NUMBER,
    Rol VARCHAR2(100),
    FOREIGN KEY (AgenteID) REFERENCES Dim_Agente(AgenteID),
    FOREIGN KEY (IncidenteID) REFERENCES Dim_Incidente(IncidenteID)
);

SELECT a.AgenteID, d.Nombre, SUM(a.Horas) AS TotalHoras, COUNT(DISTINCT a.IncidenteID) AS NumIncidentes
FROM Asignaciones a
JOIN Dim_Agente d ON a.AgenteID = d.AgenteID
GROUP BY a.AgenteID, d.Nombre
ORDER BY TotalHoras DESC;

-- 7) Crea un índice compuesto en Incidentes para las columnas Severidad y FechaDeteccion.
-- Luego, crea la tabla Incidentes particionada por rango de FechaDeteccion (trimestral para 2026). 
-- Escribe una consulta que muestre el total de horas asignadas por incidente para incidentes 'Critical'
-- detectados en el primer trimestre de 2026. Finalmente, muestra el plan de ejecución con EXPLAIN PLAN e indica qué 
-- ventaja aporta la partición para esta consulta.
 
--Respuesta 7) 
CREATE INDEX idx_severidad_fecha ON Incidentes (Severidad, FechaDeteccion);
CREATE TABLE INCIDENTES_PARTICIONADA (
    IncidenteID NUMBER PRIMARY KEY,
    Descripcion VARCHAR2(255),
    Severidad VARCHAR2(50),
    FechaDeteccion DATE
)
PARTITION BY RANGE (FechaDeteccion) (
    PARTITION p_trimestre1 VALUES LESS THAN (TO_DATE('2026-04-01', 'YYYY-MM-DD')),
    PARTITION p_trimestre2 VALUES LESS THAN (TO_DATE('2026-07-01', 'YYYY-MM-DD')),
    PARTITION p_trimestre3 VALUES LESS THAN (TO_DATE('2026-10-01', 'YYYY-MM-DD')),
    PARTITION p_trimestre4 VALUES LESS THAN (TO_DATE('2027-01-01', 'YYYY-MM-DD'))
);

EXPLAIN PLAN FOR
SELECT i.IncidenteID, SUM(a.Horas) AS TotalHoras
FROM INCIDENTES_PARTICIONADA i
JOIN Asignaciones a ON i.IncidenteID = a.IncidenteID
WHERE i.Severidad = 'Critical' AND i.FechaDeteccion >= TO_DATE('2026-01-01', 'YYYY-MM-DD') AND i.FechaDeteccion < TO_DATE('2026-04-01', 'YYYY-MM-DD')
GROUP BY i.IncidenteID;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);