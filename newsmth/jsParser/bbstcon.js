var data = {
	bid: 0,
	tpage: 0,
	title: '',
	posts: [
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
			id: arr[i][0],
			nick: arr[i][1]
		}
		data.posts.push(post);
	}
}

tconWriter.prototype.h = function() {}

function $parse(html) {
	var script = html.match(/<!--((.|\s)*?)\/\/-->/)[0];
    eval(script);

	var rsp = {code: 0, data: data, message: ''};
	console.log(rsp);
	window.location.href = 'newsmth://' + encodeURIComponent(JSON.stringify(rsp));
}