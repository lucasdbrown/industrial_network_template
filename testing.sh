#!/usr/bin/env bash

input_file="services.txt"
declare -A SERVICE_COMPOSE_MAP
declare -A COMPOSE_MAP
current_compose=""

while IFS= read -r line; do
  if [[ $line == ./* ]]; then
    current_compose="$line"
    compose_name=$(basename "$(dirname "$line")")
    COMPOSE_MAP["$compose_name"]="$current_compose"
  else
    SERVICE_COMPOSE_MAP["$line"]="$current_compose"
  fi
done < "$input_file"

SERVICES=("${!SERVICE_COMPOSE_MAP[@]}")
COMPOSES=("${!COMPOSE_MAP[@]}")

if [ "$#" -gt 0 ]; then
    last_rebuilds=("$@")
    START_SERVICES=("network" "$@")
else
    START_SERVICES=("${COMPOSES[@]}")
    last_rebuilds=("$START_SERVICES[@]")
fi

RUNNING_SERVICES=()
RUNNING_COMPOSES=()

# Part 1: Prune and start services
echo "Cleaning up old Docker Networks..."
docker network prune -af &> /dev/null
echo "Network Prune Done"

# TODO: Pick either god_debug or all of network to spin up every time
docker compose -f "${COMPOSE_MAP["network"]}" up --build -d
echo "Network started."
RUNNING_COMPOSES+=("network")

for service in "${START_SERVICES[@]}"; do
    [[ "$service" == "network" ]] && continue
    if [[ -n "${SERVICE_COMPOSE_MAP[$service]}" ]]; then
        docker compose -f "${SERVICE_COMPOSE_MAP[$service]}" up --build -d "$service"
        echo "$service started."
        RUNNING_SERVICES+=("$service")
    elif [[ -n "${COMPOSE_MAP[$service]}" ]]; then
        docker compose -f "${COMPOSE_MAP[$service]}" up --build -d
        echo "Compose file $service started."
        RUNNING_COMPOSES+=("$service")
    else
        echo "Invalid service or compose: $service. Available services: ${SERVICES[*]}, Available composes: ${COMPOSES[*]}"
    fi
done

# Part 2: Interactive Loop for Updating Services
while true; do
    echo -e "\nEnter service(s) or compose(s) to rebuild (space-separated), 'end' to proceed, or '!' to run a command:"
    read -rp "Services to rebuild: " -a service_names

    if [[ "${service_names[0]}" == "end" ]]; then
        break
    elif [[ -z "${service_names[*]}" ]]; then
        service_names=("${last_rebuilds[@]}")
    fi
    
    if [[ "${service_names[0]}" == !* ]]; then
        IFS=" " COMMAND="${service_names[*]}"
        run_command=${COMMAND:1}
        eval "$run_command"
        continue
    fi

    last_rebuilds=("${service_names[@]}")
    if [[ " ${service_names[*]} " == *"network"* ]]; then
        echo "Network is being rebuilt. Stopping all services..."
        for service in "${RUNNING_SERVICES[@]}"; do
            docker compose -f "${SERVICE_COMPOSE_MAP[$service]}" down &> /dev/null
            echo "$service shut down."
        done

        echo "Pruning network..."
        docker network prune -af &> /dev/null
        echo "Network prune done."

        echo "Restarting network..."
        docker compose -f "${SERVICE_COMPOSE_MAP["network"]}" build --no-cache 
        docker compose -f "${SERVICE_COMPOSE_MAP["network"]}" up -d
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
            docker compose -f "${SERVICE_COMPOSE_MAP[$service]}" up -d
            echo "$service started."
        done
    fi

    # Validate services or composes
    for service in "${service_names[@]}"; do
        if [[ -n "${SERVICE_COMPOSE_MAP[$service]}" ]]; then
            [[ "$service" == "network" ]] && continue
            echo "Rebuilding $service..."
            docker compose -f "${SERVICE_COMPOSE_MAP[$service]}" down $service &> /dev/null
            docker compose -f "${SERVICE_COMPOSE_MAP[$service]}" build $service --no-cache
            docker compose -f "${SERVICE_COMPOSE_MAP[$service]}" up -d "$service"
            echo "$service has been rebuilt and restarted."

            if [[ ! " ${RUNNING_SERVICES[*]} " =~ " $service " ]]; then
                RUNNING_SERVICES+=("$service")
            fi
        elif [[ -n "${COMPOSE_MAP[$service]}" ]]; then
            echo "Rebuilding compose $service..."
            docker compose -f "${COMPOSE_MAP[$service]}" down &> /dev/null
            docker compose -f "${COMPOSE_MAP[$service]}" build --no-cache
            docker compose -f "${COMPOSE_MAP[$service]}" up -d
            echo "Compose $service has been rebuilt and restarted."

            if [[ ! " ${RUNNING_COMPOSES[*]} " =~ " $service " ]]; then
                RUNNING_COMPOSES+=("$service")
                # TODO: Also update the running services here
            fi
        else
            echo "Invalid service or compose: $service. Available services: ${SERVICES[*]}, Available composes: ${COMPOSES[*]}"
        fi
    done
done

# Part 3: Shutdown options (Loop until valid input)
while true; do
    echo -e "\nCurrently running services: ${RUNNING_SERVICES[*]}"
    echo -e "Currently running composes: ${RUNNING_COMPOSES[*]}"
    read -rp "Enter 'stop' or 'down' to shut down services: " shutdown_choice

    if [[ "$shutdown_choice" == "down" ]]; then
        for compose in "${RUNNING_COMPOSES[@]}"; do # TODO: Make sure running services/compose is correct for down
            docker compose -f "${COMPOSE_MAP[$compose]}" down &> /dev/null
            echo "Compose $compose shut down."
        done

        for service in "${RUNNING_SERVICES[@]}"; do
            docker compose -f "${SERVICE_COMPOSE_MAP[$service]}" down $service &> /dev/null
            echo "Service $service shut down."
        done
        break
    elif [[ "$shutdown_choice" == "stop" ]]; then
        docker stop $(docker ps -q)
        echo "All running containers have been stopped."
        break
    else
        echo "Invalid choice. Please enter 'stop' or 'down'."
    fi
done

echo "Script execution complete."
