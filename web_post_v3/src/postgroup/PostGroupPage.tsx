import React, { useState, useEffect, FunctionComponent } from "react";
import PubSub from "pubsub-js";
import {
  postInfo,
  reply,
  showActivity,
  setTitle,
  unloaded,
  download,
  login,
  pageNumberChanged,
  getThemeConfig,
  scrollBy,
  setStorage,
  getStorage,
  removeStorage
} from "../jsbridge";
import { fetchPostGroup } from "./postUtils";
import { Post, Page, Status, XImage, Theme } from "./types.d";
import "./index.css";
import { Json } from "..";
import LoadingComponent from "./LoadingComponent";
import PostComponent from "./PostComponent";

const NOTIFICATION_TOTAL_PAGES_CHANGED = "NOTIFICATION_TOTAL_PAGES_CHANGED";
const NOTIFICATION_FORCE_LOAD_PAGE = "NOTIFICATION_FORCE_LOAD_PAGE";
const NOTIFICATION_LOADING_PAGE_CHANGED = "NOTIFICATION_LOADING_PAGE_CHANGED";
const NOTIFICATION_PAGE_CHANGED = (p: number) =>
  `NOTIFICATION_PAGE_CHANGED_${p}`;

const PostList: FunctionComponent<{ page: Page }> = ({ page }) => (
  <>
    {page.posts.map(post => (
      <PostComponent
        key={post.pid}
        post={post}
        p={page.p}
        title={mainPost.title!}
        board={mainPost.board!}
      />
    ))}
  </>
);

const PageComponent: FunctionComponent<{ p: number }> = ({ p }) => {
  function load() {
    PubSub.publish(NOTIFICATION_FORCE_LOAD_PAGE, {
      p
    });
  }

  async function loadAfterLogin() {
    const ret = await login();
    if (ret) {
      load();
    }
  }

  const [flag, setFlag] = useState(false);
  useEffect(() => {
    // console.log("sub", p);
    const token = PubSub.subscribe(NOTIFICATION_PAGE_CHANGED(p), () => {
      // console.log("in sub", p);
      setFlag(!flag);
    });
    return () => {
      console.log("unsub", p);
      // PubSub.unsubscribe(NOTIFICATION_PAGE_CHANGED(p));
      PubSub.unsubscribe(token);
    };
  });

  const page = pages[p - 1];
  const hidden = page.posts.length === 0 && p > maxLoadedPageNumber;
  const dom = document.querySelector(`[data-page="${p}"]`);
  const lastHeight = dom ? dom.getBoundingClientRect().height : 0;
  useEffect(() => {
    canHandleScrollEvent = true;
    console.log("enable handlescroll", new Date().getTime());

    const dom = document.querySelector(`[data-page="${p}"]`);
    const height = dom ? dom.getBoundingClientRect().height : 0;
    console.log("height change", p, lastHeight, height);
    if (height !== lastHeight && shownPage > p) {
      window.scrollBy(0, height - lastHeight);
    }
    // if (needScrollToPage > 0) {
    //   console.log("needscrolltopage", needScrollToPage, p, hidden);
    // }
    if (needScrollToPage > 0 && needScrollToPage === p && !hidden) {
      scrollToPage(needScrollToPage);
      needScrollToPage = 0;
    }
  });
  canHandleScrollEvent = false;
  console.log("disable handlescroll", new Date().getTime());
  return (
    <div className={hidden ? "hidden page" : "page"} data-page={p}>
      {page.status === Status.success || page.status === Status.incomplete ? (
        <PostList page={page} />
      ) : null}
      {page.status === Status.fail ? (
        <div className="page-placeholder">
          <div>{page.errorMessage}</div>
          {page.errorMessage === "您未登录,请登录后继续操作" ? (
            <button onClick={loadAfterLogin} className="login-button">
              登录后重试
            </button>
          ) : null}
        </div>
      ) : null}
      {page.status === Status.loading ? (
        <div className="page-placeholder">
          <LoadingComponent>
            <div className="page-loading">正在加载第{page.p}页</div>
          </LoadingComponent>
        </div>
      ) : null}
      {page.status === Status.init ? (
        <div onClick={load} className="page-placeholder page-init">
          <div>{page.p}</div>
        </div>
      ) : null}
    </div>
  );
};

