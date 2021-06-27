import { xScrollBy, tapImage } from "../../jsapi";
export const clickHander = (e: MouseEvent) => {
  let el = e.target as HTMLElement;
  if (el.nodeName === "IMG") {
    onImageTap(el as HTMLImageElement);
    return;
  }
  if (el.nodeName === "A") {
    return;
  }
  while (
    el &&
    el !== document.documentElement &&
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

function onImageTap(el: HTMLImageElement) {
  const src = el.src;
  if (src.indexOf("ximg://") !== 0) {
    return;
  }
  // ximg://_?url=http%3A%2F%2Fatt.mysmth.net%2FnForum%2Fatt%2FPicture%2F2207218%2F225
  const url = decodeURIComponent(src.substr(13));
  tapImage(url);
}
