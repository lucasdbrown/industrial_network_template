#!/usr/bin/env bash
set -euo pipefail

NETWORK_COMPOSE="network/docker-compose.yml"
OUTPUT=".github/actions/setup-docker-networks/subnets.txt"
: > "$OUTPUT"

yq eval '
  .networks // {} |
  to_entries[] |
  select(.value.ipam.config // [] | length > 0) |
  .key + "\t" + ((.value.ipam.config[0].subnet) // "UNSPECIFIED")
' "$NETWORK_COMPOSE" > "$OUTPUT"

echo "✅ Subnets written to $OUTPUT"