-- #################################################################
-- # SCRIPT 04: QUERY DI ESTRAZIONE ACN
-- # Esegue le query di test per verificare i dati
-- #################################################################

-- Questa query testa la VIEW principale del report ACN.
-- (NOTA: La vista stessa è hard-coded su azienda_id = 1 [cite: 50])
\echo '--- QUERY 1: Report Asset Critici (dalla VIEW) ---'

SELECT * FROM report_asset_critici_acn; 

-- Questa query testa il JOIN tra Servizi, Dipendenze e Fornitori,
-- filtrando solo per le dipendenze con impatto 'Critico'.
\echo '--- QUERY 2: Elenco Dipendenze Critiche da Terzi (PER AZIENDA 1) ---'
SELECT
    S.nome_servizio AS "Servizio_Critico",
    FT.nome_fornitore AS "Nome_Fornitore_Terzo",
    DT.criticita_dipendenza AS "Impatto_Interruzione",
    FT.tipo_servizio AS "Tipo_Fornitura"
FROM
    DIPENDENZA_TERZI DT
INNER JOIN 
    SERVIZIO S ON DT.servizio_id = S.servizio_id
INNER JOIN
    FORNITORE_TERZO FT ON DT.fornitore_id = FT.fornitore_id
WHERE
    DT.criticita_dipendenza = 'Critica'
    AND S.azienda_id = 1 --Filtro per isolare il report solo sull'Azienda 1 (Idro Spa)
ORDER BY
    S.nome_servizio;

-- Questa query testa il filtro sulla tabella RESPONSABILE
-- per estrarre solo i contatti ACN designati.
\echo '--- QUERY 3: Elenco Punti di Contatto ACN (PER AZIENDA 1) ---'
SELECT DISTINCT
    R.nome, 
    R.cognome, 
    R.ruolo_interno AS "Ruolo_Aziendale",
    R.email
FROM
    RESPONSABILE R
-- Aggiunto JOIN per poter filtrare per azienda
INNER JOIN
    SERVIZIO S ON R.responsabile_id = S.responsabile_id
WHERE
    R.contatto_acn = TRUE
    AND S.azienda_id = 1; --Filtro per isolare il report solo sull'Azienda 1 (Idro Spa)