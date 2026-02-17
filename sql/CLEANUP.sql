-- #################################################################
-- # SCRIPT: CLEANUP (Utility di servizio per test)
-- # Rimuove tutti gli oggetti dal database IN ORDINE INVERSO.
-- # Idempotente grazie all'uso di "DROP ... IF EXISTS".
-- #################################################################
\echo 'Inizio pulizia (DROP)...'

-- VISTE
DROP VIEW IF EXISTS report_gap_analysis_acn; 
DROP VIEW IF EXISTS report_asset_critici_acn;

-- TABELLE (Ordine Inverso rispetto alla creazione per vincoli FK)
DROP TABLE IF EXISTS DIPENDENZA_TERZI;
DROP TABLE IF EXISTS SERVIZIO_ASSET;

-- Cancellazione tabelle Compliance/Framework
-- Asset Compliance dipende da Asset e Sottocategoria, quindi va cancellata prima
DROP TABLE IF EXISTS ASSET_COMPLIANCE; 

DROP TABLE IF EXISTS ASSET_STORICO;
DROP TABLE IF EXISTS ASSET;
DROP TABLE IF EXISTS SERVIZIO;
DROP TABLE IF EXISTS FORNITORE_TERZO;
DROP TABLE IF EXISTS RESPONSABILE;

-- Cancellazione tabelle Struttura ACN
DROP TABLE IF EXISTS ACN_SOTTOCATEGORIA;
DROP TABLE IF EXISTS ACN_CATEGORIA;
DROP TABLE IF EXISTS ACN_FUNZIONE;

DROP TABLE IF EXISTS AZIENDA;

-- FUNZIONI
DROP FUNCTION IF EXISTS log_asset_changes();

\echo 'Pulizia completata.'