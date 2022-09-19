var data = {
  __type: "SMUser",
  info: "",
};

function $parse(html) {
  var rsp = { code: 0, data: data, message: "" };
  html = html.replace(/<script .*?<\/script>/gi, "");
  var div = document.createElement("div");
  div.innerHTML = html;

  document.body.appendChild(div);

  var info = "";
  var lis = div.querySelectorAll("#m_main li");
  for (var i = 0; i < lis.length; ++i) {
    info +=
      lis[i].innerHTML.replace(/&nbsp;/g, " ").replace(/<.+?>/g, "") + "\n";
  }

  data.info = info;
  console.log(rsp);
  $smth.sendData(rsp);
  return rsp;
  // window.location.href = 'newsmth://' + encodeURIComponent(JSON.stringify(rsp));
}
