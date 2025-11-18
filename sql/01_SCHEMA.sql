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

-- TABELLA 4: ASSET (Dipende da AZIENDA)
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

-- TABELLA 5: SERVIZIO (Dipende da AZIENDA e RESPONSABILE)
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

-- TABELLA 6: ASSET_STORICO (Log per modifiche su ASSET)
CREATE TABLE IF NOT EXISTS ASSET_STORICO (
    asset_storico_id SERIAL PRIMARY KEY,
    asset_id INT NOT NULL, 
    ts_modifica TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    utente_modifica VARCHAR(50) DEFAULT SESSION_USER,
    azione VARCHAR(10) NOT NULL, 
    dati_precedenti JSONB 
);

-- TABELLA 7: SERVIZIO_ASSET (Juction Table tra SERVIZIO e ASSET)
CREATE TABLE IF NOT EXISTS SERVIZIO_ASSET (
    servizio_asset_id SERIAL PRIMARY KEY,
    servizio_id INT NOT NULL REFERENCES SERVIZIO(servizio_id), 
    asset_id INT NOT NULL REFERENCES ASSET(asset_id),
    tipo_dipendenza VARCHAR(50), 
    UNIQUE (servizio_id, asset_id)
);

-- TABELLA 8: DIPENDENZA_TERZI (Junction Table tra SERVIZIO e FORNITORE_TERZO)
CREATE TABLE IF NOT EXISTS DIPENDENZA_TERZI (
    dipendenza_id SERIAL PRIMARY KEY,
    servizio_id INT NOT NULL REFERENCES SERVIZIO(servizio_id),         
    fornitore_id INT NOT NULL REFERENCES FORNITORE_TERZO(fornitore_id), 
    criticita_dipendenza VARCHAR(20) NOT NULL, 
    UNIQUE (servizio_id, fornitore_id)
);

\echo 'Tabelle create con successo.'