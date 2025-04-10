# The Routers

List of the Routers (functions as router):
- enterprise_router
- idmz_router
- industrial_core_switch
- assembly_switch 
- utilities_switch 
- packaging_switch 

## How the Routers actually work with FRR_Routing
Each router has a `.conf` file in the `network/routers/` folder that defines a hostname, it being integrated with `vtysh`, and the networks it's apart of. Each router has a service configuration in the `docker-compose.yml` in the network folder. Each router uses the `start_frr.sh` script that starts frr_routing stack, makes the container behave like a real router (not just an idle shell), and delegates routing behavior per device. Each router uses the `setup_routes.sh` script that adds static default routes depending on which router is running, injects default routes before OSPF convergence is complete, and allows enclave switches to know where to send traffic “upstream.”

Example Router `docker-compose` service configuration for Router:
```yaml
example_router:
    build:
      context: ./routers
      dockerfile: DockerFile
    container_name: example_router
    hostname: example_router
    cap_add:
      - NET_ADMIN
      - SYS_ADMIN
    volumes:
      - ./routers/example_router.conf:/etc/frr/frr.conf:ro # mounts the router configuration in container
      - ./routers/daemons:/etc/frr/daemons:ro # mounts the daemons file in the container
      - ./routers/start_frr.sh:/mnt/start_frr.sh:ro # mounts the bash script to start frr_routing
      - ./routers/setup_routes.sh:/mnt/setup_routes.sh:ro # mounts the bash script to make static routes
    networks:
      example_network:
        ipv4_address: 192.168.90.10
    entrypoint: ["/bin/sh", "-c", "/start_frr.sh"] 
```

## Testing functionality of Routers and Switches

Have to run `vtysh` first for the other commands to work. It should give you a message like this after running `vtysh`:
```yaml
% Can't open configuration file /etc/frr/vtysh.conf due to 'No such file or directory'.

Hello, this is FRRouting (version 8.4_git).
Copyright 1996-2005 Kunihiro Ishiguro, et al.
```

```bash
vtysh 

show ip route

show ip ospf neighbor

show ip ospf interface
```

You can also check functionality without doing `vtysh`
```bash
vtysh -c "show ip route"

vtysh -c "show ip ospf database"
vtysh -c "show ip ospf neighbor"
vtysh -c "show ip ospf interface"
```
