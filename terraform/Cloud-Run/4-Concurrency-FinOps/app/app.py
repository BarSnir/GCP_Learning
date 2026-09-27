import os
import time
import uuid

from flask import Flask, jsonify, request


INSTANCE_ID = str(uuid.uuid4())[:8]

app = Flask(__name__)


@app.route("/")
def root():
    return jsonify({
        "service": os.environ.get("K_SERVICE"),
        "revision": os.environ.get("K_REVISION"),
        "instance": INSTANCE_ID
    })


@app.route("/slow")
def slow():
    seconds = float(request.args.get("seconds", "3"))

    time.sleep(seconds)

    return jsonify({
        "instance": INSTANCE_ID,
        "slept_seconds": seconds
    })


@app.route("/health")
def health():
    return jsonify({
        "status": "healthy"
    }), 200


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))

    app.run(
        host="0.0.0.0",
        port=port
    )