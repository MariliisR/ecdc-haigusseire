# Edenemisraport

## Mis on valmis

- [x] Docker Compose käivitab kõik teenused (andmebaas, CRON, Superset)
- [x] Andmeid saadakse allikast kätte (ECDC GitHub, 2 CSV faili, 84 570 rida)
- [x] Andmed laetakse bronze kihti (tabel bronze.raw_ecdc_tests)
- [x] Transformatsioon töötab — bronze → silver (46 327 rida)
- [x] Gold vaade on olemas (23 801 rida, weekly_virus_stats)
- [x] Logimine lisatud — logifail salvestatakse logs/ingest.log
- [x] CRON seadistatud — käivitub igal laupäeval kell 6
- [x] Superset käivitub ja on ligipääsetav aadressil http://localhost:8088
- [x] Vähemalt üks näidikulaud on nähtaval
- [x] Andmekvaliteedi testid

[Täpsusta lühidalt, mis täpselt valmis on]

## Järgmised sammud

- Lisada bronze, silver ja gold kvaliteedikontrollid automaatsesse töövoogu.
- Supersetis dashboardi täiendamine 1–2 sisulise graafikuga.
- [Kolmas tegevus]

## Mis takistab

- [Probleem 1 — näiteks: API tagastab vigaseid väärtusi ühes linnas]
- [Probleem 2 — või: "Praegu pole blokeerivaid probleeme"]

## Kontrollpunkt

```bash
docker compose down -v
docker compose up -d --build

docker exec -it ecdc-haigusseire-db psql -U admin -d ecdc-haigusseire -c "SELECT COUNT(*) FROM silver.fact_respiratory_surveillance;"

docker exec -i ecdc-haigusseire-db psql -U admin -d ecdc-haigusseire < scripts/08_quality_tests_bronze.sql

docker exec -i ecdc-haigusseire-db psql -U admin -d ecdc-haigusseire < scripts/10_quality_tests_silver.sql

docker exec -i ecdc-haigusseire-db psql -U admin -d ecdc-haigusseire < scripts/11_quality_tests_gold.sql
```

Oodatav tulemus:
- silver.fact_respiratory_surveillance sisaldab andmeid (≈ 46 000+ rida).
- gold.weekly_virus_stats sisaldab andmeid.
- Quality testid salvestatakse tabelisse quality.test_results.
- Kõik Bronze, Silver ja Gold kvaliteedikontrollid annavad staatuse `passed`.
- Superset avaneb pordil 8088 ja kuvab dashboardi andmeid.

