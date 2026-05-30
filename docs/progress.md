# Edenemisraport

> **Juhend:** See fail on projektitöö teise nädala väljund. Uuenda lühidalt iga esitamise eel. Kustuta see juhendrida.

## Mis on valmis

- [x] Docker Compose käivitab kõik teenused (andmebaas, CRON, Superset)
- [x] Andmeid saadakse allikast kätte (ECDC GitHub, 2 CSV faili, 84 570 rida)
- [x] Andmed laetakse bronze kihti (tabel bronze.raw_ecdc_tests)
- [x] Transformatsioon töötab — bronze → silver (46 327 rida)
- [x] Gold vaade on olemas (23 801 rida, weekly_virus_stats)
- [x] Logimine lisatud — logifail salvestatakse logs/ingest.log
- [x] CRON seadistatud — käivitub igal laupäeval kell 6
- [x] Superset käivitub ja on ligipääsetav aadressil http://localhost:8088
- [ ] Vähemalt üks näidikulaud on nähtaval
- [ ] Andmekvaliteedi testid

[Täpsusta lühidalt, mis täpselt valmis on]

## Järgmised sammud

- [Esimene tegevus, mis ees ootab]
- [Teine tegevus]
- [Kolmas tegevus]

## Mis takistab

- [Probleem 1 — näiteks: API tagastab vigaseid väärtusi ühes linnas]
- [Probleem 2 — või: "Praegu pole blokeerivaid probleeme"]

## Kontrollpunkt

```bash
docker compose up -d --build
python3 scripts/ingest2.py
docker exec -i ecdc-haigusseire-db psql -U admin -d ecdc-haigusseire < scripts/04_incremental_upsert.sql
docker exec -it ecdc-haigusseire-db psql -U admin -d ecdc-haigusseire -c "SELECT COUNT(*) FROM gold.weekly_virus_stats;"
```

Oodatav tulemus: `count = 23801`
