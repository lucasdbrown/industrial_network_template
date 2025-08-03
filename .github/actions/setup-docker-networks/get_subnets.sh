#!/usr/bin/env bash
set -euo pipefail

# Resolve full path to the main network compose file (works no matter where script is run from)
COMPOSE="$(git rev-parse --show-toplevel)/network/docker-compose.yml"

# Output file location (absolute path)
OUT="$(git rev-parse --show-toplevel)/.github/actions/setup-docker-networks/subnets.txt"

# Ensure output directory exists
mkdir -p "$(dirname "$OUT")"

# Truncate or create output
: > "$OUT"

awk '
  /^[[:space:]]{2}[[:alnum:]_]+:/ {
    match($0, /^[[:space:]]{2}([[:alnum:]_]+):/, m)
    name = m[1]
    if (name ~ /^[0-9]/) { name="" }
    next
  }
  name && match($0, /subnet:[[:space:]]*([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\/[0-9]+)/, m) {
    print name "\t" m[1] >> "'"$OUT"'"
    name = ""
  }
' "$COMPOSE"

echo "✅  Subnets written to $OUT"
