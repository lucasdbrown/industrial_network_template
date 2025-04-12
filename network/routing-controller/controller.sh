#!/bin/sh


set -e
# set -x

echo "[routing-controller] Starting..."

docker events --filter event=start |
while read -r event; do
  # extract container ID
  container_id=$(echo "$event"  | awk -F'name=' '{print $2}' | cut -d',' -f1 | cut -d')' -f1)
  echo "[routing-controller] New container started: $container_id"

  # wait briefly to avoid race condition with net setup
  sleep 1

  # Gets name of container
  name="${container_id#name=}"
  name="${name%)}"

  # Gets the role of the container
  role=$(docker inspect $name | jq -r '.[0].Config.Labels["role"]')

  # skip FRR or routing controller itself
  if [[ $role == "router" || $name == "god_debug" ]]; then
    echo "[routing-controller] Skipping $name"
    continue
  fi

  network_name=$(docker inspect $name | jq -r '.[0].NetworkSettings.Networks | keys[]')
  
  net_id=$(docker network inspect $network_name | jq -r '.[0].IPAM.Config[0].Subnet')


  subnet=$(echo "$net_id" | awk -F'[./]' '{print $3}')


  docker exec $name ip route del default
  docker exec $name ip route add default via 192.168.$subnet.254
  echo "$name added to the $subnet subnet route"

done
