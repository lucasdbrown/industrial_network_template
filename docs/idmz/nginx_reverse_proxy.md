# Nginx Reverse Proxy in IDMZ documentation

- When a user accesses http://reverse_proxy/ind_core_switch, Nginx forwards/proxies the request to http://192.168.10.1/
- When a user accesses http://reverse_proxy/scada, Nginx forwards/proxies the request to http://192.168.30.13:8000/
- When a user accesses http://reverse_proxy/hmi, Nginx forwards/proxies the request to http://192.168.30.11:5000/
- When a user accesses http://reverse_proxy/historian, Nginx forwards/proxies the request to http://192.168.20.3:8086/

## Curling the Reverse Proxy to Test Access:
``` bash
curl http://reverse_proxy/ind_core_switch

curl http://reverse_proxy/scada

curl http://reverse_proxy/hmi

curl http://reverse_proxy/historian
```