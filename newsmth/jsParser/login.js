function $parse(html) {
	var rsp = {code: 0, data: null, message: null};

    if (html.indexOf('水木二站') != -1 && html.indexOf('的收藏夹</title>') != -1) {
        
    } else {
    	var matches = html.match(/<div class="sp hl f">(.*?)<\/div>/);
        if (!matches || matches[1] != '登陆成功') {
            rsp.code = -1;
            rsp.message = matches ? matches[1] : '解析登录页面失败，请重试';
        }
    }

	console.log(rsp);
	window.location.href = 'newsmth://' + encodeURIComponent(JSON.stringify(rsp));
}

