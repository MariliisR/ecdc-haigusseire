# Edenemisraport


## Mis on valmis

- [x] Docker Compose käivitab kõik teenused (andmebaas, CRON, Superset, ingest)
- [x] Andmeid saadakse allikast kätte (ECDC GitHub, 2 CSV faili, 84 570 rida)
- [x] Andmed laetakse automaatselt bronze kihti (tabel bronze.raw_ecdc_tests)
- [x] Transformatsioon töötab — bronze → silver (~43 000 rida, EU/EEA filtreeritud välja)
- [x] Gold vaade on olemas (weekly_virus_stats, sisaldab positivity_rate arvutust)
- [x] Audit skeem jälgib kustutatud kirjeid
- [x] Logimine lisatud — logifail salvestatakse logs/ingest.log
- [x] CRON seadistatud — käivitub igal laupäeval kell 6
- [x] Andmete laadimine käivitub automaatselt docker compose up käivitusel
- [x] Superset käivitub ja on ligipääsetav aadressil http://localhost:8088
- [x] Dashboard eksporditud ja importitakse automaatselt
- [x] 19 andmekvaliteedi testi — kõik passed (bronze, silver, gold)

Täpsem loetelu valmis kvaliteeditestides on Superset -> Dashboard_export -> README.md failis


## Järgmised sammud

- Video salvestamine ja esitamine Moodle'is (tähtaeg 07.06)
- Tagasiside teistele gruppidele (08.06–14.06)


## Mis takistab

  - Praegu pole blokeerivaid probleeme


## Kontrollpunkt

```bash
docker compose down -v
docker compose up -d --build
docker exec -it ecdc-haigusseire-db psql -U admin -d ecdc-haigusseire -c "SELECT COUNT(*) FROM silver.fact_respiratory_surveillance;"
docker exec -it ecdc-haigusseire-cron /bin/bash /app/scripts/cron_job.sh
docker exec -it ecdc-haigusseire-db psql -U admin -d ecdc-haigusseire -c "SELECT layer, test_name, status FROM quality.test_results ORDER BY layer, test_name;"
```

Oodatav tulemus:
- silver.fact_respiratory_surveillance sisaldab andmeid (≈ 46 000+ rida)
- Kõik kvaliteedikontrollid annavad staatuse `passed`
- Superset avaneb pordil 8088 ja kuvab dashboardi andmeid