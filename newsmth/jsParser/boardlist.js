var data = {
	__type: 'SMBoardList',
	items: [
		/*
		{
			__type: 'SMBoardListItem',
			isDir: false,
			title: '',
			url: '',
			board: {
				__type: 'SMBoard',
				name: '',
				cnName: ''
			}
		}
		*/
	]
};

function $parse(html) {
	var rsp = {code: 0, data: data, message: ''};
	var matches = html.match(/<ul class="slist sec">.*?<\/ul>/);
	if (matches) {
		var div = document.createElement('div');
		div.innerHTML = matches[0];
		document.body.appendChild(div);

		var lis = div.querySelectorAll('li');
		for (var i = 0; i != lis.length; ++i) {
			var li = lis[i];
			var item = {
				__type: 'SMBoardListItem',
				isDir: false,
				title: '',
				url: '',
				board: {
					__type: 'SMBoard',
					name: '',
					cnName: ''
				}
			};

			if (li.querySelector('font')) {	// dir
				item.isDir = true;
				var a = li.querySelector('a');
				item.title = a.innerHTML;
				item.url = 'http://m.newsmth.net/' + a.pathname; 

				rsp.data.items.push(item);

			} else {
				item.isDir = false;
				var a = li.querySelector('a');
				var text = a.innerHTML;
				item.board = {
					__type: 'SMBoard',
					name: a.pathname.replace(/.*\/([^\/]*)/, '$1'),
					cnName: a.innerHTML
				};

					rsp.data.items.push(item);
			}
		}

		try {
	    	data.notice = getNotice(html);
	    	data.hasNotice = true;
		} catch (ignore) {}

	} else {
		rsp.code = -1;
		rsp.message = 'cannot find board list';
	}
	console.log(rsp);
	$smth.sendData(rsp);
	// window.location.href = 'newsmth://' + encodeURIComponent(JSON.stringify(rsp));
}
