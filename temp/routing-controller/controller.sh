#!/bin/sh
set -e
set -x

ROUTER_IP_NET1="192.168.1.254"
ROUTER_IP_NET2="192.168.2.254"

echo "[routing-controller] Starting..."

docker events --filter event=start |
while read -r event; do
  # extract container ID
  container_id=$(echo "$event" | awk '{print $NF}')
  echo "[routing-controller] New container started: $container_id"

  # wait briefly to avoid race condition with net setup
  sleep 1

  # inspect container

  name="${container_id#name=}"
  name="${name%)}"

  inspect=$(docker inspect "$name" 2>/dev/null)


  # skip FRR or routing controller itself
  if [[ "$name" == "frr-router" || "$name" == "controller" ]]; then
    echo "[routing-controller] Skipping $name"
    continue
  fi

  network_name=$(docker inspect $name | jq -r '.[0].NetworkSettings.Networks | keys[]')
  
  net_id=$(docker network inspect $network_name | jq -r '.[0].IPAM.Config[0].Subnet')


  subnet=$(echo "$net_id" | awk -F'[./]' '{print $3}')


  docker exec $name ip route del default
  docker exec $name ip route add default via 192.168.$subnet.254
  echo "$name added to the $subnet subnet route"


  # # check networks
  # if echo "$inspect" | jq -r '.[0].NetworkSettings.Networks["net1"]' > /dev/null; then
  #   echo "[routing-controller] Setting default route for $name on net1"
  #   docker exec "$container_id" ip route del default
  #   docker exec "$container_id" ip route add default via "$ROUTER_IP_NET1"
  # fi
  #
  # if echo "$inspect" | jq -r '.[0].NetworkSettings.Networks["net2"]' > /dev/null; then
  #   echo "[routing-controller] Setting default route for $name on net2"
  #   docker exec "$container_id" ip route del default
  #   docker exec "$container_id" ip route add default via "$ROUTER_IP_NET2"
  # fi
done

