-- #################################################################
-- # SCRIPT 99: ELIMINA_DB (DDL) (Idempotente)
-- # Eliminazione del database 'nis2_registro'
-- #
-- # ESECUZIONE:
-- # Questo script deve essere eseguito DOPO essersi connessi
-- # al database predefinito (es. 'postgres').
-- #################################################################
\echo 'Eliminazione database nis2_registro (se esiste)...'

-- Aggiunto "IF EXISTS" per rendere lo script idempotente:
-- se il DB non esiste, il comando viene saltato senza errori.
DROP DATABASE IF EXISTS nis2_registro;

\echo 'Database eliminato (o non esisteva).'