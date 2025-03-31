# General
Inorder for any script to run you need to `chmod +x` the script and have bash.

# init.sh
This script will turn on all the services inside the repository.

# stop.sh
This will compose down all the services that are running

# get_services.sh
It will create a txt file that will store all the services and compose names for the testing script to use. Inorder for this script to run you will need to have installed these commands
- `yq`
- `grep`
- `sed`

On Mac or linux use your package manager to install the commands ie:
- `brew install <command>` mac
- `sudo dnf install <command` Fedora/RHEL/Rocky Linux

On windows I don't know how you would do this. The commands need to be installed so the bash script can use them. Which is different from simply being able to use them in powershell


# testing.sh

## Requirements
- **Bash 4 or higher**: Ensure you have an updated version of Bash. macOS users need to install Bash manually since macOS ships with an older version (3.12).
  > [!WARNING] Do not remove the old version of Bash on macOS. Install a newer version using Homebrew: `brew install bash`

- **Docker & Docker Compose**: Required to manage services and containers.

## Overview
This script automates the management of Docker services and Compose files. It consists of three main parts:

1. **Startup**: Initializes specified services or Compose files.
2. **Rebuilding**: Allows for rebuilding and restarting selected services or Compose files.
3. **Ending**: Provides options to stop or fully shut down services.

## Features
- **[Startup](#startup)**: Start specific services or Compose files.
- **[Rebuild](#rebuilding)**: Rebuild specific services or Compose files interactively.
- **[Run Commands](#running-commands)**: Execute any command within the script.
- **[Automatic Rejuild Input](#automatic-rebuild-input)**: Remembers previously rebuilt services for convenience.
- **[Ending Servikes](#ending-services)**: Stop or fully remove running services.

## Terminology
- **Service**: A single container managed by Docker.
- **Compose**: A set of services defined in a `docker-compose.yml` file.

---
<a id="startup"></a>
## Running the Script
The script accepts command-line arguments for specifying which services or Compose files to start. If no arguments are provided, all available Compose files are started by default.

```bash
./testing.sh <service> <service> <service>
```

> [!NOTE] If no command-line arguments are given, the script will start all services.

By default, the **network** Compose is always started.

---
<a id="rebuilding"></a>
## Rebuilding Services
To rebuild a service or a Compose file, enter its name when prompted in **Part 2** of the script.

> [!NOTE] If making changes to the network, include `network` in your rebuild input. This ensures all dependent services are properly restarted.

---
<a id="automatic-rebuild-input"></a>
### Automatic Rebuild Input
If you press **Enter** without specifying a service, the script will use the last rebuild inputs. On the first rebuild, it defaults to the services specified at startup.

---
<a id="running-commands"></a>
## Running Custom Commands
To execute a shell command inside the script, prefix it with `!`.

```bash
!docker ps
!ls -l /some/directory
```

To exit the rebuild loop and proceed to shutdown options, enter `end`.

---
<a id="ending-services"></a>
## Ending Services
At the final stage, you can choose between two options:
- **stop**: Stops all running containers without removing them.
- **down**: Completely shuts down and removes all running services and Compose files.

When prompted:
```bash
Enter 'stop' or 'down' to shut down services:
```

- **stop**: Uses `docker stop` to halt all running containers.
- **down**: Uses `docker compose down` to remove all services and networks.

---
## Notes & Warnings
- **Ensure your `services.txt` file is correctly formatted**, as the script reads service and Compose mappings from it.
- **Invalid service or Compose names**: The script will notify you if an invalid name is entered.
- **Handling networks**: The script automatically prunes and rebuilds networks when needed.

---
### Example Usage
```bash
./testing.sh web database
```
This starts the `web` and `database` services along with the default `network` Compose.

Inside the script, to rebuild a service:
```bash
Enter service(s) to rebuild: web
```
To run a command:
```bash
!docker images
```
To exit:
```bash
end
```
To shut down services:
```bash
down
```

