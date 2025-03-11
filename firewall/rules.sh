#!/bin/bash

# Flushs existing rules
iptables -F
iptables -X
iptables -Z

# Default policies (Drops all traffic by default)
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT  # Allows outbound traffic

# Allow Loopback
iptables -A INPUT -i lo -j ACCEPT

# Enterprise -> IDMZ (Allows only Web Proxy Access)
iptables -A FORWARD -s 192.168.10.0/24 -d 192.168.20.2 -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -s 192.168.10.0/24 -d 192.168.20.2 -p tcp --dport 443 -j ACCEPT

# IDMZ -> Industrial (Allow Reverse Proxy & Updates)
iptables -A FORWARD -s 192.168.20.2 -d 192.168.30.13 -p tcp --dport 8000 -j ACCEPT  # SCADA
iptables -A FORWARD -s 192.168.20.2 -d 192.168.30.11 -p tcp --dport 5000 -j ACCEPT  # HMI

# Logging Dropped Packets (For Debugging)
iptables -A FORWARD -j LOG --log-prefix "FW_DROP: " --log-level 4
