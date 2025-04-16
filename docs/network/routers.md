# 🛠️ Docker Network Routing Architecture

## Overview
Routing is done in this project using frr routing containers and a controller container that updates the default route of all other containers when they turn on.
- All routers IP need to end in `.254`
- All firewall IP need to end in `.253`
- All Containers need in the compose `cap_add: NET_ADMIN`
---

## Routing Architecture

- All routers are labeled with `role=router`.
- Containers representing routers configure their static routes using `setup_routes.sh`.
- Each router is configured based on its hostname (e.g., `enterprise_router`, `idmz_router`).
- Networks `1` through `8` are reserved solely for routing between firewalls and routers.
- Non-router containers (such as sensors, apps, or services) must route traffic through their designated router by setting it as their **default gateway** and not through dockers router that will always be `.250` as the ip address.

---

## Requirements for Containers

- Every container **must** be given `cap_add: NET_ADMIN` in its Docker configuration to allow it to change network routes.
- Only containers **not** labeled `role=router` will have their routes adjusted automatically.

---

## Routing Controller

A container named `controller` listens for Docker container startup events. When a new container starts:

1. The controller:
   - Detects the container’s operating system.
   - Installs the `iproute2` utility if it is not already present.
   - Skips containers labeled `role=router`.

2. It then:
   - Determines the subnet the container is on.
   - Sets the default route for the container to use `.254` as its gateway on that subnet.

### Sample Behavior

If a container is on the `192.168.10.0/24` subnet, its default route will be:
```sh
ip route add default via 192.168.10.254
```

The controller gets the container's role and network from Docker events and uses `jq` to inspect metadata. It supports multiple Linux distros using preconfigured install commands.

> See `controller.sh` for implementation details. Located in `network/routing-controller/`

---

## Router Configuration via `setup_routes.sh`

Each router runs the `setup_routes.sh` script to configure its static routes. Routes vary by hostname.

### Example: `enterprise_router`

- Default gateway: `192.168.1.253`
- Routes added to internal networks via `192.168.2.253`:
```sh
for i in 3 4 5 6 7 8 20 30 39 33 32 31; do
  ip route add 192.168.$i.0/24 via 192.168.2.253
done
```

### Example: `idmz_router`

- Default route goes through: `192.168.2.253`

### Example: `industrial_core_switch`

- Default route: `192.168.4.253`
- Adds routes to OT networks via `192.168.5.253`:
```sh
for i in 6 7 8 33 32 31; do
  ip route add 192.168.$i.0/24 via 192.168.5.253
done
```

### Other Examples:

- `assembly_switch` → default via `192.168.6.253`
- `utilities_switch` → default via `192.168.7.253`
- `packaging_switch` → default via `192.168.8.253`
- `enterprise_firewall` → default via `192.168.0.254`
- `idmz_firewall` → default via `192.168.2.254`, internal routes via `192.168.4.254`
- `ot_firewall` → default via `192.168.5.254`, OT routes via `192.168.5.253`

If no match is found, the script exits with no routes.

> See `setup_routes.sh` for full route definitions. Located in `network/routers/`

---

## OSPF Configuration

Routers like `enterprise_router` also support dynamic routing via OSPF using FRRouting (FRR).

### Example Configuration (`enterprise_router.conf`)
```frr
router ospf
 log-adjacency-changes
 network 192.168.10.0/24 area 0
 network 192.168.20.0/24 area 0
```

This configuration enables OSPF adjacency logging and announces two internal networks to the routing domain.

> See `enterprise_router.conf` for a complete example.

---

## Boot Process Summary

1. **Routers start** and run `setup_routes.sh`.
2. **Controller starts** and waits for new containers.
3. **Non-router containers start**:
   - Controller installs `iproute2` if missing.
   - Controller sets the default route to their appropriate `.254` gateway.
4. All containers are now interconnected via routers and firewalls.

---

## Notes

- This system assumes consistent subnet structure (`192.168.X.0/24`) and that all routers use `.254` as their IP within a subnet.
- Controllers rely on container labels and hostnames to determine behavior—ensure these are configured correctly in the compose files.
- If your container distro is not supported in the controller install commands, you may need to manually extend `controller.sh` with the appropriate package manager command.


