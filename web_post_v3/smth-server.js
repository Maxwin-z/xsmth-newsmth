const http = require("http");
const https = require("https");
const iconv = require("iconv-lite");

const server = http.createServer((req, res) => {
  let data = [];
  req.on("data", chunk => data.push(chunk));
  req.on("end", () => {
    // console.log(JSON.parse(data));
    let url, headers;
    try {
      const body = Buffer.concat(data).toString();
      const json = JSON.parse(body);
      url = json.url;
      headers = json.headers;
    } catch (e) {
      res.end(e.toString());
      return;
    }
    console.log("forward: ", url);
    https.get(
      url,
      {
        headers
      },
      smthRes => {
        const isGBK =
          smthRes.headers["content-type"].indexOf("charset=GBK") !== -1;
        data = [];
        smthRes.on("data", chunk => data.push(chunk));
        smthRes.on("end", () => {
          const body = Buffer.concat(data);
          const html = isGBK ? iconv.decode(body, "GBK") : body.toString();
          res.writeHead(200);
          res.end(html);
        });
      }
    );
  });
});

server.listen(3001);
