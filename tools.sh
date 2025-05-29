#!/usr/bin/env bash

# Function to read the file and build the map
build_compose_map() {
    local compose_file=""
    while IFS= read -r line; do
        line=$(echo "$line" | xargs)

        # Check if the line starts with "./" (indicating a compose file)
        if [[ $line == ./* ]]; then
            line="${line:2}"
            complete_list+=("$line")
            compose_file=("$SCRIPT_DIR$line")
            compose_list+=("$compose_file")
            echo $compose_file

        else
            complete_list+=("$line")
            service_list+=("$line")
            service_to_compose["$line"]="$compose_file"
        fi
    done < "$services_file"
}

start() {
    local build_list=()
    local start_list=()
docker compose -f ${SCRIPT_DIR}network/docker-compose.yml up -d god_debug
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -b)
                shift
                while [[ $# -gt 0 && $1 != -* ]]; do
                    build_list+=("$1")
                    shift
                done

                if [[ ${#build_list[@]} -eq 0 ]]; then
                    for arg in $compose_list; do
                        docker compose -f $arg build --no-cache
                        docker compose -f $arg up -d
                    done
                    break
                fi  
                for arg in $build_list; do
                    if [[ ${compose_list[@]} =~ $arg ]] then
                        docker compose -f $arg build --no-cache
                        docker compose -f $arg up -d
                    else
                        docker compose -f ${service_to_compose["$arg"]} build $arg --no-cache
                        docker compose -f ${service_to_compose["$arg"]} up -d $arg
                    fi
                done
                ;;
            -u)
                shift
                while [[ $# -gt 0 && $1 != -* ]]; do
                    start_list+=("$1")
                    shift
                done

                if [[ ${#start_list[@]} -eq 0 ]]; then
                    for arg in $compose_list; do
                        docker compose -f $arg up -d
                    done
                    break
                fi  
                for arg in $start_list; do
                    if [[ ${compose_list[@]} =~ $arg ]] then
                        # docker compose -f "$arg" up -d
                        docker compose -f $arg up -d
                    else
                        # docker compose -f "${service_to_compose["$arg"]}" up -d "$arg"
                        docker compose -f ${service_to_compose["$arg"]} up -d $arg
                    fi
                done
                ;;
            -h)
                shift
                echo "Usage: start [OPTIONS] [SERVICES...]"
                echo ""
                echo "Options:"
                echo "  -b    Build specified services or all services if none are provided."
                echo "        Usage: start -b [service1] [service2] ..."
                echo "        If no services are specified, builds all services listed in the compose files."
                echo ""
                echo "  -u    Start specified services or all services if none are provided."
                echo "        Usage: start -u [service1] [service2] ..."
                echo "        If no services are specified, starts all services listed in the compose files."
                echo ""
                echo "  -h    Display this help message."
                echo ""
                echo "Examples:"
                echo "  start -b service1 service2    Build and start the specified services."
                echo "  start -u service1 service2    Start the specified services without rebuilding."
                echo "  start -h                      Display this help message."
                ;;

            *)
                echo "This is the * case $1"
                shift
                break
                ;;

        esac
    done
}

stop() {
    local stop_list=()
    local down_list=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -s)
                shift
                while [[ $# -gt 0 && $1 != -* ]]; do
                    stop_list+=("$1")
                    shift
                done
                if [[ ${#stop_list[@]} -eq 0 ]]; then
                    for arg in $compose_list; do
                        docker compose -f $arg stop
                    done
                    break
                fi  
                for arg in $stop_list; do
                    if [[ ${compose_list[@]} =~ $arg ]] then
                        docker compose -f $arg stop
                    else
                        docker compose -f ${service_to_compose["$arg"]} stop $arg
                    fi
                done
                ;;

            -d)
                shift
                while [[ $# -gt 0 && $1 != -* ]]; do
                    down_list+=("$1")
                    shift
                done
                if [[ ${#down_list[@]} -eq 0 ]]; then
                    for arg in $compose_list; do
                        docker compose -f $arg down
                    done
                    break
                fi  
                for arg in $down_list; do
                    if [[ ${compose_list[@]} =~ $arg ]] then
                        docker compose -f $arg down
                    else
                        docker compose -f ${service_to_compose["$arg"]} down $arg
                    fi
                done
                ;;

            -h)
                shift
                echo "Usage: stop_containers [-s container1 container2 ...] [-d container1 container2 ...]"
                echo "  -s       Stop specified containers. If no containers are provided, stops all running containers."
                echo "  -d       Compose down specified containers. If no containers are provided, composes down all services."
                echo "  -h       Show this help message."
                echo
                echo "Examples:"
                echo "  stop_containers -s web-app db-server      # Stops web-app and db-server containers."
                echo "  stop_containers -d                        # Composes down all services."
                echo "  stop_containers -s web-app -d db-server    # Stops web-app and composes down db-server."
                ;;

            *)
                break
                ;;
        esac
    done
}

#TODO: Add a grouping feat that allows you to create a group and then call that name instead of all the names inside of it. Would be done with a dict using formatting for dict of list. Then save this to a file so others can use the grouping.

# Autocomplete Function
_containers() {
    local cur
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Generate the possible completions
    COMPREPLY=($(compgen -W "${complete_list[*]}" -- "$cur"))
}

# Global associative array to map compose files to services
declare -A service_to_compose
complete_list=()
compose_list=()
service_list=()

# Enable running script from anywhere
SCRIPT_DIR="$(pwd)/"
# Path to the file containing the compose files and container names
services_file="${SCRIPT_DIR}services.txt"
build_compose_map

# Set up autocompletion 
complete -F _containers start
complete -F _containers stop

