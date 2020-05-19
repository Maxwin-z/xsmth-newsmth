const fs = require('fs')
const path = require('path')
const manifest = fs.readFileSync(path.join(__dirname, './public/manifest.json')).toString()
console.log(manifest)