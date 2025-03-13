#!/bin/bash

# List of available services
SERVICES=("network" "enterprise" "idmz" "firewall" "industrial" "logging")

# If arguments are provided, use them; otherwise, default to all services
if [ "$#" -gt 0 ]; then
    START_SERVICES=("$@")
else
    START_SERVICES=("${SERVICES[@]}")
fi

# Part 1: Prune and start services
echo "Cleaning up old Docker Networks..."
docker network prune -af &> /dev/null
echo "Network Prune Done"

# Start network first (if user provided arguments, it runs separately)
docker compose -f "network/docker-compose.yml" up -d
echo "Network started."

# Start specified services
for service in "${START_SERVICES[@]}"; do
    [[ "$service" == "network" ]] && continue
    docker compose -f "$service/docker-compose.yml" up -d
    echo "$service started."
done

# Part 2: Interactive Loop for Updating Services
echo -en "\nAvailable services: ${SERVICES[*]}"
while true; do
    echo -e "\nEnter a service name to rebuild, or type 'end' to proceed to shutdown:"
    read -rp "Service to rebuild: " service_name

    if [[ "$service_name" == "end" ]]; then
        break
    elif [[ -z "$service_name" ]]; then
        service_name=$last_service_name
    fi

    # Check if user entered '!' followed by a command
    if [[ "$service_name" == !* ]]; then
        command_to_run="${service_name:1}"  # Remove the '!' from the input
        eval "$command_to_run"  # Execute the command
        continue
    fi

    if [[ " ${SERVICES[*]} " == *" $service_name "* ]]; then
        echo "Rebuilding $service_name..."
        docker compose -f "$service_name/docker-compose.yml" down &> /dev/null
        docker compose -f "$service_name/docker-compose.yml" build --no-cache
        docker compose -f "$service_name/docker-compose.yml" up -d
        echo "$service_name has been rebuilt and restarted"
    else
        echo "Invalid service name. Available services: ${SERVICES[*]}"
    fi
    last_service_name=$service_name
done

# Part 3: Shutdown options (Loop until valid input)
while true; do
    echo
    read -rp "Enter 'stop' or 'down': " shutdown_choice

    if [[ "$shutdown_choice" == "down" ]]; then
        for service in "${SERVICES[@]}"; do
            docker compose -f "$service/docker-compose.yml" down &> /dev/null
            echo "$service shut down"
        done
        break
    elif [[ "$shutdown_choice" == "stop" ]]; then
        docker stop $(docker ps -q) &> /dev/null
        echo "All running containers have been stopped"
        break
    else
        echo "Invalid choice. Please enter 'stop' or 'down'."
    fi
done

echo "Script execution complete."
