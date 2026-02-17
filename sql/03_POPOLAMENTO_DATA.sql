-- #################################################################
-- # SCRIPT 03: POPOLAMENTO DATI (DML) (Idempotente)
-- # Dati di test estesi (15 Aziende) + Framework ACN e Compliance
-- #################################################################
\echo 'Inserimento dati di test...'

---
-- 1. TABELLE DI LIVELLO 0 (ANAGRAFICHE BASE)
---

-- Popolamento AZIENDA (15 record)
-- NOTA: La colonna 'profilo_acn' è stata rinominata 'profilo_target' nel nuovo schema
INSERT INTO AZIENDA (nome_azienda, profilo_target) VALUES 
('Idro Spa', 'IMPORTANT'),         -- ID 1
('IT Solutions Srl','ESSENTIALS'), -- ID 2
('Trasporti Nord S.p.A.', 'IMPORTANT'), -- ID 3
('Energy Power S.r.l.', 'ESSENTIALS'),  -- ID 4
('Pharma Life S.p.A.', 'IMPORTANT'),    -- ID 5
('Global Manufacturing Srl', 'ESSENTIALS'), -- ID 6
('Comune di Alpha', 'IMPORTANT'),       -- ID 7
('Clinica Beta', 'ESSENTIALS'),          -- ID 8
('Media Digital S.p.A.', 'IMPORTANT'),  -- ID 9
('Web Hosting Pro S.r.l.', 'ESSENTIALS'), -- ID 10
('Food Supply Chain Srl', 'IMPORTANT'),  -- ID 11
('Finanza Sicura S.p.A.', 'ESSENTIALS'), -- ID 12
('Acqua Bene Comune', 'IMPORTANT'),      -- ID 13
('Aero Tecnica S.p.A.', 'ESSENTIALS'),   -- ID 14
('Logistica Veloce S.r.l.', 'IMPORTANT') -- ID 15
ON CONFLICT (nome_azienda) DO NOTHING;

-- Popolamento RESPONSABILE
INSERT INTO RESPONSABILE (nome, cognome, ruolo_interno, contatto_acn, email) VALUES
('Giulia', 'Rossi', 'CISO', TRUE, 'giulia.rossi@idrospa.it'),
('Marco', 'Bianchi', 'IT Manager', FALSE, 'marco.bianchi@idrospa.it'),
('Laura', 'Verdi', 'Responsabile Operazioni', FALSE, 'laura.verdi@idrospa.it'),
('Paolo', 'Neri', 'Responsabile HR', FALSE, 'paolo.neri@idrospa.it'),
('Elena', 'Gialli', 'IT Manager', FALSE, 'elena.gialli@itsolutionssrl.it'),
('Luca', 'Neri', 'CISO', TRUE, 'luca.bini@itsolutionssrl.it')
ON CONFLICT (email) DO NOTHING;

-- Popolamento FORNITORE_TERZO
INSERT INTO FORNITORE_TERZO (nome_fornitore, tipo_servizio) VALUES
('CloudGlobal Corp.', 'Cloud IaaS'),
('IT Assistenza Srl', 'Manutenzione Applicativa'),
('ISP Veloce Spa', 'Connettività Internet'),
('SecurNet Spa', 'Servizi SOC/MDR'),
('DataStorage Inc.', 'Cloud Backup S3')
ON CONFLICT (nome_fornitore) DO NOTHING;

---
-- [NUOVO] 2. FRAMEWORK NAZIONALE ACN (Livello Normativo)
---
\echo 'Inserimento struttura Framework Nazionale...'

-- Funzioni (Identify, Protect, Detect, Respond, Recover)
INSERT INTO ACN_FUNZIONE (codice, nome) VALUES 
('ID', 'Identify (Identificare)'),
('PR', 'Protect (Proteggere)'),
('DE', 'Detect (Rilevare)'),
('RS', 'Respond (Rispondere)'),
('RC', 'Recover (Recuperare)')
ON CONFLICT (codice) DO NOTHING;

