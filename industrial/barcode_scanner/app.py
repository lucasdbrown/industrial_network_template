from flask import Flask, jsonify, request
import random
import json

app = Flask(__name__)

# Load test barcodes from a file or define in-memory
test_barcodes = [
    {"barcode": "PKG123456", "item": "Bottle", "status": "OK"},
    {"barcode": "PKG654321", "item": "Box", "status": "Damaged"},
    {"barcode": "PKG111222", "item": "Can", "status": "OK"},
]

@app.route("/scan", methods=["GET"])
def scan_barcode():
    """Simulate scanning a barcode"""
    scanned = random.choice(test_barcodes)
    return jsonify({"scanned_data": scanned})

@app.route("/barcodes", methods=["GET"])
def get_all_barcodes():
    return jsonify(test_barcodes)

@app.route("/submit", methods=["POST"])
def submit_barcode():
    """Optional: Accept manually submitted barcode data"""
    data = request.json
    test_barcodes.append(data)
    return jsonify({"message": "Barcode received", "data": data}), 201

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)