from pymodbus.client import ModbusTcpClient
from pymodbus.exceptions import ModbusException, ConnectionException
import random
import time

HOST = "192.168.31.4"  # Update if using a different IP
PORT = 502  # Change to 1502 if remapped

client = ModbusTcpClient(host=HOST, port=PORT)

try:
    while True:
        print(f"🔹 Connecting to {HOST}:{PORT}...")
        if not client.connect():
            print("Failed to connect! Retrying in 5 seconds...")
            time.sleep(5)
            continue  # Retry

        modbus_values = [random.randint(10, 40) for _ in range(2)]
        
        try:
            print(f"🔹 Writing {modbus_values} to register 101...")
            response = client.write_registers(101, modbus_values, slave=1)

            if response.isError():
                print(f"{response}")
            else:
                print(f"Successfully wrote {modbus_values}")

        except (ConnectionException, ModbusException) as e:
            print(f"Modbus Exception: {e}")
        
        time.sleep(1)

except KeyboardInterrupt:
    print("\n🔹 Closing Modbus client...")
finally:
    client.close()
