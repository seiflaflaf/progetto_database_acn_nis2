-- #################################################################
-- # SCRIPT 05: Generazione Report ACN e Framework FNCS
-- # Esporta i dati dalle VIEW e dalle Query in formato CSV
-- #################################################################
\echo 'Fase 1: Esportazione CSV (tramite client psql)...'

-- !! ATTENZIONE: MODIFICARE I PERCORSI SOTTOSTANTI !!
-- Sostituire 'C:\export\...' con un percorso valido e con permessi 
-- lettura/scrittura sul proprio computer. La cartella deve esistere.

-- 1. Report: Asset Critici ACN
\copy (SELECT * FROM report_asset_critici_acn) TO 'C:\export\asset_critici_acn.csv' WITH CSV HEADER;
\echo 'Esportazione completata. File creato in C:\export\asset_critici_acn.csv'

-- 2. Report: Mappatura Asset e Controlli FNCS
\copy (SELECT * FROM report_mappatura_controlli_asset) TO 'C:\export\mappatura_controlli_fncs.csv' WITH CSV HEADER;
\echo 'Esportazione completata. File creato in C:\export\mappatura_controlli_fncs.csv'

-- 3. Report: Gap Analysis (Profilo Attuale vs Target per Azienda 1)
\copy (SELECT FS.codice_subcategoria AS "Controllo_Framework", FS.descrizione AS "Descrizione_Controllo", PA_ATT.stato_implementazione AS "Stato_Attuale", PA_TGT.stato_implementazione AS "Obiettivo_Target" FROM FNCS_SUBCATEGORIA FS LEFT JOIN PROFILO_SUBCATEGORIA PA_ATT ON FS.subcategoria_id = PA_ATT.subcategoria_id AND PA_ATT.profilo_id = (SELECT profilo_id FROM PROFILO_AZIENDALE WHERE azienda_id = 1 AND tipo_profilo = 'Attuale') LEFT JOIN PROFILO_SUBCATEGORIA PA_TGT ON FS.subcategoria_id = PA_TGT.subcategoria_id AND PA_TGT.profilo_id = (SELECT profilo_id FROM PROFILO_AZIENDALE WHERE azienda_id = 1 AND tipo_profilo = 'Target') ORDER BY FS.codice_subcategoria) TO 'C:\export\gap_analysis_azienda1.csv' WITH CSV HEADER;
\echo 'Esportazione completata. File creato in C:\export\gap_analysis_azienda1.csv'

\echo 'Tutte le esportazioni sono terminate con successo.'