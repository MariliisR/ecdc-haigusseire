# Edenemisraport

> **Juhend:** See fail on projektitöö teise nädala väljund. Uuenda lühidalt iga esitamise eel. Kustuta see juhendrida.

## Mis on valmis

- [x] Docker Compose käivitab andmebaasi ja CRON konteineri
- [x] Andmeid saadakse allikast kätte (ECDC GitHub, 2 CSV faili, 84 570 rida)
- [x] Andmed laetakse bronze kihti (tabel bronze.raw_ecdc_tests)
- [x] Logimine lisatud — logifail salvestatakse logs/ingest.log
- [x] CRON seadistatud — käivitub igal laupäeval kell 6
- [ ] Vähemalt üks transformatsioon toimib
- [ ] Vähemalt üks näidikulaud on nähtaval
- [ ] Vähemalt üks andmekvaliteedi test läbib

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
docker compose up -d
python3 scripts/ingest2.py
```

Oodatav tulemus: "Andmed laaditud tabelisse bronze.raw_ecdc_tests (84570 rida)"
