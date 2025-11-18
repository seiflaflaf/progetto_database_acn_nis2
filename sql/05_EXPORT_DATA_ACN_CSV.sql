-- #################################################################
-- # SCRIPT 05: Generazione Report ACN
-- # Esporta i dati dalla VIEW (creata da 02_LOGICA_VISTA.sql)
-- #
-- # ESECUZIONE:
-- # psql -h ip_server - U tuo_utente -d nis2_registro -f sql/05_EXPORT_DATA_ACN_SQL.sql

-- # ESEMPIO
-- # psql -h 127.0.0.1 -U postgres -W -d nis2_registro -f sql/05_EXPORT_DATA_ACN_SQL.sql
-- #################################################################
\echo 'Fase 1: Esportazione CSV (tramite client psql)...'

-- La VIEW "report_asset_critici_acn" è già stata creata da 02_LOGICA_VISTA.sql

-- !! ATTENZIONE: MODIFICARE IL PERCORSO SOTTOSTANTE !!
-- Sostituire 'C:/export/asset_critici_acn.csv' con un percorso
-- valido e scrivibile sul proprio computer. La cartella (es. C:/export/)
-- deve esistere prima di eseguire lo script.
\copy (SELECT * FROM report_asset_critici_acn) TO 'C:\export\asset_critici_acn.csv' WITH CSV HEADER;

\echo 'Esportazione completata. File creato in C:\export\asset_critici_acn.csv'