-- Categorie (Esempi principali)
INSERT INTO ACN_CATEGORIA (funzione_id, codice, nome) VALUES 
((SELECT funzione_id FROM ACN_FUNZIONE WHERE codice='ID'), 'ID.AM', 'Asset Management'),
((SELECT funzione_id FROM ACN_FUNZIONE WHERE codice='ID'), 'ID.RA', 'Risk Assessment'),
((SELECT funzione_id FROM ACN_FUNZIONE WHERE codice='PR'), 'PR.AC', 'Identity & Access Control'),
((SELECT funzione_id FROM ACN_FUNZIONE WHERE codice='PR'), 'PR.DS', 'Data Security'),
((SELECT funzione_id FROM ACN_FUNZIONE WHERE codice='PR'), 'PR.PT', 'Protezione Tecnologica (Patching)'),
((SELECT funzione_id FROM ACN_FUNZIONE WHERE codice='DE'), 'DE.AE', 'Anomalies & Events')
ON CONFLICT (codice) DO NOTHING;

-- Sottocategorie / Controlli (I requisiti specifici)
INSERT INTO ACN_SOTTOCATEGORIA (categoria_id, codice, descrizione, livello_minimo) VALUES 
-- ID.AM (Asset Management)
((SELECT categoria_id FROM ACN_CATEGORIA WHERE codice='ID.AM'), 'ID.AM-1', 'Inventario completo degli asset fisici e logici', 'Base'),
((SELECT categoria_id FROM ACN_CATEGORIA WHERE codice='ID.AM'), 'ID.AM-2', 'Mappatura dei flussi di dati e comunicazioni', 'Importante'),
-- PR.AC (Access Control)
((SELECT categoria_id FROM ACN_CATEGORIA WHERE codice='PR.AC'), 'PR.AC-1', 'Gestione centralizzata delle identità (IAM)', 'Essenziale'),
((SELECT categoria_id FROM ACN_CATEGORIA WHERE codice='PR.AC'), 'PR.AC-5', 'Autenticazione Multi-Fattore (MFA) obbligatoria', 'Importante'),
-- PR.DS (Data Security)
((SELECT categoria_id FROM ACN_CATEGORIA WHERE codice='PR.DS'), 'PR.DS-1', 'Crittografia dei dati a riposo (Encryption at rest)', 'Essenziale'),
((SELECT categoria_id FROM ACN_CATEGORIA WHERE codice='PR.DS'), 'PR.DS-2', 'Crittografia dei dati in transito', 'Base'),
-- PR.PT (Patching)
((SELECT categoria_id FROM ACN_CATEGORIA WHERE codice='PR.PT'), 'PR.PT-1', 'Policy di aggiornamento e patching automatico', 'Essenziale'),
-- DE.AE (Logging)
((SELECT categoria_id FROM ACN_CATEGORIA WHERE codice='DE.AE'), 'DE.AE-1', 'Raccolta centralizzata dei log di sicurezza', 'Importante')
ON CONFLICT DO NOTHING;


---
-- 3. ASSET (INVENTARIO)
---
\echo 'Inserimento Asset...'

