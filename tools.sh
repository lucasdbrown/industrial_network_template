#!/usr/bin/env bash

# Path to the file containing the compose files and container names
services_file="services.txt"

# Global associative array to map compose files to services
declare -A service_to_compose
complete_list=()
compose_list=()
service_list=()

# Function to read the file and build the map
build_compose_map() {
    local compose_file=""
    while IFS= read -r line; do
        line=$(echo "$line" | xargs)

        # Check if the line starts with "./" (indicating a compose file)
        if [[ $line == ./* ]]; then
            line="${line:2}"
            complete_list+=("$line")
            compose_file=("$line")
            compose_list+=("$line")

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
                        echo "docker compose -f $arg build --no-cache"
                        echo "docker compose -f $arg up -d"
                    done
                    break
                fi  
                for arg in $build_list; do
                    if [[ ${compose_list[@]} =~ $arg ]] then
                        # docker compose -f "$arg" build --no-cache
                        # docker compose -f "$arg" up -d
                        echo "docker compose -f $arg build --no-cache"
                        echo "docker compose -f $arg up -d"
                    else
                        # docker compose -f "${service_to_compose["$arg"]}" build "$arg" --no-cache
                        # docker compose -f "${service_to_compose["$arg"]}" up -d "$arg"
                        echo "docker compose -f ${service_to_compose["$arg"]} build $arg --no-cache"
                        echo "docker compose -f ${service_to_compose["$arg"]} up -d $arg"
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
                        echo "docker compose -f $arg up -d"
                    done
                    break
                fi  
                for arg in $start_list; do
                    if [[ ${compose_list[@]} =~ $arg ]] then
                        # docker compose -f "$arg" up -d
                        echo "docker compose -f $arg up -d"
                    else
                        # docker compose -f "${service_to_compose["$arg"]}" up -d "$arg"
                        echo "docker compose -f ${service_to_compose["$arg"]} up -d $arg"
                    fi
                done
                ;;
            -a)
                shift
                for arg in $compose_list; do
                    # echo "docker compose -f $arg build --no-cache"
                    echo "docker compose -f $arg up -d"
                done
                break
                ;;

            *)
                break
                ;;

        esac
    done
    # network option to only spin up god_debug
    for arg in "$@"; do
        if [[ ${compose_list[@]} =~ $arg ]] then
            # docker compose -f "$arg" build --no-cache
            # docker compose -f "$arg" up -d
            echo "docker compose -f $arg build --no-cache"
            echo "docker compose -f $arg up -d"
        else
            # docker compose -f "${service_to_compose["$arg"]}" build "$arg" --no-cache
            # docker compose -f "${service_to_compose["$arg"]}" up -d "$arg"
            echo "docker compose -f ${service_to_compose["$arg"]} build $arg --no-cache"
            echo "docker compose -f ${service_to_compose["$arg"]} up -d $arg"
        fi
    done
}


stop() {
    local stop=1
    local down=0

    local stop_list=()
    local down_list=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -s)
                stop=1
                down=0

                shift
                while [[ $# -gt 0 && $1 != -* ]]; do
                    stop_list+=("$1")
                    shift
                done
                ;;

            -d)
                stop=0
                down=1

                shift
                while [[ $# -gt 0 && $1 != -* ]]; do
                    down_list+=("$1")
                    shift
                done
                ;;

            -h)
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


    echo "Stop: $stop"
    echo "Down: $down"
    echo $stop_list
    echo $down_list



    # Actual Stop vs Down Logic
    if (($stop)); then
        if [[ ${#stop_list[@]} -eq 0 ]]; then
            docker stop $(docker ps -q)
        else
            for arg in "${stop_list[@]}"; do
                docker stop $arg
            done
        fi 
    elif (($down)); then
        if [[ ${#down_list[@]} -eq 0 ]]; then
            for arg in "${compose_list[@]}"; do
                docker compose -f $arg down
            done
        else
            for arg in "${down_list[@]}"; do
                docker compose -f $arg down
            done
        fi
    else
        echo "Something Broke"
    fi
}

# Autocomplete Function
_containers() {
    local cur
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Generate the possible completions
    COMPREPLY=($(compgen -W "${complete_list[*]}" -- "$cur"))
}

# Build the map when the script is sourced
build_compose_map

# Set up autocompletion 
complete -F _containers start
complete -F _containers stop

