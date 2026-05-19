import pandas as pd
import psycopg2
from sqlalchemy import create_engine
import os
from dotenv import load_dotenv

# Lae .env failist andmebaasi andmed
load_dotenv()

# ECDC andmete URL
URL = "https://raw.githubusercontent.com/EU-ECDC/Respiratory_viruses_weekly_data/refs/heads/main/data/SARITestsDetectionsPositivity.csv"

def fetch_data():
    """Tõmbab ECDC andmed GitHubist"""
    print("Tõmban andmeid ECDC GitHubist...")
    df = pd.read_csv(URL)
    print(f"Andmed tõmmatud: {len(df)} rida")
    return df

def load_to_db(df):
    """Laadib andmed PostgreSQL andmebaasi"""
    db_url = f"postgresql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
    engine = create_engine(db_url)
    
    df.to_sql(
        name="raw_ecdc_sari",
        con=engine,
        schema="bronze",
        if_exists="replace",
        index=False
    )
    print(f"Andmed laaditud andmebaasi: {len(df)} rida")

if __name__ == "__main__":
    df = fetch_data()
    print(df.head())
    print(df.shape)
    # load_to_db(df)  # Aktiveeritakse kui Docker ja PostgreSQL on seadistatud