INSERT INTO ASSET (azienda_id, codice_asset, tipo, descrizione, localizzazione, criticita) VALUES
-- Azienda 1 (Idro Spa)
(1, 'FW-PRD-01', 'Firewall Hardware', 'Firewall di Produzione Primario', 'DC A', 'Critica'),
(1, 'SRV-ERP-01', 'Server Fisico', 'Server ERP gestionale', 'DC A', 'Alta'),
(1, 'SW-HR-03', 'Applicazione Software', 'Software Gestione Risorse Umane', 'Cloud', 'Media'),
(1, 'NAS-BCK-02', 'Dispositivo Storage', 'Storage per Backup Dati', 'DC B', 'Bassa'),
(1, 'SRV-WEB-01', 'Server Virtuale', 'Web Server E-commerce', 'Cloud', 'Alta'),
(1, 'SW-CRM-01', 'Applicazione Software', 'Piattaforma CRM Clienti', 'Cloud', 'Media'),
-- Azienda 2 (IT Solutions Srl)
(2, 'FW-BETA-01', 'Firewall Hardware', 'Firewall Perimetrale Sede', 'Ufficio Beta', 'Critica'),
(2, 'SRV-DC-01', 'Server Fisico', 'Domain Controller Sede Beta', 'Ufficio Beta', 'Alta'),
(2, 'SRV-FILE-01', 'Server Fisico', 'File Server Interno', 'Ufficio Beta', 'Media'),
(2, 'NAS-BETA-BCK', 'Dispositivo Storage', 'Storage Backup Locale', 'Ufficio Beta', 'Media'),
-- Azienda 3 (Trasporti Nord)
(3, 'SRV-LOG-01', 'Server Virtuale', 'Sistema Logistica e Flotta', 'Cloud Esterno', 'Critica'),
(3, 'GPS-R-01', 'Dispositivo IoT', 'Server di Tracking GPS', 'DC Principale', 'Alta'),
(3, 'DB-FLEET-02', 'Database', 'Archivio Dati Flotta', 'Cloud Esterno', 'Alta'),
-- Azienda 4 (Energy Power)
(4, 'SCADA-CTRL-01', 'Sistema Industriale', 'Controllo Rete Elettrica', 'Centrale 1', 'Critica'),
(4, 'FW-OT-02', 'Firewall Industriale', 'Protezione Rete OT', 'Centrale 2', 'Critica'),
(4, 'WEB-PORTAL-01', 'Server Virtuale', 'Portale Clienti', 'DC Secondario', 'Media'),
(4, 'SRV-BILLING', 'Server Fisico', 'Sistema Fatturazione', 'DC Secondario', 'Alta'),
-- Azienda 5 (Pharma Life)
(5, 'SRV-LAB-01', 'Server Fisico', 'Gestione Dati Clinici', 'Laboratorio Principale', 'Critica'),
(5, 'AP-R&D', 'Applicazione Software', 'Software Ricerca & Sviluppo', 'Cloud', 'Alta'),
(5, 'NAS-ARCH-01', 'Dispositivo Storage', 'Archivio Legale', 'Sede', 'Bassa'),
-- Azienda 6 (Global Manufacturing)
(6, 'MES-PRD-01', 'Sistema Industriale', 'Manufacturing Execution System', 'Impianto A', 'Critica'),
(6, 'FW-DMZ-01', 'Firewall', 'DMZ per Connessioni Partner', 'Impianto B', 'Alta'),
(6, 'SW-CAD', 'Applicazione Software', 'Software CAD/CAM', 'Sede Tech', 'Media'),
(6, 'SRV-CAT-01', 'Server Virtuale', 'Catalogo Prodotti Online', 'Cloud', 'Media'),
-- Azienda 7 (Comune di Alpha)
(7, 'SRV-ANAG-01', 'Server Fisico', 'Anagrafe Cittadini', 'Ufficio Centrale', 'Critica'),
(7, 'WEB-SERVIZI', 'Web Server', 'Portale Servizi ai Cittadini', 'DC Comune', 'Alta'),
(7, 'FW-PA-01', 'Firewall', 'Protezione Perimetro', 'Ufficio Centrale', 'Alta'),
-- Azienda 8 (Clinica Beta)
(8, 'DB-PAZIENTI', 'Database', 'Cartelle Cliniche Elettroniche (EHR)', 'DC Clinica', 'Critica'),
(8, 'FW-HOSP-01', 'Firewall', 'Rete Ospedaliera', 'DC Clinica', 'Critica'),
(8, 'SRV-IMAGING', 'Server Fisico', 'Archiviazione Immagini Mediche (PACS)', 'DC Clinica', 'Alta'),
(8, 'SW-APP-03', 'Applicazione Software', 'Gestione Prenotazioni', 'Cloud', 'Media'),
-- Azienda 9 (Media Digital S.p.A.)
(9, 'SRV-STREAM-01', 'Server Virtuale', 'Piattaforma Streaming Video', 'Cloud CDN', 'Alta'),
(9, 'DB-CONTENUTI', 'Database', 'Metadata Contenuti', 'Cloud', 'Alta'),
(9, 'NAS-EDIT-01', 'Dispositivo Storage', 'Storage Editing Video', 'Sede Redazione', 'Media'),
-- Azienda 10 (Web Hosting Pro S.r.l.)
(10, 'FW-CORE-01', 'Firewall Hardware', 'Core Network Protection', 'DC Principal', 'Critica'),
(10, 'SRV-WEB-FARM', 'Server Fisico', 'Server Farm di Hosting', 'DC Principal', 'Critica'),
(10, 'SW-PANEL-C', 'Applicazione Software', 'Pannello di Controllo Clienti', 'Cloud', 'Alta'),
(10, 'SRV-EMAIL-01', 'Server Virtuale', 'Server Posta Elettronica', 'DC Secondario', 'Alta'),
-- Azienda 11 (Food Supply Chain Srl)
(11, 'SRV-MAG-01', 'Server Fisico', 'Sistema Gestione Magazzino (WMS)', 'Magazzino Centrale', 'Critica'),
(11, 'SCANNER-RF', 'Dispositivo IoT', 'Lettori Barcode/RFID', 'Magazzino Centrale', 'Media'),
(11, 'SW-QUAL-01', 'Applicazione Software', 'Controllo Qualità', 'Sede Uff.', 'Alta'),
-- Azienda 12 (Finanza Sicura S.p.A.)
(12, 'DB-TRANSACT', 'Database', 'Transazioni Finanziarie', 'DC Cifrato', 'Critica'),
(12, 'FW-BANK-01', 'Firewall Hardware', 'Rete Bancaria', 'DC Cifrato', 'Critica'),
(12, 'SRV-TRADING', 'Server Fisico', 'Piattaforma Trading', 'DC Cifrato', 'Alta'),
(12, 'SW-RISK', 'Applicazione Software', 'Analisi Rischio', 'Cloud Esterno', 'Alta'),
-- Azienda 13 (Acqua Bene Comune)
(13, 'SCADA-WATER', 'Sistema Industriale', 'Controllo Impianti Idrici', 'Impianto A', 'Critica'),
(13, 'SRV-GIS', 'Server Virtuale', 'Mappatura Rete', 'DC Sede', 'Alta'),
(13, 'FW-TELE-01', 'Firewall Industriale', 'Rete Telecontrollo', 'Impianto B', 'Critica'),
-- Azienda 14 (Aero Tecnica S.p.A.)
(14, 'SRV-MANUT-01', 'Server Fisico', 'Sistema Gestione Manutenzione (MRO)', 'Hangar 1', 'Critica'),
(14, 'DB-AIRCRAFT', 'Database', 'Dati Componenti Aerei', 'Cloud Sicuro', 'Alta'),
(14, 'SW-CERT-01', 'Applicazione Software', 'Certificazioni Aeronavigabilità', 'Sede Tech', 'Critica'),
(14, 'NAS-PROJ-01', 'Dispositivo Storage', 'Disegni Tecnici', 'Sede Progettazione', 'Media'),
-- Azienda 15 (Logistica Veloce S.r.l.)
(15, 'SRV-ORDINI-01', 'Server Fisico', 'Elaborazione Ordini', 'DC Esterno', 'Alta'),
(15, 'FW-LGST-01', 'Firewall', 'Perimetro Logistico', 'DC Esterno', 'Alta'),
(15, 'DB-CLIENTI', 'Database', 'Anagrafica Clienti B2B', 'DC Esterno', 'Media')
ON CONFLICT (codice_asset) DO NOTHING;


