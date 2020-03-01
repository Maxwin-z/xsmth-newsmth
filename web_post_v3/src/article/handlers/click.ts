import { scrollBy } from "../utils/jsapi";
export const clickHander = (e: MouseEvent) => {
  const el = e.target as HTMLDivElement;
  if (el && el.className.indexOf("action") !== -1) {
    return;
  }

  const height = document.documentElement.clientHeight;
  if (e.clientY > height / 2) {
    // scroll up
    const delta = Math.min(
      height - 100,
      document.documentElement.offsetHeight - window.scrollY - height
    );
    scrollBy(0, Math.ceil(delta));
  } else {
    const delta = Math.min(height - 100, window.scrollY);
    scrollBy(0, Math.ceil(-delta));
  }
};
