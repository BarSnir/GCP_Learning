import os

from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/")
def root():
    return jsonify({
        "service": "cloud-run-ex1-api",
        "version": "v1",
        "status": "running"
    })


@app.route("/health")
def health():
    return jsonify({
        "status": "healthy"
    }), 200


@app.route("/hello")
def hello():
    return jsonify({
        "message": "Hello from Cloud Run Exercise 1"
    })


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))

    app.run(
        host="0.0.0.0",
        port=port
    )