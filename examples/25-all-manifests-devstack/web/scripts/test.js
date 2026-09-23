// Trivial frontend test: the source page must exist.
const fs = require("fs");
const path = require("path");

const page = path.join(__dirname, "..", "src", "index.html");
if (!fs.existsSync(page)) {
  console.error("web test: missing src/index.html");
  process.exit(1);
}
console.log("web test: ok");
