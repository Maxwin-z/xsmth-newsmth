var data = {
	__type: 'SMPostGroup',
	tpage: 0,
	posts: [
		/*
		{
			__type: 'SMPost',
			gid: 0,	// for index id
			title: '',
			author: '',
			date: 0,
			isTop: false	// for read/unread
			board: {
				__type: 'SMBoard',
				name: ''
			}
		}
		*/
	]
};


function $parse(html) {
	var rsp = {code: 0, data: data, message: ''};
	
	// remove <script>
	html = html.replace(/<script .*?<\/script>/ig, '');
	var div = document.createElement('div');
	div.innerHTML = html;

	document.body.appendChild(div);

	// query table trs
	var trs = div.querySelectorAll('.m-table tbody tr');
	for (var i = 0; i != trs.length; ++i) {
		var tr = trs[i];
		var as = tr.querySelectorAll('a');
		if (as.length < 3) continue;

		var unread = tr.className.indexOf('no-read') != -1;
		var author = as[0].innerHTML;
		var boardName = as[1].innerHTML;

		var title_a = as[2];
		var index = title_a.getAttribute('_index');
		var title = title_a.innerHTML;
		var date = parseDate(tr.querySelector('.title_4').innerHTML);

		var post = {
			__type: 'SMPost',
			gid: index,
			title: title,
			author: author,
			date: date,
			isTop: unread,
			board: {
				__type: 'SMBoard',
				name: boardName
			}
		}

		data.posts.push(post);
	}

	// get total page
	var as = div.querySelectorAll('.t-pre-bottom .page .page-main li a')
	var tpage = 0;
	for (var i = 0; i != as.length; ++i) {
		var a = as[i];
		var t = parseInt(a.innerHTML);
		if (isNaN(t)) t = 0;
		tpage = Math.max(t, tpage);
	}
	data.tpage = tpage;

	console.log(rsp);
	window.location.href = 'newsmth://' + encodeURIComponent(JSON.stringify(rsp));

}

function parseDate(dateStr) {
	var ymdhis = dateStr.split(/[^\d]+/);
	return new Date(ymdhis[0], ymdhis[1] - 1, ymdhis[2], ymdhis[3], ymdhis[4], ymdhis[5]).getTime();
}
