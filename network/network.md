# Running the network as a stack

Dedicated folder for a centralized `docker-compose.yml` for network configuration

Allows external network referencing in your other Docker Compose files, instead of defining the networks in each compose file.

Have to run the `docker-compose.yml` in this folder before the others.