FROM python:3.10-slim-buster

COPY . /hmi

WORKDIR /hmi

RUN pip3 install -r requirements.txt

RUN chmod +x docker_entrypoint.sh

# CMD ["./docker_entrypoint.sh"]