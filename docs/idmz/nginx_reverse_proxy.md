# Nginx Reverse Proxy in IDMZ documentation

- When a user accesses http://localhost/ind_core_switch, Nginx forwards/proxies the request to http://192.168.10.1/
- When a user accesses http://localhost/scada, Nginx forwards/proxies the request to http://192.168.32.1:8000/
- When a user accesses http://localhost/hmi, Nginx forwards/proxies the request to http://192.168.31.2:5000/
- When a user accesses http://localhost/historian, Nginx forwards/proxies the request to http://192.168.20.3:8086/

## Curling the Reverse Proxy to Test Access:
``` bash
curl http://localhost/ind_core_switch

curl http://localhost/scada

curl http://localhost/hmi

curl http://localhost/historian
```