---
-- [NUOVO] 4. ASSET COMPLIANCE (GAP ANALYSIS)
---
\echo 'Associazione Asset-Controlli (Compliance)...'

-- Usiamo delle subquery per prendere gli ID corretti anche se cambiano i numeri seriali.
-- Simuliamo alcuni scenari per le aziende principali.

INSERT INTO ASSET_COMPLIANCE (asset_id, sottocategoria_id, stato_conformita, note_audit) VALUES
-- 1. IDRO SPA: Firewall di Produzione (FW-PRD-01)
(
    (SELECT asset_id FROM ASSET WHERE codice_asset = 'FW-PRD-01'), 
    (SELECT sottocategoria_id FROM ACN_SOTTOCATEGORIA WHERE codice = 'ID.AM-1'), -- Inventario
    'Conforme', 
    'Presente in CMDB aziendale'
),
(
    (SELECT asset_id FROM ASSET WHERE codice_asset = 'FW-PRD-01'), 
    (SELECT sottocategoria_id FROM ACN_SOTTOCATEGORIA WHERE codice = 'PR.AC-5'), -- MFA
    'Non Conforme', 
    'MFA non attiva su interfaccia di management'
),
(
    (SELECT asset_id FROM ASSET WHERE codice_asset = 'FW-PRD-01'), 
    (SELECT sottocategoria_id FROM ACN_SOTTOCATEGORIA WHERE codice = 'DE.AE-1'), -- Log
    'Conforme', 
    'Syslog inviati al SIEM centrale'
),

-- 1. IDRO SPA: Server ERP (SRV-ERP-01)
(
    (SELECT asset_id FROM ASSET WHERE codice_asset = 'SRV-ERP-01'), 
    (SELECT sottocategoria_id FROM ACN_SOTTOCATEGORIA WHERE codice = 'PR.DS-1'), -- Cifratura disco
    'Conforme', 
    'Bitlocker attivo'
),

