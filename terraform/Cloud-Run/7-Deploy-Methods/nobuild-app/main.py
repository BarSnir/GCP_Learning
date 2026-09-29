import json
import os

from http.server import BaseHTTPRequestHandler, HTTPServer


class Handler(BaseHTTPRequestHandler):

    def do_GET(self):
        response = {
            "exercise": 7,
            "deployment_method": "no-build",
            "service": os.environ.get("K_SERVICE"),
            "revision": os.environ.get("K_REVISION"),
            "version": "v1"
        }

        body = json.dumps(response).encode()

        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()

        self.wfile.write(body)


port = int(os.environ.get("PORT", "8080"))

server = HTTPServer(("0.0.0.0", port), Handler)

print(f"Listening on port {port}", flush=True)

server.serve_forever()