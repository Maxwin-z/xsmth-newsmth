var data = [
	/*
	{
		sectionTitle: '',
		items:[{
			author: '',
			title: '',
			board: '',
			boardName: '',
			gid: 0
		}, ...]
	}, ...
	*/
];

function $parse(html) {
	var rsp = {code: 0, data: null, message: ''};
	try {
		parseTop10(html);
		console.log(data);
		rsp.data = data;
	} catch (e) {
		rsp.code = -1;
		rsp.message = e.message;
	}
	window.location.href = 'newsmth://' + encodeURIComponent(JSON.stringify(rsp));
	return rsp;
}

function parseTop10(html) {
	var top10regex = /<table[^>]*class="HotTable"(.|\s)*?<\/table>/;
	var matchs = html.match(top10regex);
	var top10html = matchs[0];

	var div = document.createElement('div');
	div.innerHTML = top10html;
	document.body.appendChild(div);

	// get datas
	var top10items = [];

	var trs = div.querySelectorAll('tr');
	for (var i = 0; i != trs.length; ++i) {
		top10items.push(parseTop10item(trs[i]));
	}

	data.push({
		sectionTitle: '本日热点话题讨论',
		items: top10items
	});
}

function parseTop10item(tr) {
	var item = {};
	var as = tr.querySelectorAll('a');

	var a_board = as[0];
	item.boardName = a_board.innerHTML;
	item.board = a_board.search.match(/board=(.+)/)[1];

	var a_post = as[1];
	item.title = a_post.innerHTML;
	item.gid = a_post.search.match(/gid=(\d+)/)[1];

	item.author = as[2].innerHTML;

	return item;
}
