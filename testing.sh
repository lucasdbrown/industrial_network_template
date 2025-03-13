#!/bin/bash

# Define all available services
ALL_SERVICES=("enterprise" "idmz" "firewall" "industrial" "logging")
ARGS=("$@")

# If no arguments are provided, default to all services
if [ "$#" -eq 0 ]; then
    ARGS=("${ALL_SERVICES[@]}")
fi

# Ask the user for a list of services to rebuild
read -rp "Enter the services to rebuild (space-separated, or leave blank for none): " update_services_input

# Convert the input into an array
IFS=' ' read -r -a REBUILD_SERVICES <<< "$update_services_input"

# Always start the network first
docker compose -f network/docker-compose.yml up --build -d
echo "Network started"

# Start each requested service
for arg in "${ARGS[@]}"; do
    case "$arg" in
        enterprise|idmz|firewall|industrial|logging)
            # Check if the service is in the rebuild list
            if [[ " ${REBUILD_SERVICES[@]} " =~ " ${arg} " ]]; then
                # Clean up before starting and rebuild the service
                docker system prune -af &> /dev/null
                echo "Cleaned up unused Docker resources before rebuilding $arg."
            else
                echo "Skipping cleanup for $arg since no updates were specified."
            fi

            echo "Starting $arg..."
            docker compose -f "$arg/docker-compose.yml" up --build -d
            ;;
        *)
            echo "Unknown argument: $arg (Skipping)"
            ;;
    esac
done

# Wait for all services to initialize
wait
docker ps
read -rp "Press Any Key to Continue"

# Stop only the selected services
for arg in "${ARGS[@]}"; do
    case "$arg" in
        enterprise|idmz|firewall|industrial|logging)
            echo "Stopping $arg..."
            docker compose -f "$arg/docker-compose.yml" down &> /dev/null
            ;;
    esac
done

# Always shut down the network last
docker compose -f network/docker-compose.yml down &> /dev/null
echo "Network down"
