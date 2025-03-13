# The Routers

List of the Routers (functions as router):
- enterprise_router
- idmz_router
- industrial_core_switch
- assembly_switch 
- utilities_switch 
- packaging_switch 

Each router has a `.conf` file, build in the `network/docker-compose.yml`, and ARG (in the DockerFile and docker-compose) for the router config so it can be copied to the container's `/etc/frr` directory so the container has the configuration for the router.

