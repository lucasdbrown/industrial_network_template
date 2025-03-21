# How logging works on this Project

## Step by Step
1. Containers - generates logs from internal actions (e.g., HTTP requests, dropped packets, errors, etc...)
2. Mounted Volumes - Docker containers write logs explicitly to host-mounted folders (the log files are moved from the containers to the `/logging/logs` folder)
3. Filebeat	- Monitors these log files explicitly & forwards logs to Logstash
4. Logstash	- Receives and processes logs, parses into structured data
5. Elasticsearch - Stores structured logs into indices explicitly for querying
6. Kibana (http://localhost:5601) - Visualizes & enables querying and analysis of logs


## Logging Architecture

| **Network Zone**               | **Log Source**                              | **Storage Location**                     | **Forwarding Method**        | **Final Log Processing** |
| ------------------------------ | ------------------------------------------- | ---------------------------------------- | ---------------------------- | ------------------------ |
| Industrial Network (Level 0-2) | PLCs, HMIs, Sensors, Industrial Firewalls   | Industrial File Server (Samba, FTP, NFS) | Filebeat/Syslog → Level 3    | ELK (via Logstash)       |
| Site Operations (Level 3)      | SCADA, Virtual Desktops, Automation Servers | Level 3 File Server (Samba, FTP)         | Filebeat/Syslog → IDMZ       | ELK (via Logstash)       |
| Industrial DMZ (IDMZ)          | Firewalls, Jump Hosts, VPN Access Logs, IDS | IDMZ File Server (Samba, FTP)            | Filebeat/Syslog → Enterprise | ELK or SIEM              |
| Enterprise IT (Level 4-5)      | Active Directory, ERP, User Logs            | Enterprise File Server (NAS/SIEM)        | Filebeat/Syslog              | ELK or Splunk            |
