var http = require('http');
var crypto = require('crypto');

crypto.DEFAULT_ENCODING = 'binary';

var mysql = require('mysql');
var pool  = mysql.createPool({
  host     : '192.168.3.131',
  user     : 'root',
  password : '1234',
  database : 'xsmth'
});


var k = '0123456789012345';
var v = '0123456789012345';
var alg = 'AES-128-CBC';

var code = 100;
var Codes = {
	AddDonate: code++,
	GetDonate: code++
};

http.createServer(function(request, response) {
	var data = new Buffer(0);
	request.on('data', function (chunk) {
		data = concatBuffer(data, chunk);
	});
	request.on('end', function (chunk) {
		if (chunk) {
			data = concatBuffer(data, chunk);
		}		

		handleRequest(data, response);
	});
}).listen(8081);

function concatBuffer(buf1, buf2) {
	var buffer = new Buffer(buf1.length + buf2.length);
	buf1.copy(buffer, 0, 0, buf1.length);
	buf2.copy(buffer, buf1.length, 0, buf2.length);
	return buffer;
}

function handleRequest(data, response) {
	var json = decrypt(data);
	if (json == null) {
		sendResponse(response, {
			error: -1,
			message: 'invalid request'
		});
	}
	if (json.code == Codes.AddDonate) {
		handleRequestDonate(json, response);
	}
}

function handleRequestDonate(json, response) {
	var user = json.user;
	var product = json.product;
	var message = json.message;
	var addtime = json.addtime;

	pool.getConnection(function(err, connection) {
		if (err) {
			return sendResponse(response, {error: -1, message: err.toString()});
		}
		connection.query('INSERT INTO donate SET ?', {
			user: user,
			product: product,
			message: message,
			addtime: addtime
		}, function (err, result) {
			console.log(err, result);
			sendResponse(response, {error: 0, message: null});
		});
	});

}

function sendResponse(response, json) {
	response.writeHead(200, {
		'Content-Type': 'text/json'
	});
	response.end(JSON.stringify(json || {error: -1}));
}

function executeSql(sql, callback) {
	pool.getConnection(function(err, connection) {
		if (!connection) {
			console.log('getConnection error:', err);
			callback(err, null);
			return ;
		}
		connection.query(sql, function(err, result) {
			callback(err, result);
			connection.release();
		});
	});
}

function decrypt(data) {
	var res = null;
	try {
		var decipher = crypto.createDecipheriv(alg, k, v);
		decipher.setAutoPadding(auto_padding=false);
		var result = decipher.update(data);
		result += decipher.final();
		var buf = new Buffer(result, 'binary');

		var str = buf.toString();
		str = str.replace(/\0+$/g, '');
		res = JSON.parse(str);
	} catch(e) {
		console.log(e);
	}
	return res;
}
