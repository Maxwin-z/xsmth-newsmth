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
	
	console.log(rsp);
	window.location.href = 'newsmth://' + encodeURIComponent(JSON.stringify(rsp));

} 
