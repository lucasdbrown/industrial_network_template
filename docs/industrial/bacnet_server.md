# BACnet Server
`BACnet` is a communication protocol standard designed specifically to provide a way to integrate building control products made by different manufacturers.
`BACnet Server` is a device that provides BACnet objects and data to other devices (clients) on the network, allowing them to read and write to those objects.

### bacpypes installation
`pip install --user bacpypes`

### Purpose of the BACnet Server in the Template
A BACnet Server can be used for telemetry and updates of a system. 

## Functionality of BACnet Server

Checking status of BACnet server:
`curl http://localhost:8025/status`

Changing the value of the temperature.
`curl -X POST http://localhost:8025/set_temp -H "Content-Type: application/json" -d '{"value": 99}'`

### Example of Testing the functionality
```bash
$ curl http://localhost:8025/status
{"pressure":1.22,"system_status":"ON","temperature":73.67,"valve_position":43.27438018789375}

$ curl -X POST http://localhost:8025/set_temp -H "Content-Type: application/json" -d '{"value": 99}'
{"message":"Temperature manually set to 99.0\u00b0C"}

$ curl http://localhost:8025/status
{"pressure":1.705,"system_status":"ON","temperature":98.86,"valve_position":39.73617090819371}

$ curl http://localhost:8025/status
{"pressure":1.706,"system_status":"ON","temperature":98.62,"valve_position":38.36198706572897}
```
