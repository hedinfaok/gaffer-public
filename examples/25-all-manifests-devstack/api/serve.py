"""Minimal HTTP API for the all-manifests dev stack.

Reads PORT (assigned by gaffer-exec --auto-port) and answers two routes:
  GET /health  -> {"status": "ok"}
  GET /        -> {"service": "api", "port": <port>}
"""
import json
import os
from http.server import BaseHTTPRequestHandler, HTTPServer


def payload_for(path):
    if path == "/health":
        return {"status": "ok"}
    return {"service": "api", "port": int(os.environ.get("PORT", "3000"))}


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):  # noqa: N802 (http.server API)
        body = json.dumps(payload_for(self.path)).encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *args):  # keep the console quiet
        pass


def main():
    port = int(os.environ.get("PORT", "3000"))
    server = HTTPServer(("127.0.0.1", port), Handler)
    print(f"api listening on http://localhost:{port}")
    server.serve_forever()


if __name__ == "__main__":
    main()
