var data = {
	__type: 'SMWriteResult',
	success: true
};

function $parse(html) {
	var rsp = {code: 0, data: data, message: ''};
	data.success = html.indexOf('操作成功: 发文成功！') != -1;
	console.log(rsp);
	window.location.href = 'newsmth://' + encodeURIComponent(JSON.stringify(rsp));
}