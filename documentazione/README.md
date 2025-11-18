# 🚀 Registro Asset e Servizi (Conformità NIS2/ACN)

Questo progetto contiene lo schema di un database PostgreSQL e gli script SQL necessari per creare, popolare, gestire ed esportare un registro di asset e servizi per una determinata azienda, come richiesto dalla direttiva NIS2 e per il reporting ACN.

Il progetto è diviso in due parti principali:

1.  **`sql/`**: Contiene tutti gli script SQL per creare, popolare, interrogare ed esportare i dati del database. 
2.  **`documentazione/`**: Contiene  il Data Dictionary e l'ER Diagram. 

---

## 🛠️ Prerequisiti

Prima di iniziare, assicurati di avere installato e configurato:
* Un server **PostgreSQL** (v12+) in esecuzione.
* Un utente con privilegi di amministratore (es. postgres)
* Un database esistente di manutenzione
* **`psql`** (il client a riga di comando di PostgreSQL) deve essere installato e accessibile nel `PATH` del sistema. 

---

## ⚙️ Installazione e Setup del Database

Questi script sono pensati per essere eseguiti dal client `psql`. **L'ordine di esecuzione è fondamentale.** 

#### Questa è la stringa da utilizzare per eseguire gli scripts

*psql -h [IP_LOCALHOST] -U [UTENTE_AMMINISTRATORE] -W -d [DATABASE_DI_MANUNTENZIONE] -f [PERCORSO_DOVE_SI_TROVA_LO_SCRIPT]/00_CREA_DB.sql`*

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
Dopo il popolamento, puoi eseguire lo script `04_REPORTS.sql` per verificare che i dati siano stati inseriti correttamente e testare le query di estrazione.


### Esegui le query di test (l'output apparirà sul terminale)
**`psql -h 127.0.0.1 -U postgres -W -d nis2_registro -f sql/04_REPORTS.sql`**

## 📊 Esportazione del Report ACN (CSV)

Per generare il file CSV con l'elenco degli asset critici, esegui lo script di esportazione. Questo script usa il comando `\copy` di psql per generare il report. 
* Esegui lo script di esportazione
**`psql -h 127.0.0.1 -U postgres -W -d nis2_registro -f sql/05_EXPORT_DATA_ACN_CSV.sql`**

_Nota: Dovrai modificare il percorso di output **(C:/export/asset_critici_acn.csv)** all'interno del file `05_EXPORT_DATA_ACN_CSV.sql` prima di eseguirlo, per farlo puntare a una cartella esistente sul tuo computer._

---

## ⚠️ Limiti Noti e Considerazioni di Progetto 

### 1. Limiti

  * **Modalità Operativa:** L'esecuzione degli scripts è sequenziali e va eseguito dall'utente rispetto l'ordinamento `(es. 01_SCHEMA.sql, 02_LOGICA_VISTA.sql, 03_POPOLAMENTO_DATA.sql...)`. Questo approccio è soggetto a potenziali errori derivati dall'utente   
    
  * **Configurazione di Ambiente:** Il setup presuppone un ambiente di test locale (127.0.0.1) già preconfigurato con l’installazione di PostgreSQL.

  * **Esportazione Dati:** Lo script `05_EXPORT_DATA_ACN_CSV.sql` per l'esportazione dati obbliga l'utente a modificare manualmente il percorso di salvataggio del file all'interno dello script stesso specificando un percorso valido. 
  
  * **Sicurezza e Connessione:** Gli scripts assumono un utente postgres con privilegi elevati in un ambiente locale. Un ambiente di produzione richiederebbe ruoli con privilegi minimi (es. read-only per i report) e la
    gestione   della rete (Indirizzi IP, firewall, SSL).

### 2. Considerazioni

  * **Progettazione della Vista (View) non Scalabile:** La vista principale **`report_asset_critici_acn`** (nello script `02_LOGICA_VISTA.sql`) contiene un filtro "hard-coded" (`WHERE A.azienda_id = 1`).

  * **Ottimizzazione degli Indici (Performance):** L'indice **`idx_asset_codice_critico`** (su `ASSET` (codice_asset, criticita)) non è ottimizzato per la query che dovrebbe supportare.

