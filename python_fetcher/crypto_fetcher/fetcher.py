import requests
import json
from datetime import datetime
from google.cloud import storage

def fetch_top_10_cryptos(gcs_bucket: str, output_prefix: str = "raw/") -> None:
    url = "https://api.coingecko.com/api/v3/coins/markets"
    params = {
        "vs_currency": "usd",
        "order": "market_cap_desc",
        "per_page": 10,
        "page": 1,
        "sparkline": "false"
    }

    response = requests.get(url, params=params)
    response.raise_for_status()
    data = response.json()

    timestamp = datetime.now(datetime.UTC).strftime("%Y-%m-%dT%H:%M:%SZ")
    filename = f"{output_prefix}crypto_prices_{timestamp}.json"

    # Save to GCS
    client = storage.Client()
    bucket = client.bucket(gcs_bucket)
    blob = bucket.blob(filename)
    blob.upload_from_string(
        data=json.dumps(data, indent=2),
        content_type="application/json"
    )

    print(f"Uploaded data to gs://{gcs_bucket}/{filename}")
