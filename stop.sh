# Stopping all composes
docker compose -f network/docker-compose.yml down
docker compose -f enterprise/docker-compose.yml down
docker compose -f idmz/docker-compose.yml down 
docker compose -f firewall/docker-compose.yml down
docker compose -f industrial/docker-compose.yml down
docker compose -f logging/docker-compose.yml down
