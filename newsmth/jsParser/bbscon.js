/* SMPost */
var data = {
    __type: 'SMPost',
    pid: 0,
    gid: 0,
    author: '',
    nick: '',
    title: '',
    content: '',
    date: 0,
    attaches:[  /* SMAttach */
        /*{
            boardName: '',
            pid: 0,
            name: '',
            len: 0,
            pos: 0
        }*/
    ],
    board: {
        __type: 'SMBoard',
        bid: '',
        name: '',
        cnName: ''
    }
};

//////////////////////////////////////////////////////
function emptyFn() {}

// conWriter
function conWriter(ftype, board, bid, id, gid, reid, favtxt, num, istex, title) {
    data.pid = id;
    data.bid = bid;
    data.gid = gid;
    data.board = {
        __type: 'SMBoard',
        bid: bid,
        name: board
    };
    data.title = title;
}

conWriter.prototype.h = emptyFn;
conWriter.prototype.t = emptyFn;

// attWriter
function attWriter(bid, id, ftype, num, cacheable){}


// prints
function prints(content) {
    var nickRegex = /^发信人: (.+)\((.*)\), /;
    var dateRegex = /^发信人: .+\(.*\), 信区: .+\n标  题: .*\n发信站:.+\([A-Z][a-z]{2} +([A-Z][a-z]{2} +\d+ +\d{1,2}:\d{1,2}:\d{1,2} +\d{4})\)/;
    var contentRegex = /^发信人: .+\(.*\), 信区: .+\n标  题: .*\n发信站: .+站内\n{1,2}((.|\s)*)$/;

    var matchs = null;

    matchs = content.match(nickRegex);
    data.author = matchs == null ? "" : matchs[1];
    data.nick = matchs == null ? "" : matchs[2];

    matchs = content.match(dateRegex);
    data.date = matchs == null ? 0 : Date.parse(matchs[1]);

    matchs = content.match(contentRegex);
    data.content = formatContent(matchs == null ? content : matchs[1]);
    data.content = data.content.replace(/\r\[[\d;]*m/g, '');
    data.content = data.content.replace(/※ 来源:·水木社区 [:\/\/\.\w]{10,30} ·\[FROM: [\d\w\.\*]{7,30}\]\n*$/, '');
}

function attach(name, len, pos) {
    data.attaches.push({
        __type: 'SMAttach',
        boardName: data.board.name,
        pid: data.pid,
        name: name,
        len: len,
        pos: pos
    });
}

function formatContent(content) {
    return content.replace(/\[b\](.*?)\[\/b\]/g, '<b>$1</b>')
        .replace(/\[i\](.*?)\[\/i\]/g, '<i>$1</i>')
        .replace(/\[u\](.*?)\[\/u\]/g, '<u>$1</u>')
        .replace(/\[email=(.*?)\](.*?)\[\/email\]/g, '$2 mailto:$1 ')
        .replace(/\[(img|swf|mp3|url)=(.*?)\](.*?)\[\/\1\]/g, '$3 $2 ')
        .replace(/(newsmth\.net)(·\[FROM)/g, '$1 $2');
}

function parse_www(html) {
    var script = html.match(/<!--((.|\s)*?)\/\/-->/)[0];
    eval(script);
    var rsp = {code: 0, data: data, message:''};
    console.log(rsp);
    window.location.href = 'newsmth://' + encodeURIComponent(JSON.stringify(rsp));
}

//////////////////////////////////////////////////////
function parse_m(html) {
    var rsp = {code: 0, data: data, message:''};

    var body = html.match(/<body(.*)<\/body>/i)[1];
    var div = document.createElement('div');
    div.innerHTML = body;
    document.body.appendChild(div);

    if (body.indexOf('<div class="menu sp">发生错误</div>') != -1) {
        var errDiv = div.querySelector('.sp.hl.f');
        rsp.message = errDiv ? errDiv.innerHTML : '发生错误';
        rsp.code = 1;
    } else {
        // http://m.newsmth.net/article/AdvancedEdu/31066?s=31071
        var as = div.querySelectorAll('#m_main .sec.nav a');
        var a = as[0].innerHTML == '展开' ? as[0] : as[1];
        var matchs = a.href.match(/\/(\w+)\/(\d+)\?s=(\d+)/);
        data.board.name = matchs[1];
        data.gid = matchs[2];
        data.pid = matchs[3];

        var el = div.querySelector('#wraper .menu');
        if (el) {
            var boardTitle = el.innerHTML;
            data.board.cnName = boardTitle.match(/\-(.*?)\(/)[1];
        }

        data.title = div.querySelector('#m_main .list.sec li.f').innerHTML;

        // author 
        as = div.querySelectorAll('#m_main .list.sec .nav.hl a');
        data.author = as[0].innerHTML;
        data.date = parseDate(as[1].innerHTML);

        // content
        data.content = div.querySelector('#m_main .list.sec li .sp').innerHTML
            .replace(/<br\s*\/?>/ig, '\n')
            .replace(/<a.*?<\/a>/ig, '');

        // attaches
        var imgs = div.querySelectorAll('#m_main .list.sec li .sp img');
        for (var i = 0; i != imgs.length; ++i) {
            var img = imgs[i];
            matchs = img.src.match(/\/\d+\/(\d+)\/middle/);
            if (matchs) {
                attach('', 0, matchs[1]);
            }
        }
    }
    try {
        data.notice = getNotice(html);
        data.hasNotice = true;
    } catch(ignore) {
        data.title = ignore.message;
    }
    console.log(rsp);
    window.location.href = 'newsmth://' + encodeURIComponent(JSON.stringify(rsp));

}

function $parse(html) {
    if (html.indexOf('<?xml version="1.0" encoding="utf-8"?>') != -1) {
        parse_m(html);
    } else {
        parse_www(html);
    }
}

function parseDate(dateStr) {
    var comps = dateStr.split(/[^\w]+/);
    return new Date(comps[0], comps[1] - 1, comps[2], comps[3], comps[4], comps[5]).getTime();
    // return Date.parse(dateStr);
}

