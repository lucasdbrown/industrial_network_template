#!/bin/bash


set -x
set +e

echo "[routing-controller] Starting..."

declare -A install_cmds

install_cmds=(
  [alpine]="apk add --no-cache iproute2"
  [debian]="apt update && apt install -y iproute2"
  [ubuntu]="apt update && apt install -y iproute2"
  [centos]="yum install -y iproute"
  [fedora]="dnf install -y iproute"
  [arch]="pacman -Sy --noconfirm iproute2"
  [opensuse]="zypper install -y iproute2"
  [ol]="microdnf install -y iproute"
)

# telegraf
# rfid_database
# barcode_scanner


docker events --filter event=start |
while read -r event; do
  # extract container ID
  container_id=$(echo "$event"  | awk -F' name=' '{print $2}' | cut -d',' -f1 | cut -d')' -f1)
  echo "[routing-controller] New container started: $container_id"

  # wait briefly to avoid race condition with net setup
  sleep 1


  # Gets the role of the container
  role=$(docker inspect $container_id | jq -r '.[0].Config.Labels["role"]')


  # skip FRR or routing controller itself
  if [[ $role == "router" || $container_id == "god_debug" ]]; then
    echo "[routing-controller] Skipping $container_id"
    continue
  fi


  # if docker exec "$container_id" ip >/dev/null 2>&1; then
  #   echo "[$container_id] 'ip' already installed."
  #   continue
  # fi

  distro=$(docker exec "$container_id" sh -c 'cat /etc/os-release 2>/dev/null' | grep -E '^ID=' | cut -d= -f2 | tr -d '"')

  echo "[$container_id] Detected distro: $distro"

  install_cmd="${install_cmds[$distro]}"

  if [ -n "$install_cmd" ]; then
    echo "[$container_id] Installing iproute2 using: $install_cmd"
    docker exec -u root "$container_id" sh -c "$install_cmd"
  else
    echo "[$container_id] No install command found for distro: $distro"
  fi

  network_name=$(docker inspect $container_id | jq -r '.[0].NetworkSettings.Networks | keys[]')
  
  net_id=$(docker network inspect $network_name | jq -r '.[0].IPAM.Config[0].Subnet')


  subnet=$(echo "$net_id" | awk -F'[./]' '{print $3}')


  docker exec -u root $container_id ip route del default
  docker exec -u root $container_id ip route add default via 192.168.$subnet.254
  echo "$container_id added to the $subnet subnet route"

done
