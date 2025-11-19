-- #################################################################
-- # SCRIPT 05: Generazione Report ACN
-- # Esporta i dati dalla VIEW (creata da 02_LOGICA_VISTA.sql)
-- #################################################################
\echo 'Fase 1: Esportazione CSV (tramite client psql)...'

-- La VIEW "report_asset_critici_acn" è già stata creata da 02_LOGICA_VISTA.sql

-- !! ATTENZIONE: MODIFICARE IL PERCORSO SOTTOSTANTE !!
-- Sostituire 'C:/export/asset_critici_acn.csv' con un percorso
-- valido e con permessi lettura/scrittura sul proprio computer. La cartella (es. C:/export/)
-- deve esistere prima di eseguire lo script.
\copy (SELECT * FROM report_asset_critici_acn) TO 'C:\export\asset_critici_acn.csv' WITH CSV HEADER;

\echo 'Esportazione completata. File creato in C:\export\asset_critici_acn.csv'