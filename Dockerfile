FROM python:3.11-slim
WORKDIR /app
RUN echo "from http.server import HTTPServer, BaseHTTPRequestHandler\n\nclass Handler(BaseHTTPRequestHandler):\n    def do_GET(self):\n        self.send_response(200)\n        self.end_headers()\n        self.wfile.write(b'Hello from CI-built image')\n\nHTTPServer(('0.0.0.0', 5000), Handler).serve_forever()" > app.py
CMD ["python", "app.py"]
