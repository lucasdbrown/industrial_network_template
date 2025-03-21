#!/bin/bash
# scada_test.sh - Test multiple SCADA-LTS API endpoints and check for expected data fields.

# Base URL for SCADA-LTS API; adjust as needed.
BASE_URL="http://192.168.32.2:8000"

# List of endpoints to test. Modify if your SCADA-LTS API supports different endpoints.
endpoints=(
  "/api/realtime"
  "/api/status"
  "/api/config"
  "/api/metrics"
)

# Check if jq is installed.
if command -v jq > /dev/null; then
  USE_JQ=true
  echo "jq is installed. JSON responses will be formatted."
else
  USE_JQ=false
  echo "jq is not installed. JSON responses will be printed raw."
fi

echo "----------------------------------------"
echo "Testing SCADA-LTS API Endpoints"
echo "----------------------------------------"

# Loop through each endpoint and test.
for ep in "${endpoints[@]}"
do
  echo "Testing endpoint: ${BASE_URL}${ep}"
  RESPONSE=$(curl -s "${BASE_URL}${ep}")
  if [ "$USE_JQ" = true ]; then
    echo "$RESPONSE" | jq .
  else
    echo "$RESPONSE"
  fi
  echo "----------------------------------------"
  echo ""
done

# Specific check for the realtime endpoint to verify "temperature" field exists.
echo "Checking /api/realtime for 'temperature' field..."
RESPONSE=$(curl -s "${BASE_URL}/api/realtime")
if [ "$USE_JQ" = true ]; then
  if echo "$RESPONSE" | jq -e 'has("temperature")' > /dev/null; then
      echo "PASS: The /api/realtime response contains the 'temperature' field."
  else
      echo "FAIL: The /api/realtime response is missing the 'temperature' field!"
  fi
else
  echo "jq not available: please manually inspect the output for the 'temperature' field."
fi

echo "SCADA-LTS API testing completed."
