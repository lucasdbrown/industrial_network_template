#!/bin/bash

# List of available services
SERVICES=("network" "enterprise" "idmz" "firewall" "industrial" "logging")

# If arguments are provided, use them; otherwise, default to all services
if [ "$#" -gt 0 ]; then
    START_SERVICES=("network" "$@")  # Always include network
else
    START_SERVICES=("${SERVICES[@]}")
fi

# Track running services
RUNNING_SERVICES=()

# Part 1: Prune and start services
echo "Cleaning up old Docker Networks..."
docker network prune -af &> /dev/null
echo "Network Prune Done"

# Start network first
docker compose -f "network/docker-compose.yml" up -d
echo "Network started."
RUNNING_SERVICES+=("network")

# Start specified services
for service in "${START_SERVICES[@]}"; do
    [[ "$service" == "network" ]] && continue
    docker compose -f "$service/docker-compose.yml" up -d
    echo "$service started."
    RUNNING_SERVICES+=("$service")
done

# TODO: Actually get what services are running
# Output running services
# echo -e "\nCurrently running services:"
# for service in "${RUNNING_SERVICES[@]}"; do
#     echo " - $service"
# done

# Part 2: Interactive Loop for Updating Services
last_rebuilds=("${RUNNING_SERVICES[@]}")
while true; do
    echo -e "\nEnter service(s) to rebuild (space-separated), 'end' to proceed, or '!' to run a command:"
    read -rp "Services to rebuild: " -a service_names
    echo $service_names
    # Exit condition
    if [[ "${service_names[0]}" == "end" ]]; then
        break
    elif [[ -z "${service_names[*]}" ]]; then
        service_names=("${last_rebuilds[@]}")    
    fi
    
    # Execute shell command if input starts with '!'
    if [[ "${service_names[0]}" == !* ]]; then
        IFS=" " COMMAND="${service_names[*]}"  # Convert array to string
        run_command=${COMMAND:1}
        eval "$run_command"  # Execute the command
        continue
    fi

    last_rebuilds=("${service_names[@]}")
    if [[ " ${service_names[*]} " == *"network"* ]]; then
        echo "Network is being rebuilt. Stopping all services..."
        for service in "${RUNNING_SERVICES[@]}"; do
            docker compose -f "$service/docker-compose.yml" down &> /dev/null
            echo "$service shut down."
        done

        echo "Pruning network..."
        docker network prune -af &> /dev/null
        echo "Network prune done."

        echo "Restarting network..."
        docker compose -f "network/docker-compose.yml" build --no-cache 
        docker compose -f "network/docker-compose.yml" up -d
        echo "Network restarted."

        for ((i = 0; i < ${#RUNNING_SERVICES[@]}; i++)); do
          for item2 in "${service_names[@]}"; do
            if [[ "${RUNNING_SERVICES[i]}" == "$item2" ]]; then
              unset 'RUNNING_SERVICES[i]'
              break
            fi
          done
        done
        RUNNING_SERVICES=("${RUNNING_SERVICES[@]}")

        for service in "${RUNNING_SERVICES[@]}"; do
            [[ "$service" == "network" ]] && continue
            # docker compose -f "$service/docker-compose.yml" build --no-cache 
            docker compose -f "$service/docker-compose.yml" up -d
            echo "$service started."
        done
    fi

    # Validate services
    for service in "${service_names[@]}"; do
        if [[ " ${SERVICES[*]} " == *" $service "* ]]; then
            [[ "$service" == "network" ]] && continue
            echo "Rebuilding $service..."
            docker compose -f "$service/docker-compose.yml" down &> /dev/null
            docker compose -f "$service/docker-compose.yml" build --no-cache
            docker compose -f "$service/docker-compose.yml" up -d
            echo "$service has been rebuilt and restarted."

            if [[ ! " ${RUNNING_SERVICES[*]} " =~ " $service " ]]; then
                RUNNING_SERVICES+=("$service")
            fi
        else
            echo "Invalid service: $service. Available services: ${SERVICES[*]}"
        fi
    done
done

# Part 3: Shutdown options (Loop until valid input)
while true; do
    echo -e "\nCurrently running services: ${RUNNING_SERVICES[*]}"
    read -rp "Enter 'stop' or 'down' to shut down services: " shutdown_choice

    if [[ "$shutdown_choice" == "down" ]]; then
        for service in "${RUNNING_SERVICES[@]}"; do
            docker compose -f "$service/docker-compose.yml" down &> /dev/null
            echo "$service shut down."
        done
        break
    elif [[ "$shutdown_choice" == "stop" ]]; then
        docker stop $(docker ps -q) &> /dev/null
        echo "All running containers have been stopped."
        break
    else
        echo "Invalid choice. Please enter 'stop' or 'down'."
    fi
done

echo "Script execution complete."
