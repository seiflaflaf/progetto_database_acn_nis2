-- #################################################################
-- # SCRIPT: CLEANUP (Utility di servizio per test)
-- # Rimuove tutti gli oggetti dal database IN ORDINE INVERSO.
-- # Idempotente grazie all'uso di "DROP ... IF EXISTS".
-- #################################################################
\echo 'Inizio pulizia (DROP)...'

-- "IF EXISTS" assicura che lo script non fallisca se gli oggetti
-- sono già stati cancellati.
DROP VIEW IF EXISTS report_asset_critici_acn;
DROP TABLE IF EXISTS DIPENDENZA_TERZI;
DROP TABLE IF EXISTS SERVIZIO_ASSET;
DROP TABLE IF EXISTS ASSET_STORICO;
DROP TABLE IF EXISTS ASSET;
DROP TABLE IF EXISTS SERVIZIO;
DROP TABLE IF EXISTS FORNITORE_TERZO;
DROP TABLE IF EXISTS RESPONSABILE;
DROP TABLE IF EXISTS AZIENDA;
DROP FUNCTION IF EXISTS log_asset_changes();

\echo 'Pulizia completata.'