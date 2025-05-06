#!/bin/sh

# set -x
echo "Configuring static routes..."

HOST=$(hostname)

ip route del default

case "$HOST" in
  enterprise_router)
    # Makes default route out of the network
    ip route add default via 192.168.1.253

    # Addes all the other routes into the network
    for i in 3 4 5 6 7 8 20 30 30 33 32 31; do
      ip route add 192.168.$i.0/24 via 192.168.2.253 || true
    done
    ;;
  
  # Adds default route through IDMZ Firewall 
  idmz_router)
    ip route add default via 192.168.2.253
    ;;
  
  industrial_core_switch)
    ip route add default via 192.168.4.253

    for i in 6 7 8 33 32 31; do
      ip route add 192.168.$i.0/24 via 192.168.5.253 || true
    done
    ;;
  
  # Adds default route via Industrial Core Switch explicitly.
  assembly_switch)
    ip route add default via 192.168.6.253
    ;;

  # Adds default route via Industrial Core Switch explicitly.
  utilities_switch)
    ip route add default via 192.168.7.253
    ;;

  # Adds default route via Industrial Core Switch explicitly.
  packaging_switch)
    ip route add default via 192.168.8.253
    ;;

  enterprise_firewall)
    # Need to see if this container connects out to real world for internet access and what that route would be.
    ip route add default via 192.168.0.254
    
    # Flushs (all three included in flushing) existing rules
    iptables -F
    iptables -X
    iptables -Z

    # Default policies (Drops all traffic by default)
    iptables -P INPUT DROP # blocks all incoming traffic
    iptables -P FORWARD DROP # blocks all forwarded traffic by routers
    iptables -P OUTPUT ACCEPT  # Allows firewall to send outbound traffic

    # Allow Loopback (for local communication)
    iptables -A INPUT -i lo -j ACCEPT

    # Allows client_1 through the firewall
    iptables -A FORWARD -s 192.168.10.4 -j ACCEPT
    ;;

  idmz_firewall)
    ip route add default via 192.168.2.254

    for i in 5 6 7 8 20 31 32 33 30; do
      ip route add 192.168.$i.0/24 via 192.168.4.254 || true
    done

    # Flushs (all three included in flushing) existing rules
    iptables -F
    iptables -X
    iptables -Z

    # Default policies (Drops all traffic by default)
    iptables -P INPUT DROP # blocks all incoming traffic
    iptables -P FORWARD DROP # blocks all forwarded traffic by routers
    iptables -P OUTPUT ACCEPT  # Allows firewall to send outbound traffic

    # Allow Loopback (for local communication)
    iptables -A INPUT -i lo -j ACCEPT

    # Allows client_1 through the firewall
    iptables -A FORWARD -s 192.168.10.4 -j ACCEPT

    # Enterprise -> IDMZ (Allows only Web Proxy Access (on ports 80 & 443))
    iptables -A FORWARD -s 192.168.10.0/24 -d 192.168.20.2 -p tcp --dport 80 -j ACCEPT
    iptables -A FORWARD -s 192.168.10.0/24 -d 192.168.20.2 -p tcp --dport 443 -j ACCEPT

    # IDMZ -> Industrial (Allow Reverse Proxy & Updates)
    iptables -A FORWARD -s 192.168.20.2 -d 192.168.32.1 -p tcp --dport 8000 -j ACCEPT  # SCADA
    iptables -A FORWARD -s 192.168.20.2 -d 192.168.31.2 -p tcp --dport 5000 -j ACCEPT  # HMI

    # Industrial Segmentation: Allow SCADA to communicate with PLCs (Modbus, Port 502)
    iptables -A FORWARD -s 192.168.32.1 -d 192.168.30.20 -p tcp --dport 502 -j ACCEPT  # Modbus traffic allowed

    # Log dropped packets
    iptables -A FORWARD -j LOG --log-prefix "FW_DROP: " --log-level 4

    # Save logs explicitly (via rsyslog)
    echo ':msg, contains, "FW_DROP: " /var/log/iptables/iptables.log' > /etc/rsyslog.d/10-iptables.conf

    service rsyslog restart

    # Block Direct Enterprise to Industrial Access
    #iptables -A FORWARD -s 192.168.10.0/24 -d 192.168.30.0/24 -j DROP
    ;;

  ot_firewall)
    ip route add default via 192.168.5.254

    for i in 31 32 33; do
      ip route add 192.168.$i.0/24 via 192.168.5.253 || true
    done

    # Flushs (all three included in flushing) existing rules
    iptables -F
    iptables -X
    iptables -Z

    # Default policies (Drops all traffic by default)
    iptables -P INPUT DROP # blocks all incoming traffic
    iptables -P FORWARD DROP # blocks all forwarded traffic by routers
    iptables -P OUTPUT ACCEPT  # Allows firewall to send outbound traffic

    # Allow Loopback (for local communication)
    iptables -A INPUT -i lo -j ACCEPT

    # Allows client_1 through the firewall
    iptables -A FORWARD -s 192.168.10.4 -j ACCEPT
    ;;

  *)
    echo "No explicit routes configured for $HOST"
    exit 0
    ;;
esac

echo "Static routing configuration applied for $HOST."
