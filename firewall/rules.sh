#!/bin/bash

# Flush existing rules
iptables -F
iptables -X
iptables -Z

# Default policies (Drop all traffic by default)
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT  # Allow outbound traffic

# Allow Loopback
iptables -A INPUT -i lo -j ACCEPT

# 🔹 Enterprise to IDMZ (Allow only Web Proxy Access)
iptables -A FORWARD -s 192.168.10.0/24 -d 192.168.20.2 -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -s 192.168.10.0/24 -d 192.168.20.2 -p tcp --dport 443 -j ACCEPT

# 🔹 IDMZ to Industrial (Allow Reverse Proxy & Updates)
iptables -A FORWARD -s 192.168.20.2 -d 192.168.30.13 -p tcp --dport 8000 -j ACCEPT  # SCADA
iptables -A FORWARD -s 192.168.20.2 -d 192.168.30.11 -p tcp --dport 5000 -j ACCEPT  # HMI

# 🔹 Industrial Segmentation (Allow SCADA to PLCs, Block Everything Else)
iptables -A FORWARD -s 192.168.30.13 -d 192.168.30.20 -p tcp --dport 502 -j ACCEPT  # Modbus
iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.30.0/24 -j DROP  # Block unauthorized lateral movement

# Logging Dropped Packets (For Debugging)
iptables -A FORWARD -j LOG --log-prefix "FW_DROP: " --log-level 4
