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
-- EXPORT 1: Inventario Asset Critici
\echo 'Esportazione 1: Inventario Asset Critici...'
\copy (SELECT * FROM report_asset_critici_acn) TO 'C:\export\asset_critici_acn.csv' WITH CSV HEADER;

-- EXPORT 2: Report Gap Analysis (Compliance)
-- Questo file contiene il dettaglio Asset -> Controllo -> Esito
\echo 'Esportazione 2: Report Gap Analysis (Compliance)...'
\copy (SELECT * FROM report_gap_analysis_acn) TO 'C:\export\gap_analysis_acn.csv' WITH CSV HEADER;

\echo 'Esportazione completata. File creati in C:\export\'