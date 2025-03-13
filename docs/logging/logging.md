# How logging works on this Project

## Step by Step
1. Containers - generates logs from internal actions (e.g., HTTP requests, dropped packets, errors, etc...)
2. Mounted Volumes - Docker containers write logs explicitly to host-mounted folders (the log files are moved from the containers to the `/logging/logs` folder)
3. Filebeat	- Monitors these log files explicitly & forwards logs to Logstash
4. Logstash	- Receives and processes logs, parses into structured data
5. Elasticsearch - Stores structured logs into indices explicitly for querying
6. Kibana (http://localhost:5601) - Visualizes & enables querying and analysis of logs


