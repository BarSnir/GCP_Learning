import os

from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/")
def root():
    return jsonify({
        "exercise": 7,
        "deployment_method": "git-cloud-build-trigger",
        "service": os.environ.get("K_SERVICE"),
        "revision": os.environ.get("K_REVISION"),
        "version": "v1"
    })


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port)