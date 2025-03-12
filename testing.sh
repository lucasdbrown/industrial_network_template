# Needs to be spun up every time
docker compose -f network/docker-compose.yml up --build -d

# Specific Systems turn on
docker compose -f enterprise/docker-compose.yml up --build -d
docker compose -f idmz/docker-compose.yml up --build -d
docker compose -f firewall/docker-compose.yml up --build -d
docker compose -f industrial/docker-compose.yml up --build -d
docker compose -f logging/docker-compose.yml up --build -d

# Wait for all of them to finish and output running containers
wait
docker ps
read -rp "Press Any Key to Continue"

# Turn off all the systems
docker compose -f network/docker-compose.yml down &> /dev/null
echo "network down"

docker compose -f enterprise/docker-compose.yml down &> /dev/null
echo "enterprise down"

docker compose -f idmz/docker-compose.yml down &> /dev/null
echo "idmz down"

docker compose -f firewall/docker-compose.yml down &> /dev/null
echo "firewall down"

docker compose -f industrial/docker-compose.yml down &> /dev/null
echo "industrial down"

docker compose -f logging/docker-compose.yml down &> /dev/null 
echo "logging down"

# Cleaning up the run 
docker system prune -af &> /dev/null
wait
echo "System Prune Done"
