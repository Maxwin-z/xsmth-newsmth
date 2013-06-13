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
	]
};


function $parse(html) {
	var rsp = {code: 0, data: data, message: ''};
	var matches = html.match(/<ul class="list sec">.*?<\/ul>/);
	if (matches) {
		var div = document.createElement('div');
		div.innerHTML = matches[0];
		document.body.appendChild(div);

		var lis = div.querySelectorAll('li');
		for (var i = 0; i != lis.length; ++i) {
			var li = lis[i];
			var titleDiv = li.querySelector('div');

			var gid = li.querySelector('a').href.match(/\d+$/)[0];
			var title = titleDiv.childNodes[0].innerHTML;
			var replyCount = titleDiv.childNodes[1].nodeValue.replace(/[^\d]/g, '');

			var authorDiv = li.querySelectorAll('div')[1];
			var date = parseDate(authorDiv.childNodes[0].nodeValue.replace(/[^\d\-:]/g, ''));
			var author = authorDiv.childNodes[1].innerHTML;
			var replyDate = parseDate(authorDiv.childNodes[2].nodeValue.replace(/[^\d\-:]/g, ''));
			var replyAuthor = authorDiv.childNodes[3].innerHTML;

			var isTop = !!(li.querySelector('.top'));

			data.posts.push({
				__type: 'SMPost',
				gid: gid,
				title: title,
				author: author,
				date: date,
				replyAuthor: replyAuthor,
				replyDate: replyDate
			});
		}
	} else {
		rsp.code = -1;
		rsp.message = 'cannot find list <ul>';
	}
	console.log(rsp);
	window.location.href = 'newsmth://' + encodeURIComponent(JSON.stringify(rsp));

}

function parseDate(dateStr) {
	if (dateStr.indexOf(':') != -1) {
		dateStr = new Date().toString().replace(/\d\d:\d\d:\d\d/, dateStr);
	}
	return Date.parse(dateStr);
}
