var data = {
	__type: 'SMWriteResult',
	success: true,
	message: ''
};

function $parse(html) {
	var rsp = {code: 0, data: null, message: ''};
	var success = html.match(/操作成功/);
	if (success == null) {	// error
		var errorTable = html.match(/<table class="error">(.|\s)*?<\/table>/)[0];
		if (errorTable) {
			var msg = errorTable.replace(/<.+?>/g, '').replace(/\s+/g, ' ');
			rsp = {code: -1, data: null, message: msg};
		}
	} else {
		// success
    	rsp.data = data;
    }

	console.log(rsp);
	window.location.href = 'newsmth://' + encodeURIComponent(JSON.stringify(rsp));
}
