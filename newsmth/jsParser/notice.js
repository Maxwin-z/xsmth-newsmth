/*

SMNotice {
	int at
	int reply
	int mail
}

*/

function $parse(html) {
	var rsp = {code: 0, data: getNotice(html), message: ''};
	console.log(rsp);
	window.location.href = 'newsmth://' + encodeURIComponent(JSON.stringify(rsp));
}


