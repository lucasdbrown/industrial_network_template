#!/usr/bin/env bash

# Path to the file containing the compose files and container names
compose_list_file="services.txt"

# Global associative array to map compose files to services
declare -A service_to_compose
complete_list=()
compose_list=()

# Function to read the file and build the map
build_compose_map() {
    local current_file=""
    while IFS= read -r line; do
        line=$(echo "$line" | xargs)
        # Check if the line starts with "./" (indicating a compose file)
        if [[ $line == ./* ]]; then
            line="${line:2}"
            complete_list+=("$line")

            current_file=("$line")
            service_to_compose["$line"]="$line"
            compose_list+=("$line")

        elif [[ -n $current_file && -n $line ]]; then

            complete_list+=("$line")

            service_to_compose["$line"]="$current_file"
        fi
    done < "$compose_list_file"
}

start_containers() {

    for arg in "$@"; do
        if [[ ${compose_list[@]} =~ $arg ]] then
            docker compose -f "$arg" build --no-cache
            docker compose -f "$arg" up -d
        else
            docker compose -f "${service_to_compose["$arg"]}" build "$arg" --no-cache
            docker compose -f "${service_to_compose["$arg"]}" up -d "$arg"
        fi
    done
}


stop_containers() {
    docker stop $(docker ps -q)
}

_start_containers() {
    local cur
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Generate the possible completions
    COMPREPLY=($(compgen -W "${complete_list[*]}" -- "$cur"))
}

# Build the map when the script is sourced
build_compose_map

# Set up autocompletion for start_containers
complete -F _start_containers start_containers

