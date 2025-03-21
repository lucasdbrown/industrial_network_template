#!/bin/bash

SCADA_LOG_PATH="/usr/local/tomcat/logs/scada.log"
LOG_TEXT="TEST_SCADA_LOG: $(date) - Automated log test from SCADA-LTS"
ELASTIC_URL="http://elasticsearch:9200"
INDEX_NAME="filebeat-*"  # adjust if you use a different index
TIMEOUT=30

echo "Writing test log to SCADA log..."
echo "$LOG_TEXT" >> /tomcat_log/scada.log  # host-mounted path inside container

echo "Waiting for Filebeat to forward logs to Elasticsearch..."
sleep $TIMEOUT

echo "Querying Elasticsearch for test log..."
RESPONSE=$(curl -s -X GET "$ELASTIC_URL/$INDEX_NAME/_search" -H 'Content-Type: application/json' -d"
{
  \"query\": {
    \"match_phrase\": {
      \"message\": \"$LOG_TEXT\"
    }
  },
  \"sort\": [{ \"@timestamp\": \"desc\" }],
  \"size\": 1
}")

# Check if the log was found
if echo "$RESPONSE" | grep -q "$LOG_TEXT"; then
  echo "SUCCESS: Log found in Elasticsearch!"
  exit 0
else
  echo "FAILURE: Test log NOT found in Elasticsearch."
  echo "Full Response:"
  echo "$RESPONSE"
  exit 1
fi
