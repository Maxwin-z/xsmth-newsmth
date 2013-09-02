/* SMPostGroup */
var data = {
	__type: 'SMPostGroup',
	bid: 0,
	tpage: 0,
	title: '',
	posts: [	/* SMPost */
	/* {
		id: 0,
		nick: ''
	}, ... */]
}

function tconWriter(board, bid, gid, start, tpage, pno, serial, prevgid, nextgid,title) {
	data.bid = bid;
	data.tpage = tpage;
	data.title = title;
}

tconWriter.prototype.o = function(arr) {
	data.posts = [];
	for (var i = 0; i != arr.length; ++i) {
		var post = {
			__type: 'SMPost',
			pid: arr[i][0],
			author: arr[i][1],
			nick: arr[i][1]
		}
		data.posts.push(post);
	}
}

tconWriter.prototype.h = function() {}

function $parse(html) {
	var rsp = {code: 0, data: null, message: ''};
	var script = html.match(/<!--((.|\s)*?)\/\/-->/);
	if (script == null) {	// error
		var errorTable = html.match(/<table class="error">(.|\s)*?<\/table>/)[0];
		if (errorTable) {
			var msg = errorTable.replace(/<.+?>/g, '').replace(/\s+/g, ' ');
			rsp = {code: -1, data: null, message: msg};
		}
	} else {
    	eval(script[0]);
    	rsp.data = data;
    }

	console.log(rsp);
	window.location.href = 'newsmth://' + encodeURIComponent(JSON.stringify(rsp));
}