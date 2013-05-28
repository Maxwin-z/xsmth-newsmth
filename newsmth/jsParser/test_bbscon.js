var util = require('./node_utils');
var fs = require('fs');
var http = require('http');

util.httpget('http://www.newsmth.net/bbscon.php?bid=133&id=1936479557', function(body) {
    // start server 
        http.createServer(function(req, res) {
        var utils = fs.readFileSync('./utils.js').toString();
        var parser = fs.readFileSync('./bbscon.js').toString();
        var js = '<script type="text/javascript">' + utils + parser + '</script>';
        var html = body.replace('charset=gb2312', 'charset=utf-8');
        html = html.replace(/<title>.*<\/title>/, js);
        html = html.replace(/<script[^>]+src=[^>]+><\/script>/g, '');
        console.log(body);

        res.writeHead(200, {'Content-type': 'text/html'});
        res.end(html);
    }).listen(8080);
});