const FooterComponent: FunctionComponent = props => {
  const [flag, setFlag] = useState(false);
  useEffect(() => {
    PubSub.subscribe(NOTIFICATION_LOADING_PAGE_CHANGED, () => {
      console.log("footer get notify");
      setFlag(!flag);
    });
    return () => {
      PubSub.unsubscribe(NOTIFICATION_LOADING_PAGE_CHANGED);
    };
  });

  const loadMore = () => {
    taskQueue.unshift(pages.length);
    nextTask();
  };

  const loadNextPage = () => {
    orderTaskQueue(maxLoadedPageNumber);
    nextTask();
  };

  /**
   * 几种状态
   * 1. 首次进入，整页loading，隐藏
   * 2. 正在加载下一页，显示loading x/total
   * 3. 加载下一页失败，显示 x/total 点击重试
   * 4. 加载中间页，显示 x/total 点击加载，点击后重排加载顺序
   * 5. 全部加载完毕，显示 x/total 点击加载，点击后加载最后一页
   */
  enum Case {
    InitPage,
    LastPageLoading,
    LastPageLoadFail,
    MiddlePage,
    AllLoaded
  }
  const lastLoadedPage = pages[maxLoadedPageNumber - 1];
  if (!lastLoadedPage) {
    // after refresh
    return <div />;
  }

  let _case;
  if (pages.length === 1 && !isPageLoaded(pages[0])) {
    _case = Case.InitPage;
  } else if (taskQueue.length > 0) {
    if (taskQueue[0] === maxLoadedPageNumber + 1 || taskQueue.length === 1) {
      if (lastLoadedPage.status === Status.fail) {
        _case = Case.LastPageLoadFail;
      } else {
        _case = Case.LastPageLoading;
      }
    } else {
      _case = Case.MiddlePage;
    }
  } else if (lastLoadedPage && lastLoadedPage.status === Status.loading) {
    _case = Case.LastPageLoading;
  } else {
    _case = Case.AllLoaded;
  }

  const pageHint = `${Math.min(maxLoadedPageNumber + 1, pages.length)}/${
    pages.length
  }`;
  if (_case === Case.InitPage) {
    return null;
  }
  if (_case === Case.LastPageLoading) {
    return <LoadingComponent>正在加载 {pageHint} ...</LoadingComponent>;
  }
  if (_case === Case.LastPageLoadFail) {
    return (
      <div onClick={loadNextPage}>
        <LoadingComponent hide={true}>
          加载 {pageHint} 失败，点击重试
        </LoadingComponent>
      </div>
    );
  }
  if (_case === Case.MiddlePage) {
    return (
      <div onClick={loadNextPage}>
        <LoadingComponent hide={true}>点击加载 {pageHint}</LoadingComponent>
      </div>
    );
  }
  if (_case === Case.AllLoaded) {
    return (
      <div onClick={loadMore}>
        <LoadingComponent hide={true}>
          已加载 {pageHint}，点击尝试加载最新
        </LoadingComponent>
      </div>
    );
  }
  return <div></div>;
};

///////////////////////////////////////////////////////////////
// page functions
const postsPerPage = 10;
let taskQueue: number[] = [];
let pages: Page[] = [
  {
    title: "",
    total: 0,
    p: 1,
    posts: [],
    status: Status.init
  }
];
let xImages: XImage[] = [];
const maxImageDownloader = 1;
let currentDownloaders = 0;
let mainPost: Post;
let maxLoadedPageNumber = 0;
let fullLoading = true; // the whole page is loading
let pageLoading = false;
let needScrollToPage = 0;
let needScrollToPosition = -1;
let shownPage = -1;
let canHandleScrollEvent = true;
let taskTimer: NodeJS.Timeout;
let cancel = false;

async function initPage() {
  const theme = await getThemeConfig();
  setupTheme(theme);

  mainPost = await postInfo();
  // mainPost = {
  //   board: "Stock",
  //   gid: 8626024
  // };
  // mainPost = {
  //   board: "ITExpress",
  //   gid: 2101997 // 2 pages
  // };
  // mainPost = {
  //   board: "Anti2019nCoV",
  //   gid: 408945
  // };

  // mainPost = {
  //   board: "AutoWorld",
  //   gid: 1943048442
  // };

  // mainPost = {
  //   board: "Picture",
  //   gid: 2180428
  // };

  // mainPost = {
  //   board: "FamilyLife",
  //   gid: 1762997577
  // };
  console.log(mainPost);
  if (!(await loadIntance(mainPost))) {
    maxLoadedPageNumber = 0;
    taskQueue = [1];
    pages = [];
    xImages = [];
    fullLoading = true;
    nextTask();
  }
}

