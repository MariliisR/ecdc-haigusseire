# MAMM — Euroopa hingamisteede viiruste hooajaline seire

> **Juhend:** Asenda kõik nurksulgudes vormid oma sisuga enne esitamist. Kustuta see juhendrida.

## Äriküsimus

Jälgime kolme hingamisteede haiguse (Influenza, RSV, SARS-CoV-2) levikut Euroopa riikides, et aidata inimestel hinnata haigusaktiivsust ning teha teadlikumaid reisimisotsuseid.

**Mõõdikud:**

1. Positiivsete testide arv nädalate lõikes riigi ja haiguse kaupa
    * Arvutame iga nädala kohta positiivsete hingamisteede viiruse testide koguarvu Euroopa riikides.
2. Positiivsete testide määr riikide lõikes
    * Arvutame positiivsete testide osakaalu kõigist tehtud testidest iga riigi kohta nädalapõhiselt.
3. Positiivsete testide määr viirusetüüpide lõikes
    * Võrdleme Influenza, RSV ja SARS-CoV-2 positiivsete testide määra riikide ja nädalate lõikes.

## Arhitektuur

```mermaid
flowchart LR
    source[GITHUB EU-CDC/Respiratory_viruses_weekly_data] --> ingest[Python ingest]
    ingest --> staging[(PostgreSQL_staging)]
    staging --> transform[SQL transformatsioon]
    transform --> mart[(PostgreSQL mart)]
    mart --> dashboard[Apache Superset]
    mart --> quality[Andmekvaliteedi testid]
    scheduler[Cron scheduler] --> ingest
```

Täpsem kirjeldus: [`docs/arhitektuur.md`](docs/arhitektuur.md)

## Andmestik

| Allikas | Tüüp | Ajas muutuv? | Roll |
|---------|------|--------------|------|
| [ECDC respiratory virus surveillance data] | [CSV] | Jah, [nädalapõhiselt, laupäeviti] | Põhiandmevoog |
| [Teise allika nimi] | [seed / dim-tabel] | Ei, staatiline | Kõrvaltabel |

## Stack

| Komponent | Tööriist |
|-----------|---------|
| Sissevõtt | [Python] |
| Transformatsioon | [SQL] |
| Andmehoidla | PostgreSQL |
| Näidikulaud | [Apache Superset] |
| Orkestreerimine | [cron] |

## Käivitamine

```bash
# 1. Klooni repo ja liigu kausta
git clone <repo-url>
cd <projekti-kaust>

# 2. Kopeeri keskkonnamuutujad
cp .env.example .env
# Muuda .env failis paroolid ja muud seaded vastavalt vajadusele

# 3. Käivita teenused
docker compose up -d --build

# 4. [Vabatahtlik: käivita sissevõtt käsitsi esimesel korral]
# docker compose exec pipeline python scripts/run_pipeline.py run-all
```

Airflow (kui kasutatakse): http://localhost:8080 (kasutaja: airflow / parool: airflow)
Näidikulaud: http://localhost:[PORT]

## Saladused ja konfiguratsioon

Kõik saladused (paroolid, API võtmed, andmebaasi URL-id) on `.env` failis. Repos on ainult `.env.example`, mis näitab vajalike muutujate struktuuri ilma tegelike väärtusteta. Päris `.env` faili ei tohi GitHubi panna - see on `.gitignore`-s.

Vajalikud muutujad:

| Muutuja | Tähendus | Näide |
|---------|----------|-------|
| `DB_PASSWORD` | PostgreSQL parool | (saladus) |
| `[teised]` | ... | ... |

## Andmevoog lühidalt

1. **Sissevõtt** — Pythoni ingest2-skript laeb ECDC seireandmed alla ning salvestab need Bronze kihti.
2. **Laadimine** — Toorandmed salvestatakse PostgreSQL Bronze skeemi
3. **Transformatsioon** — Silver kihis andmed puhastatakse ja normaliseeritakse.
                        — Gold kihis arvutatakse nädalapõhised agregeeritud mõõdikud.
4. **Testimine** — [Mitu] andmekvaliteedi testi kontrollivad korrektsust
5. **Näidikulaud** — Apache Superset visualiseerib haigusaktiivsuse trendid ja positiivsuse määrad.

## Andmekvaliteedi testid

Projekt kontrollib järgmist:

1. [Test 1 - nt: kasutajate ID on unikaalne]
2. [Test 2 - nt: tellimuse summa pole null]
[yearweek väärtus peab vastama ISO nädalavormingule]
[countryname ei tohi olla NULL]

Testide tulemused: [kuhu salvestatakse / kuidas vaadata]

## Projekti struktuur

```
.
├── README.md
├── compose.yml
├── .env.example
├── .gitignore
├── docs/
│   ├── arhitektuur.md      ← nädal 1 väljund
│   └── progress.md         ← nädal 2 väljund
└── ...                     ← ülejäänud projektifailid
```

## Kokkuvõte, puudused ja võimalikud edasiarendused

**Kokkuvõte:**
- Valmis on:
    * ingest pipeline
    * Bronze / Silver / Gold kihid
    * PostgreSQL andmeladu
    * [nädalapõhised mõõdikud]
    * [Superseti dashboardid]

**Puudused:**
- [Loetle ausalt, mis jäi tegemata - see ei mõjuta hinnet negatiivselt, vaid aitab hinnata]
- [automaatseid data quality alert’eid veel ei ole]
- [incremental processing puudub]
- [dashboard refresh toimub käsitsi]

**Mis edasi:**
- [Mida tahaksid edasi teha, kui aega oleks rohkem]

## Meeskond

| Nimi | Roll |
|------|------|
| Mariliis | andmeallika omanik |
| Madli | transformatsioonide omanik |
| Mirell | andmekvaliteedi omanik |
| Annika | näidikulaua omanik |
