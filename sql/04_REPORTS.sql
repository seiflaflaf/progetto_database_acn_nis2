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


\echo '--- QUERY 4: Conteggio Asset Critici/Alti per Tipo di Azienda (TUTTE LE AZIENDE) ---'
---Query per avere una visione aggregata del rischio in base alla classificazione ufficiale ACN dell'azienda
SELECT
    A.profilo_acn AS "Profilo_ACN",
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
    A.profilo_acn
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


\echo '--- QUERY 7: Gap Analysis Profilo Attuale vs Target (Azienda 1) ---'
-- Mostra lo scostamento tra lo stato di sicurezza attuale e quello target richiesto come da normativa
SELECT 
    FS.codice_subcategoria AS "Controllo_Framework",
    FS.descrizione AS "Descrizione_Controllo",
    PA_ATT.stato_implementazione AS "Stato_Attuale",
    PA_TGT.stato_implementazione AS "Obiettivo_Target"
FROM FNCS_SUBCATEGORIA FS
LEFT JOIN PROFILO_SUBCATEGORIA PA_ATT ON FS.subcategoria_id = PA_ATT.subcategoria_id 
    AND PA_ATT.profilo_id = (SELECT profilo_id FROM PROFILO_AZIENDALE WHERE azienda_id = 1 AND tipo_profilo = 'Attuale')
LEFT JOIN PROFILO_SUBCATEGORIA PA_TGT ON FS.subcategoria_id = PA_TGT.subcategoria_id 
    AND PA_TGT.profilo_id = (SELECT profilo_id FROM PROFILO_AZIENDALE WHERE azienda_id = 1 AND tipo_profilo = 'Target')
ORDER BY FS.codice_subcategoria;

\echo '--- QUERY 8: Elenco Asset per Controllo di Protezione Dati (PR.DS-1) ---'
-- Mostra tutti gli asset, indipendentemente dall'azienda, che sono mappati per la crittografia dei dati
SELECT * FROM report_mappatura_controlli_asset
WHERE "Codice_Controllo" = 'PR.DS-1';