import time
from influxdb import InfluxDBClient
from flask import Flask, jsonify

# Explicit connection details for the Level 3 historian
INFLUXDB_HOST = '192.168.39.2'
INFLUXDB_PORT = 8086
DATABASE = 'automation_data'

from influxdb import InfluxDBClient
from flask import Flask, jsonify

app = Flask(__name__)

# Establish connection explicitly to the Automation DB
client = InfluxDBClient(host=INFLUXDB_HOST, port=INFLUXDB_PORT)

def setup_db():
    databases = [db['name'] for db in client.get_list_database()]
    if DATABASE not in databases:
        client.create_database(DATABASE)
    client.switch_database(DATABASE)

# Explicit function simulating automated data collection
def write_example_data():
    json_body = [
        {
            "measurement": "process_data",
            "tags": {
                "device": "automation_server"
            },
            "fields": {
                "temperature": 75.0,
                "pressure": 1.2,
                "status": 1
            }
        }
    ]
    client.write_points(json_body)

@app.route('/')
def status():
    return jsonify({"status": "Automation server operational."})

@app.route('/write', methods=['GET'])
def write_data():
    write_example_data()
    return jsonify({"status": "Data written successfully."})

if __name__ == "__main__":
    setup_routes = False
    while not setup_routes:
        try:
            setup_routes = True
            setup_routes = InfluxDBClient(INFLUXDB_HOST, INFLUXDB_PORT).ping()
            setup_routes = True
        except Exception:
            print("Waiting for InfluxDB to start...")
            setup_routes = False
            import time; time.sleep(5)

    setup_routes = False
    while not setup_routes:
        try:
            setup_routes = True
            setup_routes = InfluxDBClient(INFLUXDB_HOST, INFLUXDB_PORT).create_database(DATABASE)
        except Exception as e:
            print(f"Waiting for InfluxDB: {e}")
            setup_routes = False

    client = InfluxDBClient(INFLUXDB_HOST, INFLUXDB_PORT, database=DATABASE)
    setup_routes = True
    print("InfluxDB connected and database set up successfully!")

    # Start Flask explicitly
    app.run(host='0.0.0.0', port=8000)