async function loadPage(p: number = 1, author?: string): Promise<Page> {
  const page: Page = {
    title: "",
    total: 0,
    p: p,
    posts: [],
    status: Status.init,
    errorMessage: ""
  };
  try {
    const postGroup = await fetchPostGroup(
      mainPost.board!,
      mainPost.gid!,
      p,
      null
    );
    page.posts = postGroup.posts!;
    page.total = postGroup.total!;
    page.title = postGroup.title!;
    page.status =
      page.posts.length >= postsPerPage ? Status.success : Status.incomplete;
  } catch (e) {
    page.status = Status.fail;
    page.errorMessage = e.toString();
  }
  return page;
}

function pubPageChanged(p: number) {
  PubSub.publish(NOTIFICATION_PAGE_CHANGED(p), {});
  PubSub.publish(NOTIFICATION_LOADING_PAGE_CHANGED, {});
}

function batchPagesChanged(start: number, end: number) {
  console.log("batch", start, end);
  for (let i = start; i <= end; ++i) {
    pubPageChanged(i);
  }
  // only update last page
  if (start > end) {
    pubPageChanged(end);
  }
}

async function nextTask() {
  console.log("task queue:", taskQueue);
  if (taskQueue.length === 0 || pageLoading) return;
  pageLoading = true;
  const p = taskQueue[0];

  // fill pages
  if (p > pages.length) {
    for (let i = pages.length + 1; i <= p; ++i) {
      pages.push({
        title: "",
        total: 0,
        p: i,
        posts: [],
        status: Status.init
      });
    }
    PubSub.publish(NOTIFICATION_TOTAL_PAGES_CHANGED, {});
  }

  let page = pages[p! - 1];
  if (page.posts.length === 0) {
    page.status = Status.loading;
  }

  const batchStart = maxLoadedPageNumber + 1;
  const batchEnd = p;
  maxLoadedPageNumber = Math.max(maxLoadedPageNumber, p);
  // middle page status change
  batchPagesChanged(batchStart, batchEnd);
  // await delay(3000);
  page = await loadPage(p);
  if (cancel) {
    cancel = false;
    pageLoading = false;
    nextTask();
    return;
  }
  fullLoading = false;
  batchPagesChanged(batchStart, batchEnd);

  if (page.status === Status.fail) {
    console.log("load page error", page);
    pages[p! - 1] = page;
    pageLoading = false;
    pubPageChanged(p);
    if (p === 1) {
      PubSub.publish(NOTIFICATION_TOTAL_PAGES_CHANGED, {});
    }
    return;
  }
  // load success
  if (p === 1) {
    mainPost.title = page.title;
    setTitle(mainPost.title);
  }
  console.log(p, page);
  const totalPage = Math.ceil(page.total / postsPerPage);
  const totalPagesChanged = totalPage === 1 || totalPage !== pages.length;
  // put unloaded pages to queue
  for (let i = pages.length + 1; i <= totalPage; ++i) {
    taskQueue.push(i);
    pages.push({
      title: "",
      total: 0,
      p: i,
      posts: [],
      status: Status.init
    });
  }
  pages[p! - 1] = page;

  page.posts.forEach(({ images }) => {
    xImages.push(...images!);
  });
  loadXImage();

  // remove current page, task done
  taskQueue.splice(taskQueue.indexOf(p), 1);
  pageLoading = false;

  if (totalPagesChanged) {
    PubSub.publish(NOTIFICATION_TOTAL_PAGES_CHANGED, {});
    pageNumberChanged(p, totalPage);
  }
  pubPageChanged(p);

  taskTimer = setTimeout(() => {
    nextTask();
  }, 500);
}

function orderTaskQueue(index: number) {
  const nextTasks: number[] = [];
  const prevTasks: number[] = [];
  taskQueue.forEach(i => {
    i < index ? prevTasks.push(i) : nextTasks.push(i);
  });
  taskQueue = nextTasks
    .sort((a, b) => a - b)
    .concat(prevTasks.sort((a, b) => a - b));
  console.log("reorder queue:", taskQueue);
  return;
}

