# Docker Guide

This document provides a practical quick-reference for working with Docker and Docker Compose.  
For an introduction to container concepts, see the [Docker Docs: Get Started](https://docs.docker.com/get-started/).  

---

## Core Docker Commands

### Build an Image
`docker build -t <image-name>:<tag> <path-to-dockerfile>`

- `-t` : Assigns a name and optional tag (default `latest`).  
- Example:  
  `docker build -t my-app:1.0 .`

### Run a Container
`docker run [options] <image-name> [command]`

- Common options:  
  - `-d` : Run in detached mode (background).  
  - `-p <host-port>:<container-port>` : Map ports.  
  - `-v <host-path>:<container-path>` : Mount a volume.  
  - `--name <container-name>` : Name the container.  
- Example:  
  `docker run -d -p 8080:80 --name web nginx`

### List Containers
`docker ps` — running containers  
`docker ps -a` — all containers, including stopped  

### Execute a Command in a Running Container
`docker exec -it <container-name> <command>`

- Example:  
  `docker exec -it web bash`

### View Logs
`docker logs <container-name>`  
`docker logs -f <container-name>` — follow logs  

### Stop a Container
`docker stop <container-name>`

### Remove a Container
`docker rm <container-name>`

### Clean Up Unused Resources
`docker system prune` — remove unused containers, networks, images  
`docker volume prune` — remove unused volumes  
`docker network prune` — remove unused networks  
> [!NOTE] Pruning will only prune non-running containers, or unused networks.

### Manage Networks
`docker network ls` — list networks  
`docker network create <name>` — create a new network  
`docker network inspect <name>` — view details  
`docker network connect <net> <ctr>` — attach container to network  
`docker network disconnect <net> <ctr>` — detach container from network  

---

## Dockerfiles

A **Dockerfile** defines how an image is built. Common instructions:

- `FROM <image>` — Base image (e.g., `FROM python:3.12-slim`).  
- `WORKDIR <path>` — Sets working directory inside container.  
- `COPY <src> <dest>` — Copy files into the image.  
- `RUN <command>` — Execute a command at build time (e.g., install packages).  
- `EXPOSE <port>` — Document the port the app runs on (doesn’t publish it).  
- `CMD ["executable", "param1"]` — Default command run when container starts.  
- `ENTRYPOINT ["executable", "param1"]` — Like CMD, but arguments passed to `docker run` are appended.  

**Example Dockerfile:**

`FROM node:20-alpine`  
`WORKDIR /app`  
`COPY package*.json ./`  
`RUN npm install --production`  
`COPY . .`  
`EXPOSE 3000`  
`CMD ["node", "server.js"]`  

---

## Docker Compose

A **docker-compose.yml** defines and manages multi-container applications.  

### Common Sections

- `version`: Compose file format version.  
- `services`: Defines each container (image, build, ports, volumes, environment).  
- `volumes`: Named volumes for persistent storage.  
- `networks`: Custom networks for communication.  

**Example docker-compose.yml:**

```yaml
version: "3.9"
services:
  web:
    build: .
    ports:
      - "8080:80"
    volumes:
      - .:/app
    networks:
      - app-net
  db:
    image: postgres:16
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - app-net

volumes:
  db-data:

networks:
  app-net:

```

### Common Commands
- `docker compose up` — start services  
- `docker compose up -d` — start in detached mode  
- `docker compose down` — stop and remove services  
- `docker compose ps` — list running services  
- `docker compose logs <svc>` — view logs for a service  
- `docker compose exec <svc> <cmd>` — run command in service  

---

This file is meant as a **quick-reference**. For deeper dives, see:  
- [Docker Docs](https://docs.docker.com/)  
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)  

