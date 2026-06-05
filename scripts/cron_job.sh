#!/bin/bash

echo "$(date): Alustame andmete uuendamist"

# 1. Tõmba uued andmed GitHubist → bronze
python3 /app/scripts/ingest.py

# 2. Upsert bronze → silver
psql "postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db:5432/${POSTGRES_DB}" \
    -f /app/scripts/04_incremental_upsert.sql

# 3. Gold vaade uueneb automaatselt (VIEW)

# 4. Käivita bronze kvaliteeditest
psql "postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db:5432/${POSTGRES_DB}" \
    -f /app/scripts/08_quality_tests_bronze.sql

# 5. Käivita silver kvaliteeditest
psql "postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db:5432/${POSTGRES_DB}" \
    -f /app/scripts/10_quality_tests_silver.sql

# 6. Käivita gold kvaliteeditest
psql "postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db:5432/${POSTGRES_DB}" \
    -f /app/scripts/11_quality_tests_gold.sql

echo "$(date): Andmete uuendamine lõpetatud"