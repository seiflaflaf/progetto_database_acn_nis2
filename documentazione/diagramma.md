```mermaid
erDiagram
    AZIENDA {
        int azienda_id PK
        string nome_azienda "Univoco"
        string profilo_target "Target (es. Essenziale)"
    }
    RESPONSABILE {
        int responsabile_id PK
        string nome
        string cognome
        string email "Univoco"
        bool contatto_acn "Flag PoC"
    }
    FORNITORE_TERZO {
        int fornitore_id PK
        string nome_fornitore "Univoco"
        string tipo_servizio
    }
    ASSET {
        int asset_id PK
        int azienda_id FK
        string codice_asset "Univoco"
        string tipo
        string criticita "CHECK"
    }

    %% --- NUOVA SEZIONE FRAMEWORK ACN ---
    ACN_FUNZIONE {
        int funzione_id PK
        string codice "Es. ID, PR"
        string nome "Es. Identify"
    }
    ACN_CATEGORIA {
        int categoria_id PK
        int funzione_id FK
        string codice "Es. PR.AC"
        string nome
    }
    ACN_SOTTOCATEGORIA {
        int sottocategoria_id PK
        int categoria_id FK
        string codice "Es. PR.AC-1"
        string descrizione "Il Controllo"
        string livello_minimo "Base/Essenziale"
    }
    ASSET_COMPLIANCE {
        int compliance_id PK
        int asset_id FK
        int sottocategoria_id FK
        string stato_conformita "Conforme/Non Conforme"
        string note_audit
    }
    %% ----------------------------------

    SERVIZIO {
        int servizio_id PK
        int azienda_id FK
        int responsabile_id FK
        string nome_servizio
        string criticita_impatto
    }
    SERVIZIO_ASSET {
        int servizio_asset_id PK
        int servizio_id FK
        int asset_id FK
        string tipo_dipendenza
    }
    DIPENDENZA_TERZI {
        int dipendenza_id PK
        int servizio_id FK
        int fornitore_id FK
        string criticita_dipendenza
    }
    ASSET_STORICO {
        int asset_storico_id PK
        int asset_id "Log (no FK)"
        string azione
        jsonb dati_precedenti
    }

    %% Relazioni Gerarchiche
    AZIENDA ||--o{ ASSET : "possiede"
    AZIENDA ||--o{ SERVIZIO : "eroga"
    RESPONSABILE ||--o{ SERVIZIO : "gestisce"

    %% Relazioni Framework ACN (Nuove)
    ACN_FUNZIONE ||--|{ ACN_CATEGORIA : "contiene"
    ACN_CATEGORIA ||--|{ ACN_SOTTOCATEGORIA : "definisce"

    %% Relazione di Compliance (Il cuore del progetto)
    ASSET ||--o{ ASSET_COMPLIANCE : "è verificato su"
    ACN_SOTTOCATEGORIA ||--o{ ASSET_COMPLIANCE : "determina regola per"

    %% Relazioni Operative
    SERVIZIO ||--o{ SERVIZIO_ASSET : "utilizza"
    ASSET ||--o{ SERVIZIO_ASSET : "supporta"
    SERVIZIO ||--o{ DIPENDENZA_TERZI : "dipende da"
    FORNITORE_TERZO ||--o{ DIPENDENZA_TERZI : "fornisce"

    ASSET ||--o{ ASSET_STORICO : "logga"