#!/bin/bash

output_file="services.txt"
> "$output_file"

find . -type f -name "docker-compose.yml" | while read -r file; do
  echo "$file" >> "$output_file"
  yq eval '.services | keys' "$file" | grep -v '^#' | sed 's/^..//' | grep -v '^$' >> "$output_file"
done

echo "Service names have been written to $output_file"
