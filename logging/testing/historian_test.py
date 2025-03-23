# Querying the time processed data in InfluxDB
import time
import requests
import json

# InfluxDB details
INFLUXDB_URL = "http://192.168.39.3:8086/query"
DATABASE = "historian"
QUERY = 'SELECT * FROM "scada_lts" LIMIT 5'

def query_influxdb():
    params = {"db": DATABASE, "q": QUERY}
    response = requests.get(INFLUXDB_URL, params=params)
    data = response.json()
    print(json.dumps(data, indent=2))

if __name__ == "__main__":
    print("Waiting for data to populate...")
    time.sleep(15)
    query_influxdb()
