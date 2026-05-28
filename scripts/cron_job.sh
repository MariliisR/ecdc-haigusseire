#!/bin/bash

echo "$(date): Alustame andmete uuendamist"

# 1. Tõmba uued andmed GitHubist → bronze
python3 /app/scripts/ingest2.py

# 2. Upsert bronze → silver
psql "postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db:5432/${POSTGRES_DB}" \
    -f /app/scripts/04_incremental_upsert.sql

# 3. Käivita kvaliteeditest
psql "postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db:5432/${POSTGRES_DB}" \
    -f /app/scripts/08_quality_tests.sql

echo "$(date): Andmete uuendamine lõpetatud"