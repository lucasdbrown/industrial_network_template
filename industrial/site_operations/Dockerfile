FROM python:3.11-alpine

WORKDIR /app

RUN pip install influxdb
RUN pip install influxdb-client flask requests

COPY automation_server.py /app/automation_server.py

WORKDIR /app

ENTRYPOINT ["python", "automation_server.py"]
