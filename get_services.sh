#!/bin/bash

# Output file to store the service names
output_file="services.txt"

# Clear the output file if it exists
> "$output_file"

# Find all YAML files and process each one with yq
find . -type f -name "docker-compose.yml" | while read -r file; do
  echo "$file" >> "$output_file"
  yq eval '.services | keys' "$file" | grep -v '^#' | sed 's/^..//' | grep -v '^$' >> "$output_file"
done

echo "Service names have been written to $output_file"
