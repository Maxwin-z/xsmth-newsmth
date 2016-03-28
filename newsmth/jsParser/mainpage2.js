var data = {
	'__type': 'SMMainPage',
	sections: [
	/*
	{
		sectionTitle: '',
		posts:[{	// SMPostGroup
			author: '',
			title: '',
			board: {
				__type: 'SMBoard',
				name: '',
				cnName: ''
			},
			gid: 0
		}, ...]
	}, ...
	*/
	]
};


function $parse(html) {
  html = html.replace(/<script[^>]*?>(.|\s)*?<\/script>/g, '')
    .replace(/<style[^>]*?>(.|\s)*?<\/style>/g, '');
  var div = document.createElement('div');
  div.innerHTML = html;

  // top 10
  var top10items = fetchPosts(div.querySelector('#top10'));
  data.sections.push({
    '__type': 'SMSection',
    sectionTitle: '本日热点话题讨论',
    posts: top10items
  });

  // other sections
  var secEls = div.querySelectorAll('.w_section .b_section');
  for (var i = 0; i < secEls.length; ++i) {
    try {
      var secEl = secEls[i];
      var sectionTitle = secEl.querySelector('h3 a').innerHTML;
      var posts = fetchPosts(secEl.querySelector('.topics'));
      data.sections.push({
        '__type': 'SMSection',
        sectionTitle: sectionTitle,
        posts: posts
      })
    } catch (ignore) {}
  }

	var rsp = {code: 0, data: data, message: ''};
	$smth.sendData(rsp);
}

function fetchPosts(el) {
  var posts = [];
  var lis = el.querySelectorAll('li');
  for (var i = 0; i < lis.length; ++i) {
    var li = lis[i];
    var boardA = li.querySelector('a');
    var titleA = li.querySelector('a:last-child');

    if (!boardA || !titleA) {
      continue;
    }

    var post = {
      title: titleA.title || titleA.innerHTML,
      gid: titleA.href.split('/').pop(),
      board: {
        __type: 'SMBoard',
        name: boardA.href.split('/').pop(),
        cnName: boardA.title || boardA.innerHTML.replace(/[\[\]]/g, '')
      }
    };
    posts.push(post);
  }
  return posts;
}
