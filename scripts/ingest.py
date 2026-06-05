from sqlalchemy import create_engine, text
import pandas as pd
import os
from dotenv import load_dotenv
import logging

# Seadista logimine
os.makedirs("logs", exist_ok=True)
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
    handlers=[
        logging.FileHandler("logs/ingest.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Lae .env fail
load_dotenv()

# ECDC CSV failid
URLS = [
    "https://raw.githubusercontent.com/EU-ECDC/Respiratory_viruses_weekly_data/refs/heads/main/data/sentinelTestsDetectionsPositivity.csv",
    "https://raw.githubusercontent.com/EU-ECDC/Respiratory_viruses_weekly_data/refs/heads/main/data/SARITestsDetectionsPositivity.csv"
]

def fetch_all_data():
    """Tõmbab kõik CSV failid ja ühendab üheks DataFrame'iks"""
    dataframes = []
    for url in URLS:
        logger.info(f"Tõmban andmeid: {url}")
        df = pd.read_csv(url)
        logger.info(f"Loetud {len(df)} rida")
        dataframes.append(df)
    combined_df = pd.concat(dataframes, ignore_index=True)
    logger.info(f"Kokku ridu: {len(combined_df)}")
    return combined_df

def load_to_db(df):
    """Laeb DataFrame'i PostgreSQL andmebaasi"""
    db_url = (
        f"postgresql://{os.getenv('POSTGRES_USER')}:"
        f"{os.getenv('POSTGRES_PASSWORD')}@db:5432/"
        f"{os.getenv('POSTGRES_DB')}"
    )
    engine = create_engine(db_url)
    with engine.connect() as conn:
        conn.execute(text("CREATE SCHEMA IF NOT EXISTS bronze"))
        conn.commit()
    df.to_sql(
        name="raw_ecdc_tests",
        con=engine,
        schema="bronze",
        if_exists="replace",
        index=False
    )
    logger.info(f"Andmed laaditud tabelisse bronze.raw_ecdc_tests ({len(df)} rida)")

if __name__ == "__main__":
    df = fetch_all_data()
    logger.info(f"Andmete eelvaade:\n{df.head()}")
    logger.info(f"DataFrame kuju: {df.shape}")
    load_to_db(df)