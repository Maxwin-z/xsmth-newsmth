var data = {
	__type: 'SMUpload',
	act: 0,	// 1 add	2 delete	
	message: '',
	items: [
		/*
		{
			__type: 'SMUploadItem',
			name: '',
			key: ''
		}
		*/
	],
	leftCount: 0,
	leftSize: 0
}


function $parse(html) {
	var rsp = {code: 0, data: data, message: ''};
	var matches = html.match(/<font color='red'>(.*)<\/font>/);
	if (matches) {
		data.message = matches[1];
		if (data.message.indexOf('上传成功') != -1) {
			data.act = 1;
		} else if (data.message.match(/提示：删除.*成功/)) {
			data.act = 2;
		} else {
			rsp.code = -1;	 // 出现错误
			rsp.message = data.message;
		}
	} 

	// 取已上传的列表
	matches = html.match(/<ol(.|\s)*?<\/ol>/);
	if (matches) {
		var div = document.createElement('div');
		div.innerHTML = matches[0];

		var lis = div.querySelectorAll('ol li');
		for (var i = 0; i != lis.length; ++i) {
			var li = lis[i];
			var name = li.firstChild.nodeValue;
			var key = li.querySelector('a').href.replace(/javascript:deletesubmit\('([^']+)'\).*/, '$1');
			data.items.push({
				__type: 'SMUploadItem',
				name: name,
				key: key
			})
		}
	}


    console.log(rsp);
    $smth.sendData(rsp);
    // window.location.href = 'newsmth://' + encodeURIComponent(JSON.stringify(rsp));
}
