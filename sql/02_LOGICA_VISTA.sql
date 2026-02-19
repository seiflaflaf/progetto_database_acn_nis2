-- #################################################################
-- # SCRIPT 02: LOGICA APPLICATIVA  (Idempotente)
-- # Creazione di Trigger e Viste
-- #################################################################
\echo 'Creazione Regole Applicative DB (Trigger e Viste)...'

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
$$ LANGUAGE plpgsql; 

DROP TRIGGER IF EXISTS asset_audit_trigger ON ASSET;

CREATE TRIGGER asset_audit_trigger
BEFORE UPDATE OR DELETE ON ASSET
FOR EACH ROW EXECUTE PROCEDURE log_asset_changes();

-- VISTA ORIGINALE: Report ACN degli asset critici
CREATE OR REPLACE VIEW report_asset_critici_acn AS
SELECT
    A.codice_asset AS "ID_Asset",
    A.tipo AS "Tipo_Asset",
    A.descrizione AS "Descrizione_Asset",
    A.criticita AS "Livello_Criticita",
    S.nome_servizio AS "Servizio_Supportato",
    R.nome || ' ' || R.cognome AS "Nome_Responsabile_Servizio",
    R.email AS "Email_Contatto"
FROM ASSET A
INNER JOIN SERVIZIO_ASSET SA ON A.asset_id = SA.asset_id 
INNER JOIN SERVIZIO S ON SA.servizio_id = S.servizio_id   
INNER JOIN RESPONSABILE R ON S.responsabile_id = R.responsabile_id 
WHERE A.azienda_id = 1 AND A.criticita IN ('Alta', 'Critica')
ORDER BY A.criticita DESC, A.codice_asset ASC;


-- VISTA AGGIUNTA PER LA MAPPATURA: Report Mappatura Asset / Controlli FNCS/NIST
CREATE OR REPLACE VIEW report_mappatura_controlli_asset AS
SELECT 
    AZ.nome_azienda AS "Azienda",
    A.codice_asset AS "Asset",
    A.tipo AS "Tipo_Asset",
    FS.codice_subcategoria AS "Codice_Controllo",
    FS.descrizione AS "Descrizione_Controllo",
    ASC_C.dettaglio_tecnico AS "Dettaglio_Applicazione"
FROM ASSET A
INNER JOIN AZIENDA AZ ON A.azienda_id = AZ.azienda_id
INNER JOIN ASSET_SUBCATEGORIA ASC_C ON A.asset_id = ASC_C.asset_id
INNER JOIN FNCS_SUBCATEGORIA FS ON ASC_C.subcategoria_id = FS.subcategoria_id
ORDER BY AZ.nome_azienda, A.codice_asset;

\echo 'Trigger e Viste DB create.'