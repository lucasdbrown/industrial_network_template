#!/bin/sh

echo "Configuring static routes..."

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1

HOST=$(hostname)

case "$HOST" in
  # Adds default route through IDMZ router.
  enterprise_router)
    ip route add 0.0.0.0/0 via 192.168.20.11
    ;;
  
  # Adds default route through Industrial Core Switch.
  idmz_router)
    ip route add 0.0.0.0/0 via 192.168.30.253
    ;;
  
  # No default route or custom static routes if handled via OSPF
  industrial_core_switch)
    ;;
  
  # Adds default route via Industrial Core Switch explicitly.
  assembly_switch)
    ip route add 0.0.0.0/0 via 192.168.30.253
    ;;

  # Adds default route via Industrial Core Switch explicitly.
  utilities_switch)
    ip route add 0.0.0.0/0 via 192.168.30.253
    ;;

  # Adds default route via Industrial Core Switch explicitly.
  packaging_switch)
    ip route add 0.0.0.0/0 via 192.168.30.253
    ;;
  
  *)
    echo "No explicit routes configured for $HOST"
    ;;
esac

echo "Static routing configuration applied for $HOST."