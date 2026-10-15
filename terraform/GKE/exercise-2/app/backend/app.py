from flask import Flask, jsonify
import socket

app = Flask(__name__)

@app.route("/")
def home():
    return jsonify({
        "service": "backend",
        "message": "Hello from the backend",
        "hostname": socket.gethostname()
    })

@app.route("/health")
def health():
    return "ok", 200

app.run(host="0.0.0.0", port=8080)