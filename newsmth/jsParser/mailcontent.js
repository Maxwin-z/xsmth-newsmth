var data = {
	__type: 'SMResult',
	message: ''
};

function $parse(html) {
	var rsp = {code: 0, data: data, message: ''};

	var body = html.match(/<body>(.*)<\/body>/i)[1];
	var div = document.createElement('div');
	div.innerHTML = body;

	document.body.appendChild(div);

	data.message = div.querySelector('#m_main div.sp').innerHTML;

	try {
    	data.notice = getNotice(html);
    	data.hasNotice = true;
	} catch (ignore) {}

	
	console.log(rsp);
	$smth.sendData(rsp);
	// window.location.href = 'newsmth://' + encodeURIComponent(JSON.stringify(rsp));

} 