-- 4. ENERGY POWER (SCADA-CTRL-01 - Infrastruttura Critica)
(
    (SELECT asset_id FROM ASSET WHERE codice_asset = 'SCADA-CTRL-01'), 
    (SELECT sottocategoria_id FROM ACN_SOTTOCATEGORIA WHERE codice = 'PR.AC-1'), -- IAM
    'In Corso', 
    'Migrazione utenti in corso'
),
(
    (SELECT asset_id FROM ASSET WHERE codice_asset = 'SCADA-CTRL-01'), 
    (SELECT sottocategoria_id FROM ACN_SOTTOCATEGORIA WHERE codice = 'ID.AM-1'), -- Inventario
    'Conforme', 
    'Asset taggato fisicamente'
),

-- 7. COMUNE DI ALPHA (Anagrafe - SRV-ANAG-01)
(
    (SELECT asset_id FROM ASSET WHERE codice_asset = 'SRV-ANAG-01'), 
    (SELECT sottocategoria_id FROM ACN_SOTTOCATEGORIA WHERE codice = 'PR.DS-1'), -- Cifratura
    'Non Conforme', 
    'Dischi non cifrati, rischio GDPR'
),

-- 12. FINANZA SICURA (DB-TRANSACT)
(
    (SELECT asset_id FROM ASSET WHERE codice_asset = 'DB-TRANSACT'), 
    (SELECT sottocategoria_id FROM ACN_SOTTOCATEGORIA WHERE codice = 'PR.DS-1'), -- Cifratura Rest
    'Conforme', 
    'TDE (Transparent Data Encryption) attivo su DB'
),
(
    (SELECT asset_id FROM ASSET WHERE codice_asset = 'DB-TRANSACT'), 
    (SELECT sottocategoria_id FROM ACN_SOTTOCATEGORIA WHERE codice = 'PR.DS-2'), -- Cifratura Transito
    'Conforme', 
    'Connessioni solo via TLS 1.3'
)
ON CONFLICT (asset_id, sottocategoria_id) DO NOTHING;


---
-- 5. SERVIZI (LIVELLO 2)
---
\echo 'Inserimento Servizi...'

