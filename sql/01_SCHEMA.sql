-- #################################################################
-- # SCRIPT 01: SCHEMA (DDL) (Idempotente)
-- # Creazione delle tabelle in ordine di dipendenza
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
CREATE INDEX IF NOT EXISTS idx_asset_codice_critico ON ASSET (codice_asset, criticita);

-- TABELLA 5: SERVIZIO (Dipende da AZIENDA e RESPONSABILE)
CREATE TABLE IF NOT EXISTS SERVIZIO (
    servizio_id SERIAL PRIMARY KEY,
    azienda_id INT NOT NULL REFERENCES AZIENDA(azienda_id),
    nome_servizio VARCHAR(100) NOT NULL UNIQUE, 
    descrizione TEXT,
    criticita_impatto VARCHAR(20) NOT NULL, 
    responsabile_id INT REFERENCES RESPONSABILE(responsabile_id)
);
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

-- TABELLA 7: SERVIZIO_ASSET (Junction Table)
CREATE TABLE IF NOT EXISTS SERVIZIO_ASSET (
    servizio_asset_id SERIAL PRIMARY KEY,
    servizio_id INT NOT NULL REFERENCES SERVIZIO(servizio_id), 
    asset_id INT NOT NULL REFERENCES ASSET(asset_id),
    tipo_dipendenza VARCHAR(50), 
    UNIQUE (servizio_id, asset_id)
);

-- TABELLA 8: DIPENDENZA_TERZI (Junction Table)
CREATE TABLE IF NOT EXISTS DIPENDENZA_TERZI (
    dipendenza_id SERIAL PRIMARY KEY,
    servizio_id INT NOT NULL REFERENCES SERVIZIO(servizio_id),         
    fornitore_id INT NOT NULL REFERENCES FORNITORE_TERZO(fornitore_id), 
    criticita_dipendenza VARCHAR(20) NOT NULL, 
    UNIQUE (servizio_id, fornitore_id)
);

-- TABELLA 9: FNCS_SUBCATEGORIA (Catalogo dei controlli del Framework)
CREATE TABLE IF NOT EXISTS FNCS_SUBCATEGORIA (
    subcategoria_id SERIAL PRIMARY KEY,
    funzione VARCHAR(50) NOT NULL, -- E.g., 'Identify (ID)', 'Protect (PR)'
    categoria VARCHAR(100) NOT NULL, -- E.g., 'Asset Management (ID.AM)'
    codice_subcategoria VARCHAR(20) NOT NULL UNIQUE, -- E.g., 'ID.AM-1'
    descrizione TEXT NOT NULL
);

-- TABELLA 10: PROFILO_AZIENDALE (Profilo Attuale o Target dell'azienda)
CREATE TABLE IF NOT EXISTS PROFILO_AZIENDALE (
    profilo_id SERIAL PRIMARY KEY,
    azienda_id INT NOT NULL REFERENCES AZIENDA(azienda_id),
    tipo_profilo VARCHAR(20) NOT NULL CHECK (tipo_profilo IN ('Attuale', 'Target')),
    data_rilevazione DATE DEFAULT CURRENT_DATE,
    UNIQUE (azienda_id, tipo_profilo)
);

-- TABELLA 11: PROFILO_SUBCATEGORIA (Stato di implementazione del controllo nel Profilo)
CREATE TABLE IF NOT EXISTS PROFILO_SUBCATEGORIA (
    profilo_subcategoria_id SERIAL PRIMARY KEY,
    profilo_id INT NOT NULL REFERENCES PROFILO_AZIENDALE(profilo_id),
    subcategoria_id INT NOT NULL REFERENCES FNCS_SUBCATEGORIA(subcategoria_id),
    stato_implementazione VARCHAR(50) NOT NULL, -- E.g., 'Non Implementato', 'Parziale', 'Completato'
    UNIQUE (profilo_id, subcategoria_id)
);

-- TABELLA 12: ASSET_SUBCATEGORIA (Associazione degli Asset ai Controlli )
CREATE TABLE IF NOT EXISTS ASSET_SUBCATEGORIA (
    asset_subcategoria_id SERIAL PRIMARY KEY,
    asset_id INT NOT NULL REFERENCES ASSET(asset_id),
    subcategoria_id INT NOT NULL REFERENCES FNCS_SUBCATEGORIA(subcategoria_id),
    dettaglio_tecnico VARCHAR(255),
    UNIQUE (asset_id, subcategoria_id)
);

\echo 'Tabelle create con successo (incluso Framework FNCS).'