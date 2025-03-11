#!/bin/sh

echo "Configuring static routes..."

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1

# Enterprise Router: Route IDMZ and Industrial through IDMZ Router
if [ "$(hostname)" = "enterprise_router" ]; then
    ip route add 192.168.20.0/24 via 192.168.20.1  # IDMZ
    ip route add 192.168.30.0/24 via 192.168.20.2  # Industrial (via IDMZ)
fi

# IDMZ Router: Route Industrial Zone
if [ "$(hostname)" = "idmz_router" ]; then
    ip route add 192.168.30.0/24 via 192.168.30.1  # Industrial Zone
fi

echo "Routing configuration applied."