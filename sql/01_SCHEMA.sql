-- #################################################################
-- # SCRIPT 01: SCHEMA (DDL) (Idempotente)
-- # Creazione delle tabelle in ordine di dipendenza
-- # Creazioni di indici di performance e ricerca
-- #################################################################
\echo 'Creazione tabelle (con verifica di esistenza)...'

-- TABELLA 1: AZIENDA (Anagrafica soggetto obbligato)
CREATE TABLE IF NOT EXISTS AZIENDA (
    azienda_id SERIAL PRIMARY KEY,
    nome_azienda VARCHAR(100) NOT NULL UNIQUE,
    profilo_acn VARCHAR(50) NOT NULL 
);

-- TABELLA 2: RESPONSABILE (Anagrafica referenti interni)
CREATE TABLE IF NOT EXISTS RESPONSABILE (
    responsabile_id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    cognome VARCHAR(50) NOT NULL,
    ruolo_interno VARCHAR(100),
    contatto_acn BOOLEAN NOT NULL DEFAULT FALSE, 
    email VARCHAR(100) NOT NULL UNIQUE
);

-- Ottimizza la "QUERY DI ESTRAZIONE 3: Elenco Punti di Contatto ACN"
CREATE INDEX IF NOT EXISTS idx_responsabile_contatto_acn ON RESPONSABILE (contatto_acn);

-- TABELLA 3: FORNITORE_TERZO (Anagrafica fornitori esterni)
CREATE TABLE IF NOT EXISTS FORNITORE_TERZO (
    fornitore_id SERIAL PRIMARY KEY,
    nome_fornitore VARCHAR(100) NOT NULL UNIQUE,
    tipo_servizio VARCHAR(50) 
);

-- TABELLA 4: ASSET (inventario)
CREATE TABLE IF NOT EXISTS ASSET (
    asset_id SERIAL PRIMARY KEY,
    azienda_id INT NOT NULL REFERENCES AZIENDA(azienda_id), 
    codice_asset VARCHAR(50) NOT NULL UNIQUE, 
    tipo VARCHAR(50) NOT NULL, 
    descrizione TEXT,
    localizzazione VARCHAR(100),
    criticita VARCHAR(20) NOT NULL CHECK (criticita IN ('Alta', 'Media', 'Bassa', 'Critica'))
);
-- Ottimizza la VIEW 'report_asset_critici_acn' (filtro/ordine)
CREATE INDEX IF NOT EXISTS idx_asset_codice_critico ON ASSET (codice_asset, criticita);
-- --- NUOVA SEZIONE: STRUTTURA FRAMEWORK NAZIONALE (ACN) ---

-- TABELLA 5: ACN_FUNZIONE (Livello Alto: Identify, Protect...)
CREATE TABLE IF NOT EXISTS ACN_FUNZIONE (
    funzione_id SERIAL PRIMARY KEY,
    codice VARCHAR(10) NOT NULL UNIQUE, -- Es. 'ID', 'PR'
    nome VARCHAR(50) NOT NULL           -- Es. 'Identificazione', 'Protezione'
);

-- TABELLA 6: ACN_CATEGORIA (Es. Asset Management, Access Control...)
CREATE TABLE IF NOT EXISTS ACN_CATEGORIA (
    categoria_id SERIAL PRIMARY KEY,
    funzione_id INT NOT NULL REFERENCES ACN_FUNZIONE(funzione_id),
    codice VARCHAR(20) NOT NULL, -- Es. 'ID.AM', 'PR.AC'
    nome VARCHAR(100) NOT NULL,
    UNIQUE(codice)
);

-- TABELLA 7: ACN_SOTTOCATEGORIA (Il requisito specifico richiesto dal docente)
CREATE TABLE IF NOT EXISTS ACN_SOTTOCATEGORIA (
    sottocategoria_id SERIAL PRIMARY KEY,
    categoria_id INT NOT NULL REFERENCES ACN_CATEGORIA(categoria_id),
    codice VARCHAR(20) NOT NULL, -- Es. 'ID.AM-1'
    descrizione TEXT NOT NULL,
    livello_minimo VARCHAR(20) CHECK (livello_minimo IN ('Base', 'Essenziale', 'Importante'))
);

-- TABELLA 8: ASSET_COMPLIANCE (Gap Analysis)
-- Collega l'Asset alla Sottocategoria specifica
CREATE TABLE IF NOT EXISTS ASSET_COMPLIANCE (
    compliance_id SERIAL PRIMARY KEY,
    asset_id INT NOT NULL REFERENCES ASSET(asset_id) ON DELETE CASCADE,
    sottocategoria_id INT NOT NULL REFERENCES ACN_SOTTOCATEGORIA(sottocategoria_id),
    stato_conformita VARCHAR(20) NOT NULL 
        CHECK (stato_conformita IN ('Conforme', 'Non Conforme', 'Non Applicabile', 'In Corso')),
    data_verifica DATE DEFAULT CURRENT_DATE,
    note_audit TEXT,
    UNIQUE(asset_id, sottocategoria_id)
);
-- TABELLA 9: SERVIZIO (Dipende da AZIENDA e RESPONSABILE)
CREATE TABLE IF NOT EXISTS SERVIZIO (
    servizio_id SERIAL PRIMARY KEY,
    azienda_id INT NOT NULL REFERENCES AZIENDA(azienda_id),
    --Aggiunto UNIQUE per permettere l'idempotenza degli INSERT
    nome_servizio VARCHAR(100) NOT NULL UNIQUE, 
    descrizione TEXT,
    criticita_impatto VARCHAR(20) NOT NULL, 
    responsabile_id INT REFERENCES RESPONSABILE(responsabile_id)
);

-- Indice su FK (responsabile_id) per ottimizzare i JOIN con la tabella RESPONSABILE
CREATE INDEX IF NOT EXISTS idx_servizio_responsabile ON SERVIZIO (responsabile_id);

-- TABELLA 10: ASSET_STORICO (Log per modifiche su ASSET)
CREATE TABLE IF NOT EXISTS ASSET_STORICO (
    asset_storico_id SERIAL PRIMARY KEY,
    asset_id INT NOT NULL, 
    ts_modifica TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    utente_modifica VARCHAR(50) DEFAULT SESSION_USER,
    azione VARCHAR(10) NOT NULL, 
    dati_precedenti JSONB 
);

-- TABELLA 11: SERVIZIO_ASSET (Juction Table tra SERVIZIO e ASSET)
CREATE TABLE IF NOT EXISTS SERVIZIO_ASSET (
    servizio_asset_id SERIAL PRIMARY KEY,
    servizio_id INT NOT NULL REFERENCES SERVIZIO(servizio_id), 
    asset_id INT NOT NULL REFERENCES ASSET(asset_id),
    tipo_dipendenza VARCHAR(50), 
    UNIQUE (servizio_id, asset_id)
);

-- TABELLA 12: DIPENDENZA_TERZI (Junction Table tra SERVIZIO e FORNITORE_TERZO)
CREATE TABLE IF NOT EXISTS DIPENDENZA_TERZI (
    dipendenza_id SERIAL PRIMARY KEY,
    servizio_id INT NOT NULL REFERENCES SERVIZIO(servizio_id),         
    fornitore_id INT NOT NULL REFERENCES FORNITORE_TERZO(fornitore_id), 
    criticita_dipendenza VARCHAR(20) NOT NULL, 
    UNIQUE (servizio_id, fornitore_id)
);

\echo 'Tabelle create con successo.'