INSERT INTO SERVIZIO (azienda_id, nome_servizio, descrizione, criticita_impatto, responsabile_id) VALUES
-- ID 1-4: Azienda 1 (Idro Spa)
(1, 'Servizio Transazioni Finanziarie', 'Gestione pagamenti clienti', 'Alto', 1), -- ID 1
(1, 'Gestione Ordini e Inventario (ERP)', 'Processi chiave di business', 'Alto', 2), -- ID 2
(1, 'Servizi HR Interni', 'Gestione stipendi e presenze', 'Basso', 3), -- ID 3
(1, 'Servizio E-commerce B2C', 'Piattaforma vendita online', 'Alto', 2), -- ID 4
-- ID 5-7: Azienda 2 (IT Solutions Srl)
(2, 'Servizio Rete Aziendale', 'Connettività e autenticazione utenti', 'Critico', 6), -- ID 5
(2, 'Servizio Condivisione File', 'Accesso ai file condivisi interni', 'Medio', 5), -- ID 6
(2, 'Servizio Posta Elettronica', 'Mail server aziendale', 'Alto', 5), -- ID 7
-- ID 8-9: Azienda 3 (Trasporti Nord S.p.A.)
(3, 'Gestione Logistica Merci', 'Pianificazione e tracciamento spedizioni', 'Critico', 1), -- ID 8
(3, 'Servizio Fatturazione Clienti', 'Emissione e gestione fatture', 'Alto', 2), -- ID 9
-- ID 10-12: Azienda 4 (Energy Power S.r.l.)
(4, 'Controllo e Monitoraggio Rete Elettrica', 'Gestione OT e SCADA', 'Critico', 6), -- ID 10
(4, 'Servizio Clienti Online', 'Accesso utente e gestione contratti', 'Alto', 5), -- ID 11
(4, 'Misurazione e Billing', 'Raccolta dati contatori e fatturazione', 'Critico', 2), -- ID 12
-- ID 13-14: Azienda 5 (Pharma Life S.p.A.)
(5, 'Ricerca e Sviluppo Clinico', 'Gestione dati e protocolli di ricerca', 'Critico', 1), -- ID 13
(5, 'Archiviazione Dati Regolamentati', 'Conservazione legale dei dati', 'Alto', 3), -- ID 14
-- ID 15-16: Azienda 6 (Global Manufacturing Srl)
(6, 'Sistema di Produzione (MES)', 'Coordinamento macchine e processi', 'Critico', 6), -- ID 15
(6, 'Gestione Ordini e Cataloghi B2B', 'Vendita e gestione ordini aziendali', 'Alto', 5), -- ID 16
-- ID 17-19: Azienda 7 (Comune di Alpha)
(7, 'Servizi Anagrafici ai Cittadini', 'Erogazione certificati e documenti', 'Critico', 1), -- ID 17
(7, 'Rete e Telefono Uffici', 'Connettività interna', 'Alto', 2), -- ID 18
(7, 'Servizi Elettorali', 'Gestione liste e consultazioni', 'Alto', 3), -- ID 19
-- ID 20-21: Azienda 8 (Clinica Beta)
(8, 'Gestione Cartelle Cliniche (EHR)', 'Accesso e modifica dati paziente', 'Critico', 6), -- ID 20
(8, 'Imaging e Diagnostica', 'Archiviazione e visualizzazione esami', 'Critico', 5), -- ID 21
-- ID 22-23: Azienda 9 (Media Digital S.p.A.)
(9, 'Piattaforma Streaming Live/On Demand', 'Erogazione contenuti video', 'Alto', 1), -- ID 22
(9, 'Archiviazione Contenuti Media', 'Conservazione e gestione asset digitali', 'Medio', 2), -- ID 23
-- ID 24-26: Azienda 10 (Web Hosting Pro S.r.l.)
(10, 'Erogazione Servizi Hosting Web', 'Disponibilità server e siti web clienti', 'Critico', 6), -- ID 24
(10, 'Servizi di Posta Aziendale', 'Mail per clienti hosting', 'Alto', 5), -- ID 25
(10, 'Gestione Rete Core', 'Manutenzione e sicurezza perimetro', 'Critico', 2), -- ID 26
-- ID 27-28: Azienda 11 (Food Supply Chain Srl)
(11, 'Gestione Magazzino e Logistica Fredda', 'Tracciabilità e conservazione prodotti', 'Critico', 1), -- ID 27
(11, 'Controllo Qualità Fornitori', 'Validazione prodotti in ingresso', 'Alto', 3), -- ID 28
-- ID 29-30: Azienda 12 (Finanza Sicura S.p.A.)
(12, 'Piattaforma di Trading e Transazioni', 'Esecuzione ordini e pagamenti', 'Critico', 6), -- ID 29
(12, 'Analisi e Reportistica Rischio', 'Elaborazione dati e compliance', 'Alto', 5), -- ID 30
-- ID 31-32: Azienda 13 (Acqua Bene Comune)
(13, 'Gestione Impianti Idrici (SCADA)', 'Controllo remoto pompe e valvole', 'Critico', 1), -- ID 31
(13, 'Mappatura e Rete Distribuzione', 'Visualizzazione e manutenzione infrastruttura', 'Medio', 2), -- ID 32
-- ID 33-35: Azienda 14 (Aero Tecnica S.p.A.)
(14, 'Manutenzione e Riparazione Aerei (MRO)', 'Gestione operazioni di hangar', 'Critico', 6), -- ID 33
(14, 'Certificazione e Conformità Aeronavigabilità', 'Emissione e archiviazione certificati', 'Critico', 5), -- ID 34
(14, 'Gestione Progetti R&D', 'Archiviazione e collaborazione su progetti', 'Medio', 3), -- ID 35
-- ID 36-37: Azienda 15 (Logistica Veloce S.r.l.)
(15, 'Elaborazione e Evasione Ordini', 'Ricezione e preparazione spedizioni', 'Alto', 1), -- ID 36
(15, 'Gestione Clienti B2B', 'Accesso a portale clienti e dati anagrafici', 'Medio', 2) -- ID 37
ON CONFLICT (nome_servizio) DO NOTHING;


---
-- 6. TABELLE PONTE (RELAZIONI N:M)
---
\echo 'Inserimento Relazioni Servizi-Asset e Servizi-Fornitori...'

