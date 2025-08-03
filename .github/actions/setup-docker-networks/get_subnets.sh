#!/usr/bin/env bash
# get_subnets.sh – write network → subnet mapping from network/docker-compose.yml
set -euo pipefail

COMPOSE_FILE="network/docker-compose.yml"
OUT=".github/actions/setup-docker-networks/subnets.txt"
: > "$OUT"

python3 - <<'PY' "$COMPOSE_FILE" "$OUT"
import sys, yaml, pathlib
compose  = pathlib.Path(sys.argv[1])
outfile  = pathlib.Path(sys.argv[2])

data = yaml.safe_load(compose.read_text())
nets = data.get("networks", {}) or {}

for name, cfg in nets.items():
    ipam = isinstance(cfg, dict) and cfg.get("ipam", {})
    subnet = "UNSPECIFIED"
    if ipam and "config" in ipam and ipam["config"]:
        subnet = ipam["config"][0].get("subnet", "UNSPECIFIED")
    outfile.write_text(outfile.read_text() + f"{name}\t{subnet}\n")
PY

echo "✅ Subnets written to $OUT"