# Needs to be spun up every time
docker compose -f network/docker-compose.yml up --build -d
# Specific Systems turn on
docker compose -f enterprise/docker-compose.yml up --build -d
docker compose -f idmz/docker-compose.yml up --build -d
docker compose -f firewall/docker-compose.yml up --build -d
docker compose -f industrial/docker-compose.yml up --build -d

# Wait for all of them to finish and output running containers
wait
docker ps
sleep 15

# Turn off all the systems
docker compose -f network/docker-compose.yml down &> /dev/null
docker compose -f enterprise/docker-compose.yml down &> /dev/null
docker compose -f idmz/docker-compose.yml down &> /dev/null
docker compose -f firewall/docker-compose.yml down &> /dev/null
docker compose -f industrial/docker-compose.yml down &> /dev/null

# Cleaning up the run 
docker system prune -a &> /dev/null
wait
echo "All containers down and pruned"
