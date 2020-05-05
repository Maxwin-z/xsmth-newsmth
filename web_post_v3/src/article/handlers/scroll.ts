import { pageNumberChanged } from "../../jsapi";

let shownPage = 0;
export const scrollHander = (e: Event) => {
  const ps = document.querySelectorAll(".page");
  let last = shownPage;
  for (let i = 0; i < ps.length; ++i) {
    const p = ps[i];
    const rect = p.getBoundingClientRect();
    if (rect.top >= 0) {
      // the hide page's y is 0
      const page = parseInt(p.getAttribute("data-page") || "1", 10);
      shownPage =
        rect.height > 0 && rect.top < (window.innerHeight * 2) / 3
          ? page
          : page - 1;
      break;
    }
  }
  if (last !== shownPage) {
    pageNumberChanged(shownPage, -1);
  }
};
