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
