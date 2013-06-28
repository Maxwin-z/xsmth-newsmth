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
            name: '',
            len: 0,
            pos: 0
        }*/
    ]
};

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
    data.content = matchs == null ? content : matchs[1];
    data.content = data.content.replace(/\r\[[\d;]*m/g, '');
}

function attach(name, len, pos) {
    data.attaches.push({
        __type: 'SMAttach',
        name: name,
        len: len,
        pos: pos
    });
}

function $parse(html) {
    var script = html.match(/<!--((.|\s)*?)\/\/-->/)[0];
    eval(script);
    var rsp = {code: 0, data: data, message:''};
    console.log(rsp);
    window.location.href = 'newsmth://' + encodeURIComponent(JSON.stringify(rsp));
}