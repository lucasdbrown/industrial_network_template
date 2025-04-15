#!/bin/sh

echo "[+] Starting router: $HOSTNAME"

# Enable IP forwarding (may still error if not privileged)
# sysctl -w net.ipv4.ip_forward=1 || echo "[!] Could not enable IP forwarding."

# Start daemons (config already mounted into place)
echo "[+] Starting FRR daemons..."
/usr/lib/frr/frrinit.sh start

# Apply static routes
/mnt/setup_routes.sh

# Keep container alive
tail -f /dev/null
