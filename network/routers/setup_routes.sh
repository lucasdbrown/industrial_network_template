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
    for i in 3 4 5 6 7 8 20 30 39 33 32 31; do
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
    ;;

  idmz_firewall)
    ip route add default via 192.168.2.254

    for i in 5 6 7 8 20 31 32 33 39; do
      ip route add 192.168.$i.0/24 via 192.168.4.254 || true
    done
    ;;

  ot_firewall)
    ip route add default via 192.168.5.254

    for i in 31 32 33; do
      ip route add 192.168.$i.0/24 via 192.168.5.253 || true
    done
    ;;

  *)
    echo "No explicit routes configured for $HOST"
    exit 0
    ;;
esac

echo "Static routing configuration applied for $HOST."
