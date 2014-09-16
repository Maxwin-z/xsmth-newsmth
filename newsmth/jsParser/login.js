function $parse(html) {
	var rsp = {code: 0, data: null, message: null};
	var matches = html.match(/<div class="sp hl f">(.*?)<\/div>/);
	if (!matches || matches[1] != '登陆成功') {
		rsp.code = -1;
		rsp.message = matches ? matches[1] : 'parser error';
	}
	console.log(rsp);
	$smth.sendData(rsp);
	// window.location.href = 'newsmth://' + encodeURIComponent(JSON.stringify(rsp));
}

