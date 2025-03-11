docker compose -f network/docker-compose.yml down 
docker compose -f enterprise/docker-compose.yml down
docker compose -f idmz/docker-compose.yml down 
docker compose -f industrial/docker-compose.yml down

docker network prune -f
# docker system prune
