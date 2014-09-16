var data = {
	__type: 'SMUser',
	info: ''
}


function $parse(html) {
	var rsp = {code: 0, data: data, message: ''};
	var matches = html.match(/<pre>\s*((.|\s)*?)<\/pre>/);
	if (matches) {
		data.info = matches[1].replace(/<[^>]*>/g, '');
	} else {
		rsp.code = -1;
		rsp.message = 'cannot find userinfo <pre> tag';
	}
    console.log(rsp);
    $smth.sendData(rsp);
    // window.location.href = 'newsmth://' + encodeURIComponent(JSON.stringify(rsp));
}