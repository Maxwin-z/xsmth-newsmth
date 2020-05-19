const fs = require("fs");
const path = require("path");
const manifest = JSON.parse(
  fs.readFileSync(path.join(__dirname, "./public/manifest.json")).toString()
);
const indexHtml = fs
  .readFileSync(path.join(__dirname, "./build/index.html"))
  .toString();
const loader = indexHtml.replace(/^.*<script>(.*?)<\/script>.*$/, "$1");
fs.writeFileSync(path.join(__dirname, "build/static/js/loader.js"), loader);
const jsFiles = fs
  .readdirSync(path.join(__dirname, "build/static/js/"))
  .filter((file) => file.match(/\.js$/)).map(file => `./static/js/${file}`);
const cssFiles = fs
  .readdirSync(path.join(__dirname, "build/static/css/"))
  .filter((file) => file.match(/\.css$/)).map(file => `./static/css/${file}`);
manifest.content_scripts[0].js = jsFiles;
manifest.content_scripts[0].css = cssFiles;
fs.writeFileSync(
  path.join(__dirname, "build/manifest.json"),
  JSON.stringify(manifest, true, 2)
);
console.log(manifest)
console.log("done");
