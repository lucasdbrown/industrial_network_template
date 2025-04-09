from bacpypes.core import run
from bacpypes.local.device import LocalDeviceObject
from bacpypes.service.device import WhoIsIAmServices
from bacpypes.app import BIPSimpleApplication
from bacpypes.object import AnalogValueObject, BinaryValueObject
from threading import Thread
import time
import random

# BACnet Device Definition
device = LocalDeviceObject(
    objectName="SimulatedUtilityBACnetDevice",
    objectIdentifier=1001,
    maxApduLengthAccepted=1024,
    segmentationSupported="segmentedBoth",
    vendorIdentifier=999  # Use your own vendor ID if applicable
)

# BACnet Application Setup
application = BIPSimpleApplication(device, "0.0.0.0")
application.add_capability(WhoIsIAmServices)


# Some Possible Simulated Objects

# Temperature Sensor
temp_sensor = AnalogValueObject(
    objectIdentifier = ('analogValue', 1),
    objectName = 'Temperature Sensor',
    presentValue = 70.0
)
temp_sensor.units = 'degrees Fahrenheit'
application.add_object(temp_sensor)

# Pressure Sensor
pressure_sensor = AnalogValueObject(
    objectIdentifier=('analogValue', 2),
    objectName='Zone1_Pressure',
    presentValue=1.2
)
pressure_sensor.units = 'bars'
application.add_object(pressure_sensor)

# Valve Position (0-100%)
valve_position = AnalogValueObject(
    objectIdentifier=('analogValue', 3),
    objectName='MainValve_Position',
    presentValue=45.0
)
valve_position.units = 'percent'
application.add_object(valve_position)

# System On/Off Status
system_status = BinaryValueObject(
    objectIdentifier=('binaryValue', 1),
    objectName='System_Status',
    presentValue=1  # 1 = ON, 0 = OFF
)
application.add_object(system_status)

# Simulation Loop 
def simulate_sensor_updates():
    while True:
        # Simulate gradual temperature drift
        temp_sensor.presentValue += random.uniform(-0.3, 0.5)
        temp_sensor.presentValue = round(temp_sensor.presentValue, 2)

        # Simulate slight pressure fluctuation
        pressure_sensor.presentValue += random.uniform(-0.05, 0.05)
        pressure_sensor.presentValue = round(pressure_sensor.presentValue, 3)

        # Simulate valve movement
        valve_position.presentValue += random.uniform(-1, 1)
        valve_position.presentValue = max(0, min(valve_position.presentValue, 100))  # Clamp between 0-100%

        print(f"[UPDATE] Temp: {temp_sensor.presentValue}°F | Pressure: {pressure_sensor.presentValue} bar | Valve: {valve_position.presentValue:.1f}%")

        time.sleep(2)  # Update every 2 seconds

def start_background_sim():
    print("[INFO] Starting sensor simulation thread...")
    sim_thread = Thread(target=simulate_sensor_updates, daemon=True)
    sim_thread.start()

if __name__ == "__main__":
    print("[INFO] BACnet Simulation Server is starting...")
    start_background_sim()
    run()