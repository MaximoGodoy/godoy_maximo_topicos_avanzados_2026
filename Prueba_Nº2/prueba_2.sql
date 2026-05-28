--R1: Un procedimiento almacenado es un bloque de código que realiza tareas particulares, acepta valores de entrada y de salida.
--La función almacenada es un bloque de código que devuelve un valor y se puede usar en dentro de una consulta SQL.

--R2: El parámetro IN OUT se usa cuando deseamos recibir un valor, un ejemplo es las horas asignadas a un inicidente
--las horas se ajustan y se devuelven a la vez.

--R3: Se debe llamar a la función dentro de la consulta, por ejemplo:
--CREATE OR REPLACE FUNCTION horas_asignadas(IncidenteID in NUMBER) RETURN NUMBER IS
--    horas_total NUMBER;
--BEGIN
--    SELECT SUM(Horas) INTO horas_total FROM Asignaciones WHERE IncidenteID = horas_asignadas.IncidenteID;
--    RETURN horas_total;
--END;
--/

--R4: Un trigger es un bloque de código que se ejecuta como respuesta ante algún evento, por ejemplo una inserción o eliminación de un dato
--dos tipos de triggers son: BEFORE INSERT y AFTER DELETE
--CREATE OR REPLACE TRIGGER actualizar_estado_incidente
--AFTER INSERT ON Asignaciones
--FOR EACH ROW
--BEGIN
--    UPDATE Incidentes
--    SET Estado = 'En Proceso'
--    WHERE IncidenteID = :NEW.IncidenteID AND Estado = 'Abierto';
--END;
--/

--5)Escribe un procedimiento registrar_asignacion que reciba un AgenteID, IncidenteID, Horas y Rol (parámetros IN). El procedimiento debe:
--Insertar una nueva asignación en la tabla Asignaciones (usa el próximo AsignacionID disponible).
--Actualizar el estado del incidente a 'En Proceso' si estaba en 'Abierto'.
--Manejar excepciones si el agente o incidente no existen, o si el agente ya está asignado a ese incidente.

--R5: 
CREATE OR REPLACE PROCEDURE registrar_asignacion (
    p_AgenteID IN NUMBER,
    p_IncidenteID IN NUMBER,
    p_Horas IN NUMBER,
    p_Rol IN VARCHAR2,
    p_AsignacionID OUT NUMBER,
    P_Estado OUT VARCHAR2
    ) INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Rol);

BEGIN
    VALUES (p_AgenteID, p_IncidenteID, p_Horas, p_Rol);
    RETURN AsignacionID INTO p_AsignacionID;

    UPDATE Incidentes
    SET p_Estado = 'En Proceso'
    WHERE IncidenteID = p_IncidenteID AND p_Estado = 'Abierto'
    RETURN p_Estado INTO p_Estado;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'El agente o incidente no se encuentra');
    WHEN DUP_VAL_ON_INDEX THEN
        RAISE_APPLICATION_ERROR(-20002, 'El agente ya está asignado a ese incidente');
END;
/

--6) Escribe una función calcular_horas_agente que reciba un AgenteID (parámetro IN) y 
--devuelva el total de horas asignadas a ese agente en todos los incidentes. Luego,
-- usa la función en un procedimiento mostrar_carga_agentes que muestre el total de horas por agente para todos los agentes, indicando su nombre y especialidad.

--R6: 
CREATE OR REPLACE FUNCTION calcular_horas_agente(p_AgenteID IN NUMBER) RETURN NUMBER IS
    v_totalHoras NUMBER;
BEGIN
    SELECT SUM(Horas) INTO v_totalHoras FROM Asignaciones WHERE AgenteID = p_AgenteID;
    RETURN v_totalHoras;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    END;
/

CREATE OR REPLACE PROCEDURE mostrar_carga_agentes IS 
    CURSOR agentes_cursor IS
        SELECT AgenteID, Nombre, Especialidad FROM Agentes;
BEGIN
    FOR agente IN agentes_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('Agente: ' || agente.Nombre || 'Especialidad: ' || agente.Especialidad || 'Horas totales: ' || calcular_horas_agente(agente.AgenteID));
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;


--7) Implementa un sistema de auditoría manual usando un trigger. Para esto, 
--primero crea una tabla llamada AuditoriaAsignaciones con las columnas necesarias. 
--Luego, crea un trigger auditar_asignaciones que se dispare después de insertar o 
--eliminar una asignación en la tabla Asignaciones. El trigger debe registrar en la tabla
--de auditoría el AsignacionID, AgenteID, IncidenteID, Horas, la acción realizada ('INSERT' o 'DELETE') y la fecha del registro.

CREATE TABLE AuditoriaAsignaciones(
    AuditoriaID NUMBER PRIMARY KEY,
    AsignacionID NUMBER,
    AgenteID NUMBER, 
    IncidenteID NUMBER, 
    Horas NUMBER, 
    Accion VARCHAR2(10), 
    FechaRegistro DATE,
    CONSTRAINT fk_auditoria_asignacion FOREIGN KEY (AsignacionID) REFERENCES Asignaciones(AsignacionID),
    CONSTRAINT fk_auditoria_agente FOREIGN KEY (AgenteID) REFERENCES Agentes(AgenteID),
    CONSTRAINT fk_auditoria_incidente FOREIGN KEY (IncidenteID) REFERENCES Incidentes(IncidenteID)
);

CREATE OR REPLACE TRIGGER auditar_asignaciones
AFTER INSERT OR DELETE ON Asignaciones
FOR EACH ROW
BEGIN
    IF :NEW.InsertarAccion = 'INSERT' THEN
        INSERT INTO AuditoriaAsignaciones (AuditoriaID, AsignacionID, AgenteID, IncidenteID, Horas, Accion, FechaRegistro);
    ELSE IF :NEW.EliminarAccion = 'DELETE' THEN
        INSERT INTO AuditoriaAsignaciones (AuditoriaID, AsignacionID, AgenteID, IncidenteID, Horas, Accion, FechaRegistro);
    END IF;
END;
/