async function loadXImage() {
  console.log("xImage:", xImages);
  if (currentDownloaders === maxImageDownloader) {
    console.log("no downloders");
    return;
  }
  const img = xImages.find(img => img.status === Status.init);
  if (!img) {
    console.log("no init images");
    return;
  }
  img.status = Status.loading;
  let { id, src } = img;
  let ret = false;
  try {
    ret = await download(src, id);
  } catch (ignore) {}
  if (ret === false) {
    try {
      src += "/large";
      ret = await download(src, id);
    } catch (ignore) {}
  }

  if (ret === true) {
    (document.querySelector(
      `#ximg-${id}`
    ) as HTMLImageElement).src = `ximg://_?url=${encodeURIComponent(src)}`;
    img.status = Status.success;
    const span = document.querySelector(`#ximg-info-${id}`) as HTMLSpanElement;
    span.style.display = "none";
  } else {
    console.log(`load image fail: ${src}`);
    img.status = Status.fail;
  }
  loadXImage();
}

function isPageLoaded(page: Page) {
  return (
    page.status === Status.success ||
    page.status === Status.fail ||
    page.status === Status.incomplete
  );
}

function scrollToPage(p: number) {
  const el = document.querySelector(`[data-page="${p}"]`) as HTMLDivElement;
  console.log("needScrollToPage el", el);
  if (el) {
    const rect = el.getBoundingClientRect();
    if (rect.height > 0) {
      window.scrollTo(0, rect.top + window.pageYOffset);
      return true;
    }
  }
  return false;
}

function formatSize(size: number): string {
  if (size < 1000) {
    return size + "B";
  }
  if (size < 1000 * 1000) {
    return Math.floor(size / 1000) + "K";
  }
  if (size < 1000 * 1000 * 1000) {
    return Math.floor(size / 1000 / 1000) + "M";
  }
  return "";
}
function setupTheme(style: Theme) {
  console.log("styles", style);
  var sheet = document.styleSheets[0] as CSSStyleSheet;

  for (let i = sheet.rules.length - 1; i >= 0; --i) {
    sheet.deleteRule(i);
  }

  sheet.addRule(
    "body.xsmth",
    style2string({
      "background-color": style.bgColor,
      color: style.textColor,
      "font-family": style.fontFamily,
      "font-size": style.fontSize,
      "line-height": style.lineHeight
    }),
    0
  );

  sheet.addRule(
    ".f006",
    style2string({
      color: style.quoteColor
    }),
    0
  );

  sheet.addRule(
    "a",
    style2string({
      color: style.tintColor
    }),
    0
  );

  sheet.addRule(
    "div.post",
    style2string({
      "border-top": "1px solid " + style.textColor
    }),
    0
  );

  sheet.addRule(
    "div.post .action",
    style2string({
      color: style.tintColor,
      "border-color": style.tintColor,
      "background-color": style.bgColor
    }),
    0
  );

  document.body.className = "xsmth";
}

function style2string(styles: Json) {
  const res: string[] = [];
  Object.keys(styles).forEach(key => {
    const value = styles[key];
    res.push(key + ":" + value + ";");
  });
  return res.join("");
}

function storageKey(post: Post) {
  return `post_${mainPost.board}_${mainPost.gid}`;
}

interface PageInstance {
  maxLoadedPageNumber: number;
  title: string;
  taskQueue: number[];
  xImages: XImage[];
  pages: Page[];
  scrollY: number;
}

async function saveInstance() {
  await setStorage(storageKey(mainPost), {
    maxLoadedPageNumber,
    title: mainPost.title,
    taskQueue,
    xImages: xImages.map(img => {
      const _img = { ...img };
      _img.status = Status.init;
      return _img;
    }),
    pages,
    scrollY: window.scrollY
  });
}

async function loadIntance(post: Post): Promise<boolean> {
  let data: PageInstance;
  try {
    data = await getStorage(storageKey(post));
    console.log("load page instance:", data);
  } catch (e) {
    console.log("no page instance", e);
    return false;
  }
  maxLoadedPageNumber = data.maxLoadedPageNumber;
  mainPost.title = data.title;
  taskQueue = data.taskQueue;
  xImages = data.xImages;
  pages = data.pages;
  if (!mainPost.title || !taskQueue || !pages) {
    return false;
  }

  fullLoading = false;
  PubSub.publish(NOTIFICATION_TOTAL_PAGES_CHANGED, {});

  needScrollToPosition = data.scrollY;
  if (document.documentElement.offsetHeight > needScrollToPosition) {
    window.scrollTo(0, needScrollToPosition);
    needScrollToPosition = -1;
  }
  nextTask();
  loadXImage();
  return true;
}

