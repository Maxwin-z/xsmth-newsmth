/* SMPostGroup */
var data = {
	__type: 'SMPostGroup',
	bid: 0,
	tpage: 0,
	title: '',
	posts: [	/* SMPost */
	/* {
		id: 0,
		nick: ''
	}, ... */]
}

function decode(html) {
	return html.replace(/&lt;/ig, '<')
			.replace(/&gt;/ig, '>')
			.replace(/&quot;/ig, '"')
			.replace(/&#039;/g, "'")
			.replace(/&nbsp;/ig, ' ')
			.replace(/&amp;/ig, '&');
}

function $parse(html) {
    if (html.indexOf('<?xml version="1.0" encoding="utf-8"?>') != -1) {
        parse_m(html);
    } else {
        parse_www(html);
    }
}

function tconWriter(board, bid, gid, start, tpage, pno, serial, prevgid, nextgid,title) {
	data.bid = bid;
	data.tpage = tpage;
    if (title) {
        data.title = decode(title);
    }
}

tconWriter.prototype.o = function(arr) {
	data.posts = [];
	for (var i = 0; i != arr.length; ++i) {
		var post = {
			__type: 'SMPost',
			pid: arr[i][0],
			author: arr[i][1],
			nick: arr[i][1]
		}
		data.posts.push(post);
	}
}

tconWriter.prototype.h = function() {}

function parse_www(html) {
	var rsp = {code: 0, data: null, message: ''};
	var script = html.match(/<!--((.|\s)*?)\/\/-->/);
	if (script == null) {	// error
		var errorTable = html.match(/<table class="error">(.|\s)*?<\/table>/)[0];
		if (errorTable) {
			var msg = errorTable.replace(/<.+?>/g, '').replace(/\s+/g, ' ');
			rsp = {code: -1, data: null, message: msg};
		}
	} else {
    	eval(script[0]);
        if (data.title.length == 0) {  // www.2.
            html.replace(/<h1\s+class="ttit">(?:同主题阅读：\s*)(.+)<\/h1>/i, function ($0, $1) {
                data.title = decode($1 || '');
            });
        }
    	rsp.data = data;
    }

	console.log(rsp);
	window.location.href = 'newsmth://' + encodeURIComponent(JSON.stringify(rsp));
}


/////////////////////////////////////////////
function parse_m(html) {
    var body = html.match(/<body(.*)<\/body>/i)[1];
    var div = document.createElement('div');
    div.innerHTML = body;
    document.body.appendChild(div);

    var as = div.querySelectorAll('#m_main .sec.nav form a.plant');
    for (var i = 0; i != as.length; ++i) {
    	var a = as[i];
    	var matches = a.innerHTML(/(\d+)\/(\d+)/);
    	if (matches) {
    		data.tpage = matches[2];
    	}
    }
}
