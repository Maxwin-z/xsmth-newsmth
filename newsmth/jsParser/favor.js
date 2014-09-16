var data = {
	__type: 'SMFavor',
	boards: [
		/*
		{
			__type: 'SMBoard',
			bid: 0,
			name: ''
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

		// get boards
		var as = div.querySelectorAll('a');
		for (var i = 0; i != as.length; ++i) {
			var a = as[i];
			var text = a.innerHTML;
			var a_matchs = text.match(/(.+)\((.+)\)/);
			if (a_matchs) {
				data.boards.push({
					__type: 'SMBoard',
					name: a_matchs[2],
					cnName: a_matchs[1]
				});
			}
		}		
	} else {
		rsp.code = -1;
		rsp.message = 'cannot find favor <ul>';
	}
	console.log(rsp);
	$smth.sendData(rsp);
	// window.location.href = 'newsmth://' + encodeURIComponent(JSON.stringify(rsp));
}
