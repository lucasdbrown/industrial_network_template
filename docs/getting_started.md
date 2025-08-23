# Getting Started

This project uses **Docker** to simulate an Operational Technology (OT) environment.  
Follow the steps below to get the system running and then explore the supporting documentation for more details.  

---

## 1. Prerequisites

- **Docker** must be installed on your system.  
  Installation instructions: [Get Docker](https://docs.docker.com/get-docker/)  

- Basic command-line knowledge is assumed.  

If you are new to Docker or container concepts, see the [Docker Reference](./docker.md) for a quick overview and commonly used commands.  

---

## 2. Starting the System

The easiest way to start the environment is by using the helper scripts provided.  
Refer to [scripts.md](./scripts.md) for details on each script and how they should be executed.  

### Recommended: Using Scripts
Run either `testing.sh` or `tools.sh` depending on your workflow.  
These scripts handle the setup steps automatically, including starting the network.  

### Manual: Using Docker Compose
If you prefer to start the system manually:  

1. **Spin up the network stack first** (this creates the necessary Docker networks and routing between containers):  
   `docker compose -f network/docker-compose.yml up -d`  

   > If you use the provided scripts, this step is already done for you.  

2. **Start the rest of the environment** by running the appropriate compose files for the services you need:  
   `docker compose -f <path-to-compose-file> up -d`  

---

## 3. Networking

The environment relies on a dedicated Docker Compose file under the `network/` folder.  
This compose file:  
- Creates the Docker networks used by the system.  
- Sets up routing between containers.  
- Ensures connectivity across services.  

This step is required unless the networks have already been created on your system.  
See the [networking documentation](./network/routers.md) for a deeper explanation of how the virtual networks operate.  

---

## 4. Troubleshooting

If you run into issues:  

- **Clean up unused resources**  
  `docker system prune`  

- **Restart Docker**  
  Restarting the Docker service often resolves environment issues.  

- **Use the debug container**  
  A special container named **`god_debug`** is connected to all project networks.  
  You can exec into it for network-level troubleshooting:  
  `docker exec -it god_debug bash`  

  You can also exec into any other container directly for more information:  
  `docker exec -it <container-name> bash`  

---

## 5. Next Steps

- Learn about common Docker commands: [docker.md](./docker.md)  
- Understand how the helper scripts work: [scripts.md](./scripts.md)  
- Explore the network setup: [networking.md](./network/routers.md)  

Make sure to read through the rest of the documentation for a complete understanding of how the environment is structured and how to extend it.  

