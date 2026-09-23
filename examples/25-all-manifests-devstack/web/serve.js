// Tiny static file server for the web workspace.
// Reads PORT (assigned by gaffer-exec --auto-port) and serves web/dist,
// falling back to web/src when the build has not run yet.
const http = require("http");
const fs = require("fs");
const path = require("path");

const port = Number(process.env.PORT || 3000);
const root = fs.existsSync(path.join(__dirname, "dist"))
  ? path.join(__dirname, "dist")
  : path.join(__dirname, "src");

const server = http.createServer((req, res) => {
  const rel = req.url === "/" ? "/index.html" : req.url.split("?")[0];
  const file = path.join(root, rel);
  fs.readFile(file, (err, data) => {
    if (err) {
      res.writeHead(404, { "Content-Type": "text/plain" });
      res.end("not found\n");
      return;
    }
    res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
    res.end(data);
  });
});

server.listen(port, () => {
  console.log(`web listening on http://localhost:${port}`);
});
