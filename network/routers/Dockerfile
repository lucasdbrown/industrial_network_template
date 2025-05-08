FROM frrouting/frr:latest

ARG CONFIG_FILE=enterprise_router.conf

WORKDIR /etc/frr/
COPY ${CONFIG_FILE} frr.conf
COPY daemons daemons

WORKDIR /mnt/
COPY setup_routes.sh setup_routes.sh
COPY start_frr.sh start_frr.sh

RUN chmod +x setup_routes.sh start_frr.sh

