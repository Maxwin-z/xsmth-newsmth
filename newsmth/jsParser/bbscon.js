var data = {
    author: '',
    nick: '',
    title: '',
    content: '',
    date: 0
};

function emptyFn() {}

// conWriter
function conWriter(ftype, board, bid, id, gid, reid, favtxt, num, istex, title) {
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

}

function attach(name, len, pos) {}

function $parse(html) {
//    var script = html.match(/<!--((.|\s)*?)\/\/-->/)[0];
//    eval(script);
    console.log(data);
    window.location.href = 'newsmth://' + JSON.stringify(data);
}