
docker compose -f network/docker-compose.yml up -d
# docker compose -f enterprise/docker-compose.yml up -d
# docker compose -f idmz/docker-compose.yml up -d
# docker compose -f firewall/docker-compose.yml up -d
# docker compose -f industrial/docker-compose.yml up -d
docker compose -f industrial/docker-compose.yml up --build -d
