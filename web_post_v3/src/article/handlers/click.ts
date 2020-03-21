import { scrollBy } from "../utils/jsapi";
export const clickHander = (e: MouseEvent) => {
  const el = e.target as HTMLDivElement;
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
    scrollBy(0, Math.ceil(delta));
  } else {
    const delta = Math.min(clientHeight - 100, window.scrollY);
    scrollBy(0, Math.ceil(-delta));
  }
};
