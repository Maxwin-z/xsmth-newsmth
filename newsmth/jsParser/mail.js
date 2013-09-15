var data = {
	__type: 'SMMailList',
	items: [
		/*
		{
			__type: 'SMMailItem',
			author: '',
			title: '',
			date: 0l
		}
		*/
	],
	tpage: 0,
	hasMail: false
};


function $parse(html) {
	var rsp = {code: 0, data: data, message: ''};
	// get total page
	html.replace(/<a\s+href="\/mail\/.*?\?p=(\d+)">尾页<\/a>/, function($0, $1) {
		data.tpage = $1;
	});
	// <a href="/mail/inbox?p=2">尾页</a>

	var matches = html.match(/<ul class="list sec">.*?<\/ul>/);
	if (matches) {
		var div = document.createElement('div');
		div.innerHTML = matches[0];
		document.body.appendChild(div);

		var lis = div.querySelectorAll('li');
		if (lis.length == 1 && lis[0].innerHTML == '没有任何信件') {
			data.hasMail = false;
		} else {
			data.hasMail = true;
			for (var i = 0; i != lis.length; ++i) {
				var li = lis[i];
				var as = li.querySelectorAll('a');
				var title_a = as[0];
				var url = title_a.pathname;
				var title = title_a.innerHTML;
				var author_a = as[1];
				var author = author_a.pathname.replace(/.*\/([^\/]+)$/, '$1');
				var dateText = author_a.nextSibling.nodeValue.replace(/[^\d :\-]/g, '');
				var date = parseDate(dateText);

				data.items.push({
					__type: 'SMMailItem',
					title: title,
					author: author,
					date: date,
					url: url
				});
			}
		}
	} else {
		rsp.code = -1;
		rsp.message = 'cannot find list <ul>';	
	}
	console.log(rsp);
	window.location.href = 'newsmth://' + encodeURIComponent(JSON.stringify(rsp));

}

function parseDate(dateStr) {
	var ymdhis = dateStr.split(/[^\d]+/);
	return new Date(ymdhis[0], ymdhis[1] - 1, ymdhis[2], ymdhis[3], ymdhis[4], ymdhis[5]).getTime();
}
