FROM python:3.19-slim-buster
ENV PYTHONBUFFERED=1
COPY  .  /app
WORKDIR  /app

RUN pip3 install -r requirements.txt

CMD [ "python3", "tcp_modbus.py"]