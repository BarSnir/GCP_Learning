from flask import Flask, jsonify
import requests
import socket

app = Flask(__name__)

@app.route("/")
def home():
    response = requests.get("http://backend:8080", timeout=3)

    return jsonify({
        "service": "frontend",
        "hostname": socket.gethostname(),
        "backend_response": response.json()
    })

@app.route("/health")
def health():
    return "ok", 200

app.run(host="0.0.0.0", port=8080)