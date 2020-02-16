import React, { useState, useEffect, FunctionComponent } from "react";
import PubSub from "pubsub-js";
import {
  postInfo,
  reply,
  showActivity,
  setTitle,
  toast,
  unloaded,
  download,
  login
} from "../jsbridge";
import { fetchPostGroup } from "./postUtils";
import { Post, Page, Status, XImage } from "./types.d";
import "./index.css";
import { Json } from "..";

const NOTIFICATION_TOTAL_PAGES_CHANGED = "NOTIFICATION_TOTAL_PAGES_CHANGED";
const NOTIFICATION_FORCE_LOAD_PAGE = "NOTIFICATION_FORCE_LOAD_PAGE";
const NOTIFICATION_LOADING_PAGE_CHANGED = "NOTIFICATION_LOADING_PAGE_CHANGED";
const NOTIFICATION_PAGE_CHANGED = (p: number) =>
  `NOTIFICATION_PAGE_CHANGED_${p}`;

const delay = (t: number) => new Promise(rs => setTimeout(rs, t));

const LoadingComponent: FunctionComponent<{ hide?: boolean }> = props => (
  <div className="loading-container">
    {props.children}
    <div className={"loading-icon " + (props.hide ? "hide" : "")}></div>
  </div>
);

const PostComponent: FunctionComponent<{ post: Post }> = ({ post }) => {
  function makeActionPost() {
    let actionPost: Json = {};
    actionPost.title = mainPost.title!;
    actionPost.author = post.author!;
    actionPost.nick = post.nick!;
    actionPost.pid = post.pid!;
    actionPost.board = {
      name: mainPost.board!
    };
    actionPost.content = post
      .content!.replace(/<br\/?>/g, "\n")
      .replace(/<.*?>/g, "")
      .replace(/&nbsp;/g, " ")
      .replace(/&lt;/g, "<")
      .replace(/&gt;/g, ">")
      .replace(/&amp;/g, "&");
    return actionPost;
  }
  function doReply() {
    reply(makeActionPost());
  }
  function doActivity() {
    showActivity(makeActionPost());
  }
  return (
    <div className="post" key={post.pid}>
      <div className="post-title">
        <div>
          {post.author}
          {post.nick!.length > 0 ? `(${post.nick})` : ``}
        </div>
        <div>
          <span className="floor">{post.floor}</span>
          <span className="date">{post.dateString}</span>
        </div>
        <div className="post-action">
          <div className="action replay" onClick={doReply}>
            回复
          </div>
          <div className="action more" onClick={doActivity}>
            ...
          </div>
        </div>
      </div>
      <div dangerouslySetInnerHTML={{ __html: post.content || "" }}></div>
    </div>
  );
};

const PostList: FunctionComponent<{ posts: Post[] }> = ({ posts = [] }) => (
  <>
    {posts.map(post => (
      <PostComponent key={post.pid} post={post} />
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
    console.log("sub", p);
    PubSub.subscribe(NOTIFICATION_PAGE_CHANGED(p), () => {
      console.log("in sub", p);
      setFlag(!flag);
    });
    return () => {
      console.log("unsub", p);
      PubSub.unsubscribe(NOTIFICATION_PAGE_CHANGED(p));
    };
  });
  const page = pages[p - 1];
  const hidden =
    page.posts.length === 0 && p > maxLoadedPageNumber ? "hidden page" : "page";
  return (
    <div className={hidden}>
      {page.status === Status.success || page.status === Status.incomplete ? (
        <PostList posts={page.posts} />
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
          {page.p}
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
  debugger;

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
const pages: Page[] = [
  {
    title: "",
    total: 0,
    p: 1,
    posts: [],
    status: Status.init
  }
];
const xImages: XImage[] = [];
const maxImageDownloader = 1;
let currentDownloaders = 0;
let mainPost: Post;
let incompletePageNumber = 1;
let maxLoadedPageNumber = 0;
let fullLoading = true; // the whole page is loading
let pageLoading = false;

async function initPage() {
  mainPost = await postInfo();
  // mainPost = {
  //   board: "Anti2019nCoV",
  //   gid: 408945
  // };

  // mainPost = {
  //   board: "AutoWorld",
  //   gid: 1943048442
  // };

  // mainPost = {
  //   board: "FamilyLife",
  //   gid: 1762997577
  // };
  console.log(mainPost);
  loadIncompletePage();
}

async function loadIncompletePage() {
  taskQueue.unshift(incompletePageNumber);
  nextTask();
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

async function nextTask() {
  console.log("task queue:", taskQueue);
  if (taskQueue.length === 0 || pageLoading) return;
  pageLoading = true;
  const p = taskQueue[0];
  let page = pages[p! - 1];
  if (page.posts.length === 0) {
    page.status = Status.loading;
  }

  pubPageChanged(p);

  page = await loadPage(p);
  fullLoading = false;
  maxLoadedPageNumber = Math.max(maxLoadedPageNumber, p);

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

  // set last page always incomplete, try to load new posts
  incompletePageNumber = totalPage;
  // remove current page, task done
  taskQueue.splice(taskQueue.indexOf(p), 1);
  pageLoading = false;

  setTimeout(() => {
    nextTask();
  }, 500);

  if (totalPagesChanged) {
    PubSub.publish(NOTIFICATION_TOTAL_PAGES_CHANGED, {});
  }
  pubPageChanged(p);
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

initPage();
PubSub.subscribe(
  NOTIFICATION_FORCE_LOAD_PAGE,
  (_: string, msg: { p: number }) => {
    orderTaskQueue(msg.p);
    nextTask();
  }
);

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
  (document.querySelector(
    `#ximg-info-${id}`
  ) as HTMLSpanElement).innerHTML = info;
});

PubSub.subscribe("PAGE_CLOSE", async () => {
  console.log("page close");
  unloaded();
});

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

  return (
    <div className="main">
      <h1>{mainPost && mainPost.title}</h1>
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