-- Popolamento Ponte N:M (Servizi -> Asset)
INSERT INTO SERVIZIO_ASSET (servizio_id, asset_id, tipo_dipendenza) VALUES
-- Azienda 1 (Idro Spa)
(1, 1, 'Infrastrutturale'), -- Servizio Finanziarie -> FW-PRD-01
(2, 2, 'Applicativo'),      -- Servizio ERP -> SRV-ERP-01
(2, 1, 'Infrastrutturale'), -- Servizio ERP -> FW-PRD-01
(3, 3, 'Applicativo'),      -- Servizi HR -> SW-HR-03
(4, 5, 'Applicativo'),      -- Servizio E-commerce -> SRV-WEB-01
(4, 6, 'Dati'),             -- Servizio E-commerce -> SW-CRM-01
-- Azienda 2 (IT Solutions Srl)
(5, 7, 'Infrastrutturale'), -- Servizio Rete -> FW-BETA-01
(5, 8, 'Infrastrutturale'), -- Servizio Rete -> SRV-DC-01
(6, 9, 'Applicativo'),      -- Servizio File -> SRV-FILE-01
(6, 10, 'Dati'),            -- Servizio File -> NAS-BETA-BCK
(7, 8, 'Infrastrutturale'), -- Servizio Posta -> SRV-DC-01
-- Azienda 3 (Trasporti Nord)
(8, 11, 'Applicativo'),      -- Gestione Logistica -> SRV-LOG-01
(8, 12, 'Dati'),             -- Gestione Logistica -> GPS-R-01
(9, 13, 'Dati'),             -- Servizio Fatturazione -> DB-FLEET-02
-- Azienda 4 (Energy Power)
(10, 14, 'Applicativo'),     -- Controllo Rete -> SCADA-CTRL-01
(10, 15, 'Infrastrutturale'),-- Controllo Rete -> FW-OT-02
(11, 16, 'Applicativo'),     -- Servizio Clienti -> WEB-PORTAL-01
(12, 17, 'Applicativo'),     -- Misurazione e Billing -> SRV-BILLING
-- Azienda 5 (Pharma Life)
(13, 18, 'Applicativo'),     -- R&S Clinico -> SRV-LAB-01
(13, 19, 'Applicativo'),     -- R&S Clinico -> AP-R&D
(14, 20, 'Dati'),            -- Archiviazione Dati -> NAS-ARCH-01
-- Azienda 6 (Global Manufacturing)
(15, 21, 'Applicativo'),     -- Sistema Produzione -> MES-PRD-01
(16, 22, 'Infrastrutturale'),-- Gestione Ordini -> FW-DMZ-01
(16, 24, 'Applicativo'),     -- Gestione Ordini -> SRV-CAT-01
-- Azienda 7 (Comune di Alpha)
(17, 25, 'Applicativo'),     -- Servizi Anagrafici -> SRV-ANAG-01
(17, 26, 'Applicativo'),     -- Servizi Anagrafici -> WEB-SERVIZI
(18, 27, 'Infrastrutturale'),-- Rete Uffici -> FW-PA-01
-- Azienda 8 (Clinica Beta)
(20, 28, 'Dati'),            -- Gestione EHR -> DB-PAZIENTI
(20, 29, 'Infrastrutturale'),-- Gestione EHR -> FW-HOSP-01
(21, 30, 'Applicativo'),     -- Imaging -> SRV-IMAGING
-- Azienda 9 (Media Digital S.p.A.)
(22, 32, 'Applicativo'),     -- Streaming -> SRV-STREAM-01
(23, 33, 'Dati'),            -- Archiviazione Contenuti -> DB-CONTENUTI
(23, 34, 'Dati'),            -- Archiviazione Contenuti -> NAS-EDIT-01
-- Azienda 10 (Web Hosting Pro S.r.l.)
(24, 35, 'Infrastrutturale'),-- Hosting Web -> FW-CORE-01
(24, 36, 'Applicativo'),     -- Hosting Web -> SRV-WEB-FARM
(25, 38, 'Applicativo'),     -- Posta Aziendale -> SRV-EMAIL-01
-- Azienda 11 (Food Supply Chain Srl)
(27, 39, 'Applicativo'),     -- Gestione Magazzino -> SRV-MAG-01
(27, 40, 'Dati'),            -- Gestione Magazzino -> SCANNER-RF
(28, 41, 'Applicativo'),     -- Controllo Qualità -> SW-QUAL-01
-- Azienda 12 (Finanza Sicura S.p.A.)
(29, 42, 'Dati'),            -- Trading -> DB-TRANSACT
(29, 43, 'Infrastrutturale'),-- Trading -> FW-BANK-01
(30, 45, 'Applicativo'),     -- Analisi Rischio -> SW-RISK
-- Azienda 13 (Acqua Bene Comune)
(31, 46, 'Applicativo'),     -- SCADA Impianti -> SCADA-WATER
(31, 48, 'Infrastrutturale'),-- SCADA Impianti -> FW-TELE-01
(32, 47, 'Applicativo'),     -- Mappatura Rete -> SRV-GIS
-- Azienda 14 (Aero Tecnica S.p.A.)
(33, 49, 'Applicativo'),     -- MRO -> SRV-MANUT-01
(34, 51, 'Applicativo'),     -- Certificazione -> SW-CERT-01
(35, 52, 'Dati'),            -- Progetti R&D -> NAS-PROJ-01
-- Azienda 15 (Logistica Veloce S.r.l.)
(36, 53, 'Applicativo'),     -- Elaborazione Ordini -> SRV-ORDINI-01
(36, 54, 'Infrastrutturale'),-- Elaborazione Ordini -> FW-LGST-01
(37, 55, 'Dati')             -- Gestione Clienti -> DB-CLIENTI
ON CONFLICT (servizio_id, asset_id) DO NOTHING;


