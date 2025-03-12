# Testing Logs

Be in network-god_debug and do `apk add curl`

### Testing the Firewall Logs
#### Ping (ICMP) blocked by default firewall rules
ping 192.168.20.3 

#### SSH attempt (port 22) to blocked subnet 
nc -vz 192.168.30.11 22

cat logging/logs/iptables/iptables.log

### Testing Reverse Proxy Logs
curl http://localhost/scada
curl http://localhost/hmi
curl http://localhost/historian
curl http://localhost/hmi

cat logging/logs/nginx/access.log