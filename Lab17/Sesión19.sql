--1) Diseña una estrategia de respaldo para el esquema curso_topicos. 
-- Documenta la estrategia en comentarios y escribe un script RMAN para un respaldo completo y un respaldo incremental.


-- Estrategia de Respaldo
-- - Esquema: ventas_historico
-- - Respaldo completo: Cada sábado a las 01:00
-- - Respaldo incremental (nivel 1): Diariamente a las 22:00
-- - Retención: Mantener respaldos de los últimos 30 días
-- - Ubicación: Disco local (/mnt/storage/backup) y copia en la nube (Azure Blob)

rman target /-- Script RMAN para respaldo completo

CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 30 DAYS;
CONFIGURE CHANNEL DEVICE TYPE DISK FORMAT '/mnt/storage/backup/%U';

RUN {
BACKUP DATABASE PLUS ARCHIVELOG;
DELETE OBSOLETE;
}

RUN {
BACKUP INCREMENTAL LEVEL 1 DATABASE; -- Script RMAN para respaldo incremental
BACKUP ARCHIVELOG ALL;
}

LIST BACKUP;

-- 2) Simula un fallo eliminando la tabla Productos y recupera los datos usando Flashback (si está habilitado) o RMAN. Documenta el proceso.

DROP TABLE Productos;-- Simular fallo

SELECT COUNT(*) FROM Productos; -- Error: tabla no existe

FLASHBACK TABLE Productos TO BEFORE DROP;-- Recuperar con Flashback (si está habilitado)

rman target / -- Si Flashback no está habilitado, usar RMAN

SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
RUN {
	RESTORE TABLE curso_topicos.Productos;
	RECOVER TABLE curso_topicos.Productos;
}
ALTER DATABASE OPEN;

