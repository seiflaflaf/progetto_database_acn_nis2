# 🚀 Registro Asset e Servizi (Conformità NIS2/ACN e Framework Nazionale per la Cybersecurity e la Data Protection)

Questo progetto contiene lo schema di un database PostgreSQL e gli script SQL necessari per creare, popolare, gestire ed esportare un registro di asset e servizi per determinate aziende, come richiesto dalla direttiva NIS2 e per il reporting ACN. 

Inoltre, il progetto integra l'architettura per la misurazione della conformità secondo il **Framework Nazionale per la Cybersecurity (FNCS/NIST)**, permettendo la mappatura degli asset ai controlli di sicurezza e la generazione automatica di una **Gap Analysis** (Profilo Attuale vs Profilo Target).

Il progetto è diviso in due parti principali:

1.  **`sql/`**: Contiene tutti gli script SQL per creare, popolare, interrogare ed esportare i dati del database. 
2.  **`documentazione/`**: Contiene le istruzioni di deploy (questo file) e il Diagramma ER. 

---

## 🛠️ Prerequisiti

Prima di iniziare, assicurati di avere installato e configurato:
* Un server **PostgreSQL** (v12+) in esecuzione.
* Un utente con privilegi di amministratore (es. postgres)
* Un database esistente di manutenzione
* **`psql`** (il client a riga di comando di PostgreSQL) deve essere installato e accessibile nel `PATH` del sistema. 

---

## ⚙️ Installazione e Setup del Database

Questi script sono pensati per essere eseguiti dal client `psql`. **L'ordine di esecuzione è fondamentale.** #### Questa è la stringa da utilizzare per eseguire gli scripts

*`psql -h [IP_LOCALHOST] -U [UTENTE_AMMINISTRATORE] -W -d [DATABASE_DI_MANUNTENZIONE] -f [PERCORSO_DOVE_SI_TROVA_LO_SCRIPT]/00_CREA_DB.sql`*

_(-W forza la richiesta di password, -h IP_LOCALHOST forza IPv4)_

### 1. Creazione del Database
Questo script va eseguito **connettendosi al database di manutenzione `postgres`** (o un altro database esistente). 

**`psql -h 127.0.0.1 -U postgres -W -d postgres -f sql/00_CREA_DB.sql`**

_dopo aver creato il database **nis2_registro** si eseguono in successione questi scripts._

### 2. Crea le tabelle e i vincoli 
**`psql -h 127.0.0.1 -U postgres -W -d nis2_registro -f sql/01_SCHEMA.sql`**

### 3. Aggiunge i trigger, le funzioni e le viste
**`psql -h 127.0.0.1 -U postgres -W -d nis2_registro -f sql/02_LOGICA_VISTA.sql`**

### 4. Inserisce i dati di test simulati 
**`psql -h 127.0.0.1 -U postgres -W -d nis2_registro -f sql/03_POPOLAMENTO_DATA.sql`**

**A questo punto, il database è pronto e funzionante.**

_(Opzionale) Pulisce il DB. Utile per i test._

**`psql -h 127.0.0.1 -U postgres -W -d nis2_registro -f sql/CLEANUP.sql`**

---

## 🔎 Verifica dei Dati (Test)
Dopo il popolamento, puoi eseguire lo script `04_REPORTS.sql` per verificare che i dati siano stati inseriti correttamente e testare le query di estrazione. Questo includerà anche le query di test per la Gap Analysis e la mappatura dei controlli.


### Esegui le query di test (l'output apparirà sul terminale)
**`psql -h 127.0.0.1 -U postgres -W -d nis2_registro -f sql/04_REPORTS.sql`**

## 📊 Esportazione dei Report (CSV)

Per generare i file CSV con le evidenze di conformità, esegui lo script di esportazione. Questo script usa il comando `\copy` di psql per generare **tre report distinti**:
1. L'elenco degli Asset Critici ACN
2. La mappatura dei controlli FNCS sugli Asset
3. La Gap Analysis (Profilo Attuale vs Target)

* Esegui lo script di esportazione
**`psql -h 127.0.0.1 -U postgres -W -d nis2_registro -f sql/05_EXPORT_DATA_ACN_CSV.sql`**

_Nota: Dovrai modificare i percorsi di output (es. **C:\export\asset_critici_acn.csv**) all'interno del file `05_EXPORT_DATA_ACN_CSV.sql` prima di eseguirlo, per farli puntare a una cartella esistente sul tuo computer._

---

## ⚠️ Limiti Noti e Considerazioni di Progetto 

### 1. Limiti

  * **Modalità Operativa:** L'esecuzione degli scripts è sequenziale e va eseguita dall'utente rispettando l'ordinamento `(es. 01_SCHEMA.sql, 02_LOGICA_VISTA.sql, 03_POPOLAMENTO_DATA.sql...)`. Questo approccio è soggetto a potenziali errori derivati dall'utente.
    
  * **Configurazione di Ambiente:** Il setup presuppone un ambiente di test locale (127.0.0.1) già preconfigurato con l’installazione di PostgreSQL.

  * **Esportazione Dati:** Lo script `05_EXPORT_DATA_ACN_CSV.sql` per l'esportazione dati obbliga l'utente a modificare manualmente i percorsi di salvataggio dei file all'interno dello script stesso specificando percorsi validi. 
  
  * **Sicurezza e Connessione:** Gli scripts assumono un utente postgres con privilegi elevati in un ambiente locale. Un ambiente di produzione richiederebbe ruoli con privilegi minimi (es. read-only per i report) e la gestione della rete (Indirizzi IP, firewall, SSL).

### 2. Considerazioni

  * **Progettazione delle Viste non Scalabile:** Alcune viste e query per la Gap Analysis contengono filtri "hard-coded" (es. `WHERE A.azienda_id = 1` o `WHERE tipo_profilo = 'Attuale'`), pensati per scopo dimostrativo in assenza di un'architettura multi-tenant complessa.

  * **Ottimizzazione degli Indici (Performance):** L'indice **`idx_asset_codice_critico`** (su `ASSET` (codice_asset, criticita)) non è ottimizzato per la query che dovrebbe supportare; si dovrebbe invertire l'ordine in `(criticita, codice_asset)`.