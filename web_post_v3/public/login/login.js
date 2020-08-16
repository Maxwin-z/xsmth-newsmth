const selectors = [
  "#ad_container",
  ".slist.sec",
  ".logo.sp",
  ".menu.sp",
  ".menu.nav"
];
selectors.forEach(sel => {
  [...document.querySelectorAll(sel)].forEach(dom => (dom.hidden = true));
});

const enlarges = ["#u_login", "#u_login input"];
enlarges.forEach(sel => {
  [...document.querySelectorAll(sel)].forEach(dom => {
    dom.style = dom.style || {};
    dom.style.fontSize = "120%";
  });
});

const idEl = document.querySelector('[name="id"]');
const passwdEl = document.querySelector('[name="passwd"]');
const saveEl = document.querySelector('[name="save"]');
saveEl.checked = true;
const key = "_xsmth_userinfo";
const userinfo = window.localStorage.getItem(key);
if (userinfo) {
  try {
    const { id, passwd } = JSON.parse(userinfo);
    idEl.value = id;
    passwdEl.value = passwd;
  } catch (ignore) {
    console.log(ignore);
  }
}

document.getElementById("TencentCaptcha").addEventListener("click", () => {
  const userinfo = {
    id: idEl.value,
    passwd: passwdEl.value
  };
  window.localStorage.setItem(key, JSON.stringify(userinfo));
  window.webkit.messageHandlers.nativeBridge.postMessage({
    methodName: "setStorage",
    parameters: {
      key: "_xsmth_userinfo",
      value: userinfo
    },
    callbackID: 0
  });
});
