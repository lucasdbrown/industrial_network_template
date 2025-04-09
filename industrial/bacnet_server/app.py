from bacpypes.core import run
from bacpypes.local.device import LocalDeviceObject
from bacpypes.service.device import WhoIsIAmServices
from bacpypes.app import BIPSimpleApplication
from bacpypes.object import AnalogValueObject, BinaryValueObject
from threading import Thread
import time
import random
from flask import Flask, request, jsonify
from multiprocessing import Process

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

# Flask API for Scenario Control 
api = Flask(__name__)

@api.route("/status", methods=["GET"])
def status():
    return jsonify({
        "temperature": temp_sensor.presentValue,
        "pressure": pressure_sensor.presentValue,
        "valve_position": valve_position.presentValue,
        "system_status": "ON" if system_status.presentValue == 1 else "OFF"
    })

@api.route("/force_shutdown", methods=["POST"])
def force_shutdown():
    system_status.presentValue = 0
    return jsonify({"message": "System forced OFF by remote controller"}), 200

@api.route("/force_startup", methods=["POST"])
def force_startup():
    system_status.presentValue = 1
    return jsonify({"message": "System turned ON"}), 200

@api.route("/set_temp", methods=["POST"])
def set_temp():
    data = request.json
    value = float(data.get("value", 22.0))
    temp_sensor.presentValue = value
    return jsonify({"message": f"Temperature manually set to {value}°C"}), 200

@api.route("/set_value", methods=["POST"])
def set_value():
    """Generic setter: POST object_type, instance_number, property, value"""
    data = request.json
    obj_type = data.get("type")  
    instance = int(data.get("instance"))
    value = data.get("value")
    for obj in application.objectIdentifierToObject.values():
        if obj.objectType == obj_type and obj.instanceNumber == instance:
            obj.presentValue = type(obj.presentValue)(value)
            return jsonify({"message": f"{obj_type} {instance} set to {value}"}), 200
    return jsonify({"error": "Object not found"}), 404

# Starting Threads
def launch_threads():
    sim_thread = Thread(target=simulate_sensor_updates, daemon=True)
    sim_thread.start()
    print("[BACnet] Simulation thread running...")

    flask_thread = Thread(target=lambda: api.run(host="0.0.0.0", port=8025), daemon=True)
    flask_thread.start()
    print("[Flask] Control API running on port 8025...")


if __name__ == "__main__":
    print("[INFO] BACnet + Flask Scenario Server starting...")
    launch_threads()
    run()