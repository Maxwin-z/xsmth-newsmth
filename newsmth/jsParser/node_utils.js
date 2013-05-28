var http = require('http');
var Iconv = require('iconv').Iconv;

exports.httpget = function(url, callback) {
    url = url.replace(/^http:\/\//, '');
    var host = url.split('/', 1)[0];
    var path = url.substring(host.length);

    var buf = new Buffer(0);
    http.request({
        host: host,
        path: path
    }, function (rsp) {
        rsp.on('data', function(chunk) {
            var tmp = new Buffer(buf.length + chunk.length);
            buf.copy(tmp, 0, 0, buf.length);
            chunk.copy(tmp, buf.length, 0, chunk.length);
            buf = tmp;
        });
        rsp.on('end', function() {
            var iconv = new Iconv('GB18030', 'UTF-8')
            var body = iconv.convert(buf).toString();
            // var body = buf.toString();
            callback(body); 
        });
    }).end();
}

