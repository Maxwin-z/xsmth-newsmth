import { xScrollBy } from "../utils/jsapi";
export const clickHander = (e: MouseEvent) => {
  let el = e.target as HTMLElement;
  while (
    el &&
    el !== document.body &&
    el.className !== "post" &&
    el.className.indexOf("skip-scroll") === -1
  ) {
    el = el.parentNode as HTMLElement;
  }
  if (el && el.className.indexOf("skip-scroll") !== -1) {
    return;
  }

  const { clientHeight, offsetHeight } = document.documentElement;
  if (offsetHeight < clientHeight) {
    // only 1 page
    return;
  }
  if (e.clientY > clientHeight / 2) {
    // scroll up
    const delta = Math.min(
      clientHeight - 100,
      offsetHeight - window.scrollY - clientHeight
    );
    xScrollBy(0, Math.ceil(delta));
  } else {
    const delta = Math.min(clientHeight - 100, window.scrollY);
    xScrollBy(0, Math.ceil(-delta));
  }
};