-- Popolamento Ponte N:M (Servizi -> Fornitori Terzi)
INSERT INTO DIPENDENZA_TERZI (servizio_id, fornitore_id, criticita_dipendenza) VALUES
-- Azienda 1 (Idro Spa)
(1, 1, 'Critica'),    -- Finanziarie -> CloudGlobal
(2, 2, 'Importante'), -- ERP -> IT Assistenza
(4, 1, 'Critica'),    -- E-commerce -> CloudGlobal
(4, 4, 'Importante'), -- E-commerce -> SecurNet
-- Azienda 2 (IT Solutions Srl)
(5, 3, 'Critica'),    -- Rete Aziendale -> ISP Veloce
(7, 5, 'Importante'), -- Posta Elettronica -> DataStorage
-- Azienda 3 (Trasporti Nord S.p.A.)
(8, 1, 'Critica'),    -- Logistica Merci -> CloudGlobal
(9, 2, 'Importante'), -- Fatturazione -> IT Assistenza
-- Azienda 4 (Energy Power S.r.l.)
(10, 4, 'Critica'),   -- Controllo Rete -> SecurNet
(12, 1, 'Importante'),-- Misurazione/Billing -> CloudGlobal
-- Azienda 5 (Pharma Life S.p.A.)
(13, 1, 'Critica'),   -- R&S Clinico -> CloudGlobal
(14, 5, 'Critica'),   -- Archiviazione -> DataStorage
-- Azienda 6 (Global Manufacturing Srl)
(15, 2, 'Critica'),   -- Sistema Produzione -> IT Assistenza
(16, 4, 'Importante'),-- Gestione Ordini -> SecurNet
-- Azienda 7 (Comune di Alpha)
(17, 3, 'Critica'),   -- Servizi Anagrafici -> ISP Veloce
(19, 5, 'Bassa'),     -- Servizi Elettorali -> DataStorage
-- Azienda 8 (Clinica Beta)
(20, 1, 'Critica'),   -- Gestione EHR -> CloudGlobal
(21, 3, 'Critica'),   -- Imaging -> ISP Veloce
-- Azienda 9 (Media Digital S.p.A.)
(22, 1, 'Critica'),   -- Streaming -> CloudGlobal
(23, 5, 'Importante'),-- Archiviazione -> DataStorage
-- Azienda 10 (Web Hosting Pro S.r.l.)
(24, 3, 'Critica'),   -- Hosting Web -> ISP Veloce
(26, 4, 'Importante'),-- Gestione Rete Core -> SecurNet
-- Azienda 11 (Food Supply Chain Srl)
(27, 2, 'Critica'),   -- Gestione Magazzino -> IT Assistenza
(28, 5, 'Bassa'),     -- Controllo Qualità -> DataStorage
-- Azienda 12 (Finanza Sicura S.p.A.)
(29, 1, 'Critica'),   -- Trading -> CloudGlobal
(30, 4, 'Critica'),   -- Analisi Rischio -> SecurNet
-- Azienda 13 (Acqua Bene Comune)
(31, 2, 'Critica'),   -- SCADA Impianti -> IT Assistenza
(32, 3, 'Importante'),-- Mappatura Rete -> ISP Veloce
-- Azienda 14 (Aero Tecnica S.p.A.)
(33, 1, 'Critica'),   -- MRO -> CloudGlobal
(34, 5, 'Critica'),   -- Certificazione -> DataStorage
-- Azienda 15 (Logistica Veloce S.r.l.)
(36, 3, 'Critica'),   -- Elaborazione Ordini -> ISP Veloce
(37, 4, 'Importante') -- Gestione Clienti -> SecurNet
ON CONFLICT (servizio_id, fornitore_id) DO NOTHING; 

\echo 'Dati inseriti correttamente.'