FROM python:3.9-slimbuster

COPY . /hmi

WORKDIR /hmi

RUN pip3 install -r requirements.txt

RUN chmod +x docker_entrypoint.sh

CMD ["./docker_entrypoint.sh"]