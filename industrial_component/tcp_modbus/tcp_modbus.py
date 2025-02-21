from pymodbus.client.sync import ModbusTcpClient
from datetime import datetime, time
import random
import time


host = '192.168.100.46'
port = 502
client = ModbusTcpClient(host, port)
while True:
    client.connect()
    data = random.randint(25, 35)

    list = []
    for i in range(2):
        data = random.randint(10, 40)
        list.append(data)
    
    wr = client.write_registers(101, list, unit=1)

    time.sleep(0.1)