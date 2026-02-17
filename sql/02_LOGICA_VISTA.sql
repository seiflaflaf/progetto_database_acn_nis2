-- #################################################################
-- # SCRIPT 02: LOGICA APPLICATIVA  (Idempotente)
-- # Creazione di Trigger e Viste
-- #################################################################
\echo 'Creazione Regole Applicative DB (Trigger e Viste)...'

-- FUNZIONE TRIGGER per lo storico di ASSET
-- "CREATE OR REPLACE" rende la creazione della funzione idempotente
CREATE OR REPLACE FUNCTION log_asset_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'UPDATE' OR TG_OP = 'DELETE') THEN
        INSERT INTO ASSET_STORICO (asset_id, azione, dati_precedenti)
        VALUES (OLD.asset_id, TG_OP, to_jsonb(OLD));
    END IF;
    
    IF (TG_OP = 'UPDATE') THEN
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql; -- Imposto che il linguaggio sia interpretato come plpgsql


-- 'DROP IF EXISTS' rende la creazione del trigger idempotente
DROP TRIGGER IF EXISTS asset_audit_trigger ON ASSET;

-- TRIGGER per la storicizzazione di ASSET
CREATE TRIGGER asset_audit_trigger
BEFORE UPDATE OR DELETE ON ASSET
FOR EACH ROW EXECUTE PROCEDURE log_asset_changes();


-- VISTA 1: Asset Critici (Esistente, utile per inventario rapido)
CREATE OR REPLACE VIEW report_asset_critici_acn AS
SELECT
    A.codice_asset AS "ID_Asset",
    A.tipo AS "Tipo_Asset",
    A.criticita AS "Livello_Criticita",
    S.nome_servizio AS "Servizio_Supportato",
    R.email AS "Email_Responsabile"
FROM ASSET A
JOIN SERVIZIO_ASSET SA ON A.asset_id = SA.asset_id 
JOIN SERVIZIO S ON SA.servizio_id = S.servizio_id   
JOIN RESPONSABILE R ON S.responsabile_id = R.responsabile_id 
WHERE A.azienda_id = 1 AND A.criticita IN ('Alta', 'Critica');

-- VISTA 2: GAP ANALYSIS (Mostra lo stato di conformità per ogni asset rispetto alle sottocategorie ACN)
CREATE OR REPLACE VIEW report_gap_analysis_acn AS
SELECT 
    A.nome_azienda,
    ASS.codice_asset,
    FUN.codice AS "Funzione",
    CAT.codice AS "Categoria",
    SUB.codice AS "Sottocategoria_ACN",
    SUB.descrizione AS "Requisito",
    COMP.stato_conformita,
    COMP.note_audit
FROM ASSET_COMPLIANCE COMP
JOIN ASSET ASS ON COMP.asset_id = ASS.asset_id
JOIN AZIENDA A ON ASS.azienda_id = A.azienda_id
JOIN ACN_SOTTOCATEGORIA SUB ON COMP.sottocategoria_id = SUB.sottocategoria_id
JOIN ACN_CATEGORIA CAT ON SUB.categoria_id = CAT.categoria_id
JOIN ACN_FUNZIONE FUN ON CAT.funzione_id = FUN.funzione_id
ORDER BY ASS.codice_asset, SUB.codice;

\echo 'Trigger e Viste DB create.'