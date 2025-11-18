
-- #################################################################
-- # SCRIPT 00: CREA_DB (DDL) (Idempotente)
-- # Creazione del database 'nis2_registro'
-- # ESECUZIONE:
-- # Questo script deve essere eseguito DOPO dopo essersi connessi
-- # al database predefinito (es. 'postgres').
-- ##################################################################

-- ##################################################################
-- # PostgreSQL non possiede un comando specifico per la verifica della preesistenza
-- # del database quindi è stato implementato un workaround per garantire 
-- # l'idempotenza dello script.
-- ##################################################################
\echo 'Controllo e creazione database nis2_registro (se non esiste)...'

-- La soluzione si basa sull'uso combinato di una query dinamica sul catalogo di sistema pg_database e del meta-comando \gexec

SELECT 'CREATE DATABASE nis2_registro'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'nis2_registro')\gexec 

\echo 'Database creato (o esistente).'