////// start //////
initPage();

PubSub.subscribe("THEME_CHANGE", (_: string, style: Theme) => {
  setupTheme(style);
});

PubSub.subscribe(
  NOTIFICATION_FORCE_LOAD_PAGE,
  (_: string, msg: { p: number }) => {
    orderTaskQueue(msg.p);
    nextTask();
  }
);

PubSub.subscribe("PAGE_SELECTED", async (_: string, p: number) => {
  console.log(504, p);
  if (!scrollToPage(p)) {
    // page not ready
    needScrollToPage = p;
    console.log("needScrollToPage save", p);
  } else {
    console.log("needScrollToPage done");
  }
  orderTaskQueue(p);
  nextTask();
  // setTimeout(() => {
  //   scrollToPage((p - 1) * postsPerPage);
  // }, 0);
});

PubSub.subscribe("DOWNLOAD_PROGRESS", (_: string, data: any) => {
  console.log(data);
  const { id, progress, completed, total } = data;
  let info = "";
  if (total > 0) {
    const p = Math.floor(progress * 100) + "%";
    info = `正在加载${p}, ${formatSize(total)}`;
  } else {
    info = `正在加载${formatSize(completed)}`;
  }
  try {
    (document.querySelector(
      `#ximg-info-${id}`
    ) as HTMLSpanElement).innerHTML = info;
  } catch (e) {
    console.log("image not found", id, e);
  }
});

PubSub.subscribe("PAGE_REFRESH", async () => {
  await removeStorage(storageKey(mainPost));
  console.log(752, pageLoading);
  if (pageLoading) {
    // there is task loading now
    cancel = true;
  } else if (taskTimer != null) {
    cancel = false;
    clearTimeout(taskTimer);
  }
  initPage();
});

PubSub.subscribe("PAGE_CLOSE", async () => {
  console.log("page close");
  await saveInstance();
  unloaded();
});

document.addEventListener("scroll", e => {
  if (!canHandleScrollEvent) {
    e.preventDefault();
    e.stopPropagation();
    return;
  }
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
  console.log("shown", shownPage);
  if (last !== shownPage) {
    pageNumberChanged(shownPage, pages.length);
  }
});

document.body.addEventListener("touchstart", (e: TouchEvent) => {
  if (!canHandleScrollEvent) {
    e.preventDefault();
    e.stopPropagation();
  }
});

document.body.addEventListener("click", (e: MouseEvent) => {
  console.log(e);
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
    scrollBy(0, Math.ceil(delta / 2));
  } else {
    const delta = Math.min(height - 100, window.scrollY);
    scrollBy(0, Math.ceil(-delta / 2));
  }
});

/*
document.addEventListener("scroll", () => {
  let post, top, y, el;
  post = document.querySelector('[data-floor="6"]');
  t = post.getBoundingClientRect().top + window.pageYOffset;
  el = post;
  y = 0;
  while (el) {
    y += el.offsetTop;
    console.log(y)
    el = el.offsetParent;
  }
  console.log(t ,y)
});
*/

export default function PostGroupPage() {
  console.log("render , PostGroupPage");
  const [flag, setFlag] = useState(false);
  useEffect(() => {
    PubSub.subscribe(NOTIFICATION_TOTAL_PAGES_CHANGED, () => {
      console.log("get notify");
      // toast({ message: "page changed" });
      setFlag(!flag);
    });
    return () => {
      PubSub.unsubscribe(NOTIFICATION_TOTAL_PAGES_CHANGED);
    };
  });

  useEffect(() => {
    if (needScrollToPosition > 0) {
      window.scrollTo(0, needScrollToPosition);
      needScrollToPosition = -1;
    }
  });

  return (
    <div className="main">
      <div id="title">{mainPost && mainPost.title}</div>
      {fullLoading ? (
        <LoadingComponent>正在加载</LoadingComponent>
      ) : (
        <div>
          <div className="page-list">
            {pages.map(page => (
              <PageComponent key={`${page.p}-${page.status}`} p={page.p} />
            ))}
          </div>
          <div className="footer">
            <FooterComponent />
          </div>
        </div>
      )}
    </div>
  );
}
