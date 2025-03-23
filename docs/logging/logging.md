# How logging works on this Project

## Step by Step
1. Containers - generates logs from internal actions (e.g., HTTP requests, dropped packets, errors, etc...)
2. Mounted Volumes - Docker containers write logs explicitly to host-mounted folders (the log files are moved from the containers to the `/logging/logs` folder)
3. Filebeat	- Monitors these log files explicitly & forwards logs to Logstash
4. Logstash	- Receives and processes logs, parses into structured data
5. Elasticsearch - Stores structured logs into indices explicitly for querying
6. Kibana (http://localhost:5601) - Visualizes & enables querying and analysis of logs

- ELK (Elasticsearch, Logstash, Kibana): captures operational and security logs.
- InfluxDB + Grafana + Telegraf: collects real-time industrial process data.

## Industrial Process Data Flow (InfluxDB/Grafana):

[ Assembly Enclave (192.168.31.0) ]
PLC (192.168.31.6) ──┐
Node-RED (192.168.31.4) ──┤
OpenPLC HMI (192.168.31.2) ──┤
                             │ (MQTT, Modbus)
                             ├─▶ Telegraf Forwarder (192.168.32.7) ──▶ InfluxDB AutomationDB (192.168.39.3)
[ Utilities Enclave (192.168.32.0) ]      │
BACnet (192.168.32.4) ────────────────────┘
SCADA-LTS (192.168.32.2) via MQTT/API─────┘

[ Site Operations (192.168.39.0) ]
AutomationDB (InfluxDB) ──▶ Grafana (Enterprise 192.168.10.15)
                           │
                           ▼ (Processed Data via Telegraf or OPC UA/MQTT)
Enterprise Historian DB (192.168.39.X)

## Operational Logs Flow (ELK Stack):

[ Assembly, Utilities, Packaging Enclaves (192.168.31.0 - 33.0) ]
Services containers logs (/var/lib/docker/containers/*/*.log) ──┐
Barcode API logs (192.168.33.2) ──────────▶ Log file ───────────┤
RFID Database (192.168.33.3) logs ───────────────────────────────┤
                                                                 │
Filebeat (192.168.31.7) ────────────────────────────────────────┘
                               │
                               ▼ (beats input:5000)
Logstash (192.168.20.8 & 192.168.39.6) ────▶ Elasticsearch (192.168.20.7)
                                                │
                                                ▼
Kibana (192.168.10.6) ────── Dashboards for security & operational logs.
