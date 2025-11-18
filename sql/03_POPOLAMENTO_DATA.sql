-- #################################################################
-- # SCRIPT 03: POPOLAMENTO DATI (DML) (Idempotente)
-- # Inserimento dati di test rappresentativi
-- # Tutti gli INSERT usano "ON CONFLICT (...) DO NOTHING".
-- # per prevenire errori di duplicazione
-- # se lo script viene eseguito più volte.
-- #################################################################
\echo 'Inserimento dati di test (con verifica di duplicazione)...'

-- Popolamento Tabelle di Livello 0 (Anagrafiche)
-- Aggiunto "ON CONFLICT" per l'idempotenza
INSERT INTO AZIENDA (nome_azienda, profilo_acn) VALUES 
('Idro Spa', 'IMPORTANT'),
('IT Solutions Srl','ESSENTIALS')
ON CONFLICT (nome_azienda) DO NOTHING;

INSERT INTO RESPONSABILE (nome, cognome, ruolo_interno, contatto_acn, email) VALUES
('Giulia', 'Rossi', 'CISO', TRUE, 'giulia.rossi@idrospa.it'), 
('Marco', 'Bianchi', 'IT Manager', FALSE, 'marco.bianchi@idrospa.it'),
('Laura', 'Verdi', 'Responsabile Operazioni', FALSE, 'laura.verdi@idrospa.it'), -- <-- VIRGOLA CORRETTA
('Paolo', 'Neri', 'Responsabile HR', FALSE, 'paolo.neri@idrospa.it'),
('Elena', 'Gialli', 'IT Manager', FALSE, 'elena.gialli@itsolutionssrl.it'),
('Luca', 'Neri', 'CISO', TRUE, 'luca.bini@itsolutionssrl.it')
ON CONFLICT (email) DO NOTHING;

INSERT INTO FORNITORE_TERZO (nome_fornitore, tipo_servizio) VALUES
('CloudGlobal Corp.', 'Cloud IaaS'), 
('IT Assistenza Srl', 'Manutenzione Applicativa'), 
('ISP Veloce Spa', 'Connettività Internet'),
('SecurNet Spa', 'Servizi SOC/MDR'),
('DataStorage Inc.', 'Cloud Backup S3')
ON CONFLICT (nome_fornitore) DO NOTHING;

-- Popolamento Tabelle di Livello 1 (Dati principali dipendenti dal Liv. 0)
INSERT INTO ASSET (azienda_id, codice_asset, tipo, descrizione, localizzazione, criticita) VALUES
-- Asset Azienda 1 (Idro Spa)
(1, 'FW-PRD-01', 'Firewall Hardware', 'Firewall di Produzione Primario', 'Data Center A', 'Critica'), 
(1, 'SRV-ERP-01', 'Server Fisico', 'Server ERP gestionale', 'Data Center A', 'Alta'), 
(1, 'SW-HR-03', 'Applicazione Software', 'Software Gestione Risorse Umane', 'Cloud', 'Media'), 
(1, 'NAS-BCK-02', 'Dispositivo Storage', 'Storage per Backup Dati', 'Data Center B', 'Bassa'),
(1, 'SRV-WEB-01', 'Server Virtuale', 'Web Server E-commerce', 'Cloud', 'Alta'),
(1, 'SW-CRM-01', 'Applicazione Software', 'Piattaforma CRM Clienti', 'Cloud', 'Media'),
-- Asset Azienda 2 (IT Solutions Srl)
(2, 'FW-BETA-01', 'Firewall Hardware', 'Firewall Perimetrale Sede', 'Ufficio Beta', 'Critica'),
(2, 'SRV-DC-01', 'Server Fisico', 'Domain Controller Sede Beta', 'Ufficio Beta', 'Alta'),
(2, 'SRV-FILE-01', 'Server Fisico', 'File Server Interno', 'Ufficio Beta', 'Media'),
(2, 'NAS-BETA-BCK', 'Dispositivo Storage', 'Storage Backup Locale', 'Ufficio Beta', 'Media')
ON CONFLICT (codice_asset) DO NOTHING;


INSERT INTO SERVIZIO (azienda_id, nome_servizio, descrizione, criticita_impatto, responsabile_id) VALUES
-- Servizi Azienda 1 (Idro Spa)
(1, 'Servizio Transazioni Finanziarie', 'Gestione pagamenti clienti', 'Alto', 1), 
(1, 'Gestione Ordini e Inventario (ERP)', 'Processi chiave di business', 'Alto', 2), 
(1, 'Servizi HR Interni', 'Gestione stipendi e presenze', 'Basso', 3),
(1, 'Servizio E-commerce B2C', 'Piattaforma vendita online', 'Alto', 2),
-- Servizi Azienda 2 (IT Solutions Srl)
(2, 'Servizio Rete Aziendale', 'Connettività e autenticazione utenti', 'Critico', 6),
(2, 'Servizio Condivisione File', 'Accesso ai file condivisi interni', 'Medio', 5),
(2, 'Servizio Posta Elettronica', 'Mail server aziendale', 'Alto', 5)
ON CONFLICT (nome_servizio) DO NOTHING;

-- Popolamento Ponte N:M (Servizi -> Asset)
INSERT INTO SERVIZIO_ASSET (servizio_id, asset_id, tipo_dipendenza) VALUES
-- L1 (Azienda 1)
(1, 1, 'Infrastrutturale'), 
(2, 2, 'Applicativo'),      
(2, 1, 'Infrastrutturale'), 
(3, 3, 'Applicativo'),      
(1, 4, 'Dati'),             
(4, 5, 'Applicativo'),      
(4, 1, 'Infrastrutturale'), 
(4, 6, 'Dati'),             
-- L2 (Azienda 2)
(5, 7, 'Infrastrutturale'), 
(5, 8, 'Infrastrutturale'), 
(6, 9, 'Applicativo'),      
(6, 10, 'Dati'),            
(7, 8, 'Infrastrutturale')  
ON CONFLICT (servizio_id, asset_id) DO NOTHING;

-- Popolamento Ponte N:M (Servizi -> Fornitori Terzi)
INSERT INTO DIPENDENZA_TERZI (servizio_id, fornitore_id, criticita_dipendenza) VALUES
-- L1 (Azienda 1)
(1, 1, 'Critica'),    
(2, 2, 'Importante'), 
(1, 3, 'Critica'),    
(4, 1, 'Critica'),    
(4, 4, 'Importante'), 
-- L2 (Azienda 2)
(5, 3, 'Critica'),    
(5, 4, 'Critica'),    
(7, 5, 'Importante')
ON CONFLICT (servizio_id, fornitore_id) DO NOTHING; -- <-- CLAUSOLA ON CONFLICT CORRETTA

\echo 'Dati inseriti (o ignorati se già presenti).'