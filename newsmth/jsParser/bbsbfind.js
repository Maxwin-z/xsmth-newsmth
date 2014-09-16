var data = {
	__type: 'SMBoard',
	posts: [
		/*
		{
			__type: 'SMPost',
			gid: 0,
			title: '',
			author: '',
			date: 0,
			replyAuthor: '',
			replyDate: 0,
			replyCount: 0,
			isTop: false
		}
		*/
	],
	currentPage: 0
};

function decode(html) {
	return html.replace(/&lt;/ig, '<')
			.replace(/&gt;/ig, '>')
			.replace(/&quot;/ig, '"')
			.replace(/&#039;/g, "'")
			.replace(/&nbsp;/ig, ' ')
			.replace(/&amp;/ig, '&');
}


function $parse(html) {

	function tabWriter() {}
	tabWriter.prototype.r = function(idx, space, userLink, dateStr, postTitle) {
		var author = userLink.replace(/<.*?>/g, '');
		var date = Date.parse(new Date().toString().replace(/(\w+) \w+ \d+ (.*)/, '$1 ' + decode(dateStr) + ' $2'));
		var title = decode(postTitle.replace(/<.*?>/g, ''));
		var gid = postTitle.match(/<.*?&id=(\d+)">/i)[1];

		posts.push({
			__type: 'SMPost',
			gid: gid,
			title: title,
			author: author,
			date: date,
		});
	}
	tabWriter.prototype.t = function () {}

	var rsp = {code: 0, data: data, message: ''};
	var posts = [];
    
    var script = html.match(/<script>\s*(var ta =(.|\s)*?)<\/script>/)[1];
    eval(script);

    data.posts = posts.reverse();	// www模式，每页排序需反转

	console.log(rsp);
	$smth.sendData(rsp);
	// window.location.href = 'newsmth://' + encodeURIComponent(JSON.stringify(rsp));

}