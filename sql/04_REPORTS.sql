-- #################################################################
-- # SCRIPT 04: QUERY DI ESTRAZIONE ACN
-- # Esegue le query di test per estrapolamento dati a video
-- #################################################################

\echo '--- QUERY 1: Report Asset Critici (dalla VIEW) ---'
-- Query che testa la VIEW principale del report ACN.
SELECT * FROM report_asset_critici_acn; 

---

\echo '--- QUERY 2: Elenco Dipendenze Critiche da Terzi (PER AZIENDA 3) ---'
-- Query per testare il JOIN tra Servizi, Dipendenze e Fornitori,
-- filtrando solo per le dipendenze con impatto 'Critico' per l'Azienda 3.
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
    AND S.azienda_id = 3 --Filtro per isolare il report solo sull'Azienda 3 (Trasporti Nord)
ORDER BY
    S.nome_servizio;

---

\echo '--- QUERY 3: Elenco Punti di Contatto ACN (PER AZIENDA 2) ---'
-- Query che estrae solo i contatti ACN designati, filtrando per l'Azienda 2.
SELECT DISTINCT
    R.nome, 
    R.cognome, 
    R.ruolo_interno AS "Ruolo_Aziendale",
    R.email
FROM
    RESPONSABILE R
INNER JOIN
    SERVIZIO S ON R.responsabile_id = S.responsabile_id
INNER JOIN
    AZIENDA A ON S.azienda_id = A.azienda_id
WHERE
    R.contatto_acn = TRUE
    AND S.azienda_id = 2; -- Filtro per isolare il report solo sull'Azienda 2 (IT Solutions Srl)


\echo '--- QUERY 4: Conteggio Asset Critici/Alti per Tipo di Azienda ---'
-- [AGGIORNATA] Corretto 'profilo_acn' in 'profilo_target' come da nuovo schema
SELECT
    A.profilo_target AS "Profilo_Obiettivo_ACN",
    COUNT(CASE WHEN AST.criticita = 'Critica' THEN 1 END) AS "Conta_Asset_Critici",
    COUNT(CASE WHEN AST.criticita = 'Alta' THEN 1 END) AS "Conta_Asset_Alti",
    COUNT(AST.asset_id) AS "Totale_Asset_Alti_Critici"
FROM
    AZIENDA A
INNER JOIN
    ASSET AST ON A.azienda_id = AST.azienda_id
WHERE
    AST.criticita IN ('Alta', 'Critica')
GROUP BY
    A.profilo_target
ORDER BY
    "Totale_Asset_Alti_Critici" DESC;


\echo '--- QUERY 5: Asset e Servizi Dipendenti da Fornitori Critici (TUTTE LE AZIENDE) ---'
---Query per l'analisi della Supply Chain e delle dipendenze da terze parti
SELECT
    A.nome_azienda AS "Azienda",
    S.nome_servizio AS "Servizio_Dipendente",
    AST.codice_asset AS "Asset_Associato",
    FT.nome_fornitore AS "Fornitore_Critico",
    DT.criticita_dipendenza AS "Impatto_Dipendenza"
FROM
    DIPENDENZA_TERZI DT
INNER JOIN 
    SERVIZIO S ON DT.servizio_id = S.servizio_id
INNER JOIN
    AZIENDA A ON S.azienda_id = A.azienda_id
INNER JOIN
    FORNITORE_TERZO FT ON DT.fornitore_id = FT.fornitore_id
LEFT JOIN
    SERVIZIO_ASSET SA ON S.servizio_id = SA.servizio_id
LEFT JOIN
    ASSET AST ON SA.asset_id = AST.asset_id
WHERE
    DT.criticita_dipendenza = 'Critica'
ORDER BY
    A.nome_azienda, FT.nome_fornitore, S.nome_servizio;


\echo '--- QUERY 6: Responsabili con Più Servizi Critici ---'
---query per i responsabili interni relativi ai servizi critici
SELECT
    R.nome || ' ' || R.cognome AS "Responsabile",
    R.email,
    COUNT(S.servizio_id) AS "Numero_Servizi_Critici_Alti",
    A.nome_azienda AS "Azienda"
FROM
    SERVIZIO S
INNER JOIN
    RESPONSABILE R ON S.responsabile_id = R.responsabile_id
INNER JOIN 
    AZIENDA A ON S.azienda_id = A.azienda_id
WHERE
    S.criticita_impatto IN ('Critico', 'Alto')
GROUP BY
    R.responsabile_id, R.nome, R.cognome, R.email, A.nome_azienda
ORDER BY
    "Numero_Servizi_Critici_Alti" DESC, "Responsabile" ASC;

    \echo '--- QUERY 7: GAP ANALYSIS (Asset Non Conformi alla Normativa) ---'
-- Questa query dimostra l'associazione Asset-Controlli richiesta dal docente
SELECT * FROM report_gap_analysis_acn 
WHERE stato_conformita = 'Non Conforme';

\echo '--- QUERY 8: Statistiche di Conformità per Funzione ACN ---'
-- Mostra quanto l'azienda è "coperta" sulle funzioni Identify, Protect, etc.
SELECT 
    F.nome AS "Funzione_ACN",
    COUNT(C.compliance_id) AS "Controlli_Verificati",
    COUNT(CASE WHEN C.stato_conformita = 'Conforme' THEN 1 END) AS "Conformi",
    COUNT(CASE WHEN C.stato_conformita = 'Non Conforme' THEN 1 END) AS "NON_Conformi"
FROM ACN_FUNZIONE F
JOIN ACN_CATEGORIA CAT ON F.funzione_id = CAT.funzione_id
JOIN ACN_SOTTOCATEGORIA S ON CAT.categoria_id = S.categoria_id
JOIN ASSET_COMPLIANCE C ON S.sottocategoria_id = C.sottocategoria_id
GROUP BY F.nome
ORDER BY F.nome;