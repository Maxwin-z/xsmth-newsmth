var data = {
	__type: 'SMWriteResult',
	success: true,
	message: ''
};

function $parse(html) {
	// default is success
	var rsp = {code: 0, data: data, message: ''};

	// fail
	if (html.indexOf('<div id="m_main"><div class="sp hl f">发表成功</div>') == -1) {
		var matches = html.match(/<div id="m_main"><div class="sp hl f">(.+?)<\/div>/);
		if (matches) {	// 权限错误等
			data.success = false;
			data.message = matches[1];
		} else {	// 未知错误
			rsp.code = -1;
			rsp.message = '未知错误';
		}
	}

	console.log(rsp);
	$smth.sendData(rsp);
	// window.location.href = 'newsmth://' + encodeURIComponent(JSON.stringify(rsp));
}