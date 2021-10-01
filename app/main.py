from http.server import BaseHTTPRequestHandler, HTTPServer

PORT = 8000

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        print("REQUEST_RECEIVED")
        print("[GO_TO_S3]")
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'hello')

HTTPServer.allow_reuse_address = True 

with HTTPServer(("", PORT), Handler) as httpd:
    print("serving at port", PORT, flush=True)
    httpd.serve_forever()
