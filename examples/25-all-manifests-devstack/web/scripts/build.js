// Build the frontend: copy web/src into web/dist.
const fs = require("fs");
const path = require("path");

const src = path.join(__dirname, "..", "src");
const dist = path.join(__dirname, "..", "dist");

fs.rmSync(dist, { recursive: true, force: true });
fs.mkdirSync(dist, { recursive: true });
for (const entry of fs.readdirSync(src)) {
  fs.copyFileSync(path.join(src, entry), path.join(dist, entry));
}
console.log("web build: copied src -> dist");
