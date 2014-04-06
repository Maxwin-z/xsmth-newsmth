var data = {
	__type: 'SMBoardList',
	items: [
		/*
		{
			__type: 'SMBoardListItem',
			isDir: false,
			title: '',
			url: '',
			board: {
				__type: 'SMBoard',
				name: '',
				cnName: ''
			}
		}
		*/
	]
};

function brdWriter(father, select, fix) {
    
}

brdWriter.prototype.f = function (select, desc, npos, name) {
    data.items.push({
        __type: 'SMBoardListItem',
        isDir: true,
        title: desc + '(' + name +')',
        url: 'http://www.2.newsmth.net/bbsfav.php?x&select=' + select
    });
}

brdWriter.prototype.o = function (group, unread, bid, lastpost, cls, name, desc, bms, artcnt, npos, online) {
    data.items.push({
        __type: 'SMBoardListItem',
        isDir: false,
        title: desc + '(' + name + ')',
        board: {
            __type: 'SMBoard',
            name: name,
            cnName: desc,
            bid: bid
        }
    });
}

brdWriter.prototype.t = function () {}

function $parse(html) {
    var script = html.match(/<!--((.|\s)*?)\/\/-->/)[0];
    eval(script);
    var rsp = {code: 0, data: data, message:''};
	
	console.log(rsp);
	window.location.href = 'newsmth://' + encodeURIComponent(JSON.stringify(rsp));
}
