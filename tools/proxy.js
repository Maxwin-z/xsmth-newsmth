var http = require('http');

http.createServer(function(req, res) {
	// console.log(req);
	var headers = req.headers;
	headers.host = 'www.newsmth.net';
	headers.path = req.url;
	console.log('proxy start: ', new Date(), req.url);
	// console.log(headers);
	var delay = 3;
	var proxyReq = http.request(headers, function(proxyRes) {
		// var responseText = '';
		// console.log(proxyRes.headers);

		var buf = new Buffer(0);

		res.writeHead(200, proxyRes.headers);
		proxyRes.on('data', function(chunk) {
			var nb = new Buffer(buf.length + chunk.length);
			buf.copy(nb, 0, 0, buf.length);
			chunk.copy(nb, buf.length, 0, chunk.length);
			buf = nb;
			// res.write(chunk);
		});
		proxyRes.on('end', function(chunk) {
			if (chunk != null) {
				// responseText += chunk.toString();
			}
			// console.log(responseText);
			setTimeout(function() {
				res.end(buf);
				console.log('proxy end: ', new Date(), req.url);
			}, delay * 1000);
			// res.end();
		});
	});
	req.on('data', function(chunk) {
		proxyReq.write(chunk);
	});
	req.on('end', function(chunk) {
		proxyReq.end(chunk);
	});
}).listen(8080);
