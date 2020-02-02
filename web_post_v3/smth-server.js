const http = require("http");
const https = require("https");
const iconv = require("iconv-lite");

const server = http.createServer((req, res) => {
  let data = [];
  req.on("data", chunk => data.push(chunk));
  req.on("end", () => {
    // console.log(JSON.parse(data));
    const body = Buffer.concat(data).toString();
    const { url, withXhr } = JSON.parse(body);
    console.log("forward: ", url);
    https.get(
      url,
      {
        headers: withXhr
          ? {
              "X-Requested-With": "XMLHttpRequest"
            }
          : {}
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
