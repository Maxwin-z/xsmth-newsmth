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
    if (html.indexOf('<?xml version="1.0" encoding="utf-8"?>') != -1) {
        parse_m(html);
    } else {
        parse_www(html);
    }
}

function parse_www(html) {
	function docWriter(board, bid, start, man, ftype, page, total, apath, showHot, normalB) {
		data.currentPage = page;
	}
	docWriter.prototype = {
		o: function (id, gid, author, flag, time, title, size, imported, is_tex) {
			posts.push({
				gid: gid,
				title: title,
				author: author,
				date: time * 1000,
				isTop: flag.indexOf('d') != -1 || flag.indexOf('D') != -1
			});
		},
		t: function() {},
		f: function() {}
	}

	var rsp = {code: 0, data: data, message: ''};
	var posts = [];
    
    var script = html.match(/<!--((.|\s)*?)\/\/-->/)[0];
    eval(script);

    data.posts = posts.reverse();	// www模式，每页排序需反转

	console.log(rsp);
	window.location.href = 'newsmth://' + encodeURIComponent(JSON.stringify(rsp));
}

function parse_m(html) {
	var rsp = {code: 0, data: data, message: ''};
	var matches = html.match(/<ul class="list sec">.*?<\/ul>/);
	var isTzt = isTztMode(html);
	if (matches) {
		var div = document.createElement('div');
		div.innerHTML = matches[0];
		document.body.appendChild(div);

		var lis = div.querySelectorAll('li');
		for (var i = 0; i != lis.length; ++i) {
			var li = lis[i];
			var post = isTzt ? parseTztPost(li) : parseNormalPost(li);
			data.posts.push(post);
		}

		try {
        	data.notice = getNotice(html);
        	data.hasNotice = true;
		} catch (ignore) {}
	} else {
		rsp.code = -1;
		rsp.message = 'cannot find list <ul>';	
	}
	console.log(rsp);
	window.location.href = 'newsmth://' + encodeURIComponent(JSON.stringify(rsp));

}

function isTztMode (html) {
	var matches = html.match(/<div id="m_main"><div class="sec nav">.*?<\/div>/); 
	if (matches) {
		return matches[0].indexOf('经典') != -1;	// 显示"经典"按钮时表示同主题模式
	}
	return true;	// should not be here
}

function parseTztPost(li) {	// Tzt -> 同主题...
	var titleDiv = li.querySelector('div');

	var gid = li.querySelector('a').href.match(/\d+$/)[0];
	var isTop = li.querySelector('a').className.indexOf('top') != -1;
	var title = decode(titleDiv.childNodes[0].innerHTML);
	var replyCount = titleDiv.childNodes[1] ? titleDiv.childNodes[1].nodeValue.replace(/[^\d]/g, '') : 0;

	var authorDiv = li.querySelectorAll('div')[1];
	var date = parseDate(authorDiv.childNodes[0].nodeValue.replace(/[^\d\-:]/g, ''));
	var author = authorDiv.childNodes[1].innerHTML;
	var replyDate = parseDate(authorDiv.childNodes[2].nodeValue.replace(/[^\d\-:]/g, ''));
	var replyAuthor = authorDiv.childNodes[3].innerHTML;

	var isTop = !!(li.querySelector('.top'));

	return {
		__type: 'SMPost',
		gid: gid,
        pid: gid,
		title: title,
		author: author,
		date: date,
		replyAuthor: replyAuthor,
		replyDate: replyDate,
		replyCount: replyCount,
		isTop: isTop
	};	
}

function parseNormalPost(li) {
	var titleDiv = li.querySelector('div');

	var gid = li.querySelector('a').href.match(/(\d+)\/0$/)[1];
	var isTop = li.querySelector('a').className.indexOf('top') != -1;
	var title = decode(titleDiv.childNodes[0].innerHTML);

	var authorDiv = li.querySelectorAll('div')[1];
	var date = parseDate(authorDiv.childNodes[0].nodeValue.replace(/\d*[^\d]*([\d\-:]+)\s*/, '$1'));
	var author = authorDiv.childNodes[1].innerHTML;

	var isTop = !!(li.querySelector('.top'));

	return {
		__type: 'SMPost',
		gid: gid,
		title: title,
		author: author,
		date: date,
		replyAuthor: null,
		replyDate: 0,
		replyCount: 0,
		isTop: isTop
	};
}

function parseDate(dateStr) {
	if (dateStr.indexOf(':') != -1) {	// is 12:12:12
		dateStr = new Date().toString().replace(/\d\d:\d\d:\d\d/, dateStr);
	} else {	// 2013-06-12
		var ymd = dateStr.split('-');
		return new Date(ymd[0], ymd[1] - 1, ymd[2]).getTime();
	}
	return Date.parse(dateStr);
}
