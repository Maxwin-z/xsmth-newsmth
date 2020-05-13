import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import {
  postInfo,
  pageNumberChanged,
  ajax,
  toast,
  ToastType,
  openPostPage,
  setTitle
} from "../jsapi";
import { GroupTask, PostTask } from "./utils/Task";
import { AppThunk, RootState } from ".";
import {
  IGroupState,
  IPage,
  ITask,
  Status,
  IMainPost,
  IGroup,
  ArticleStatus,
  IPost
} from "./types";
import { getArticleStatus } from "./utils/article-status";
import {
  enqueue as imageTaskEnqueue,
  restoreImagesState
} from "./slices/imageTask";
import { cacheInstance, removeInstance } from "./handlers/pageState";

const isLike = window.location.hash.indexOf("#/likes") === 0;

const groupInitialState: IGroupState = {
  mainPost: { board: "", title: "", gid: 0, pid: 0, single: false },
  pages: [],
  tasks: [],
  taskCount: 0,
  articleStatus: ArticleStatus.allLoading,
  lastLoading: 0,
  selectedPage: 0,
  pageScrollY: -1,
  domHeights: {}
};

function updatePageStatus(
  pages: IPage[],
  tasks: ITask[],
  p: number,
  status: Status,
  errorMessage?: string
) {
  // console.log(
  //   pages.map(page => page.p),
  //   p
  // );
  if (p > pages.length) {
    console.error("outofbounds", p, pages);
    return;
  }
  pages[p - 1].status = status;
  pages[p - 1].errorMessage = errorMessage || "";
  const task = tasks.find(task => task.p === p);
  task && (task.status = status);
  let { articleStatus, maxLoaded, lastLoading } = getArticleStatus(
    pages.map(page => page.status)
  );
  pages.forEach(page => {
    page.hidden =
      page.posts.length === 0 &&
      (page.status === Status.init || page.status === Status.loading) &&
      page.p >= maxLoaded;
    if (page.posts.length > 0 && articleStatus === ArticleStatus.allLoading) {
      articleStatus = ArticleStatus.reloading;
    }
  });
  // console.log(
  //   new Date(),
  //   pages.map(page => [page.p, page.hidden])
  // );
  return {
    pages,
    tasks,
    articleStatus,
    lastLoading
  };
}

const group = createSlice({
  name: "group",
  initialState: groupInitialState,
  reducers: {
    setMainPost(state, { payload }: PayloadAction<IMainPost>) {
      state.mainPost = payload;
    },
    restoreGroupState(state, { payload }: PayloadAction<IGroupState>) {
      Object.assign(state, payload, { floor: state.floor });
    },
    resetScrollY(state) {
      state.pageScrollY = -1;
    },
    setSelectedPage(state, { payload }: PayloadAction<number>) {
      state.selectedPage = payload;
    },
    enqueue(state, { payload }: PayloadAction<number[] | number>) {
      // console.log("enqueue", payload);
      const newTasks: ITask[] = [];
      const newPages: IPage[] = [];
      const ps = Array.isArray(payload) ? payload : [payload];
      if (ps.length === 0) {
        return;
      }
      ps.forEach(p => {
        if (!state.tasks.find(task => task.p === p)) {
          newTasks.push({
            status: Status.init,
            p
          });
        }
        if (!state.pages.find(page => page.p === p)) {
          newPages.push({
            posts: [],
            status: Status.init,
            p
          });
        }
      });
      state.tasks = state.tasks.concat(newTasks);
      state.pages = state.pages.concat(newPages).sort((p1, p2) => p1.p - p2.p);
    },
    dequeue(state, { payload }: PayloadAction<number>) {
      const index = state.tasks.findIndex(task => task.p === payload);
      // console.log("dequeue", payload, index);
      if (index !== -1) {
        state.tasks.splice(index, 1);
      }
    },
    sortQueue(state, { payload }: PayloadAction<number>) {
      const nextTasks: ITask[] = [];
      const prevTasks: ITask[] = [];
      state.tasks.forEach(task => {
        task.p < payload ? prevTasks.push(task) : nextTasks.push(task);
      });
      state.tasks = nextTasks
        .sort((a, b) => a.p - b.p)
        .concat(prevTasks.sort((a, b) => a.p - b.p));
      // console.log(state.tasks.map(t => t.p));
    },
    taskCount(state, { payload }: PayloadAction<number>) {
      // console.log("taskCount", state.taskCount, payload);
      state.taskCount += payload;
    },
    taskBegin(state, { payload }: PayloadAction<number>) {
      // console.log(new Date(), "taskBegin");
      Object.assign(
        state,
        updatePageStatus(state.pages, state.tasks, payload, Status.loading)
      );
    },
    getTitleSuccess(state, { payload }: PayloadAction<string>) {
      state.mainPost.title = payload;
    },
    getPageSuccess(state, { payload: { p }, payload }: PayloadAction<IPage>) {
      // console.log("task success");
      state.pages[p - 1] = payload;
      Object.assign(
        state,
        updatePageStatus(state.pages, state.tasks, p, Status.success)
      );
    },
    getPageFail(
      state,
      { payload: { p, error } }: PayloadAction<{ p: number; error: string }>
    ) {
      Object.assign(
        state,
        updatePageStatus(state.pages, state.tasks, p, Status.fail, error)
      );
    },
    singleAuthor(state, { payload }: PayloadAction<string | null>) {
      state.author = payload;
    },
    singlePost(state, { payload }: PayloadAction<IPost>) {
      state.singlePost = payload;
      state.articleStatus = ArticleStatus.allSuccess;
    },
    setFloor(state, { payload }: PayloadAction<number | null>) {
      state.floor = payload;
      state.pageScrollY = -1;
    }
  }
});
export const {
  setMainPost,
  restoreGroupState,
  resetScrollY,
  setSelectedPage,
  enqueue,
  dequeue,
  sortQueue,
  taskCount,
  taskBegin,
  getTitleSuccess,
  getPageSuccess,
  getPageFail,
  singleAuthor,
  singlePost,
  setFloor
} = group.actions;
export default group.reducer;

const getPostInfo = async () => {
  let mainPost: IMainPost;

  try {
    mainPost = await postInfo();
  } catch (ignore) {
    const hash = window.location.hash;
    const queryString = hash.split("?")[1] || "";
    const query: { [x: string]: any } = {};
    queryString.split("&").forEach(item => {
      const [k, v] = item.split("=");
      if (k) {
        query[k] = decodeURIComponent(v || "");
      }
    });

    const gid = parseInt(query.gid, 10);

    mainPost = {
      board: query.board as string,
      gid,
      pid: gid,
      author: (query.author as string) || "",
      title: (query.title as string) || "",
      single: isLike
    };
    setTitle(`${mainPost.author} - ${mainPost.title}`);
  }
  return mainPost;
};

export const getMainPost = (): AppThunk => async dispatch => {
  // debug
  // mainPost = { board: "WorkLife", gid: 2164300, title: "" }; // 20+ pages
  // mainPost = { board: "Tooooold", gid: 41831, title: "" }; // 4 pages
  // https://www.newsmth.net/nForum/article/WorkLife/2199396?ajax=&p=1&_xsmth_disable_cache=1583767005666
  // mainPost = { board: "WorkLife", gid: 2199396, title: "" }; // 46 pages
  // mainPost = { board: "WorkLife", gid: 2211774, title: "" }; // 46 pages
  // mainPost = {
  //   gid: 1952208,
  //   single: true,
  //   board: "History",
  //   pid: 1952417,
  //   title: "[Apple]Re: xsmth怎么又有上下黑边框了？"
  // };

  // mainPost = {
  //   gid: 1952208,
  //   single: true,
  //   board: "AutoWorld",
  //   pid: 1943009472,
  //   title: "[Apple]Re: xsmth怎么又有上下黑边框了？"
  // };
  const mainPost = await getPostInfo();

  console.log(mainPost);
  dispatch(setMainPost(mainPost));
  if (isLike) {
    dispatch(loadLikePost(mainPost));
  } else if (mainPost.single) {
    dispatch(loadSinglePost(mainPost));
  } else {
    const data = await cacheInstance(mainPost);
    if (data) {
      dispatch(restorePage(data));
    } else {
      dispatch(enqueue(1));
    }
  }
};

export const refreshPage = (): AppThunk => async dispatch => {
  console.log("refresh page");
  const mainPost = await getPostInfo();
  if (!mainPost.single) {
    await removeInstance(mainPost);
  }
  dispatch(
    restoreGroupState({
      mainPost,
      pages: [],
      tasks: [],
      taskCount: 0,
      articleStatus: ArticleStatus.allLoading,
      lastLoading: 0,
      selectedPage: 0,
      pageScrollY: -1
    })
  );
  dispatch(getMainPost());
};

const handleGroupTask = (group: IGroup): AppThunk => (dispatch, getState) => {
  // console.log("handle group", group);
  const {
    group: { pages }
  } = getState();
  dispatch(getTitleSuccess(group.title));
  dispatch(imageTaskEnqueue(group.posts));

  if (group.total > pages.length || group.total === 1) {
    pageNumberChanged(group.p, group.total);
    dispatch(
      enqueue(
        new Array(group.total - pages.length)
          .fill(0)
          .map((_, i) => i + pages.length + 1)
      )
    );
  }

  dispatch(
    getPageSuccess({
      posts: group.posts,
      status: Status.success,
      p: group.p
    })
  );
};

export const nextTask = (
  atonce = false,
  specifiedPage = -1
): AppThunk => async (dispatch, getState) => {
  const taskCountLimit = 1;
  const { group } = getState();
  // console.log("atonce", atonce);
  if (!atonce && group.taskCount >= taskCountLimit) {
    return;
  }
  const task =
    specifiedPage > 0
      ? {
          p: specifiedPage,
          status: Status.init
        }
      : group.tasks.find(task => task.status === Status.init);
  // console.log("find init task", group.tasks, task);
  if (!task) {
    return;
  }
  const { p } = task;
  const mainPost = group.mainPost;
  const groupTask = new GroupTask(
    mainPost.board,
    mainPost.gid,
    p,
    mainPost.author
  );
  // console.log("task + 1", p);
  dispatch(taskCount(1));
  dispatch(taskBegin(p));
  try {
    // debug
    // await delay(1500);
    const groupPost = await groupTask.execute();
    // console.log(groupPost);
    dispatch(handleGroupTask(groupPost));
    dispatch(dequeue(p));
  } catch (e) {
    dispatch(
      getPageFail({
        p,
        error: e.toString()
      })
    );
  }
  dispatch(taskCount(-1));
  // console.log("task - 1", p);
};

export const onSelectPage = (page: number): AppThunk => async (
  dispatch,
  getState
) => {
  const pages = getState().group.pages;
  let isLastLoading = true;
  for (let i = page; i < pages.length; ++i) {
    if (pages[i].status !== Status.init) {
      isLastLoading = false;
      break;
    }
  }
  if (isLastLoading) {
    window.scrollTo(0, document.body.clientHeight * 2);
  } else {
    dispatch(setSelectedPage(page));
  }
  dispatch(loadPage(page));
};

export const loadPage = (
  page: number,
  force: boolean = false
): AppThunk => async dispatch => {
  dispatch(sortQueue(page));
  dispatch(nextTask(true, force ? page : -1));
};

export const restorePage = (state: RootState): AppThunk => async dispatch => {
  dispatch(restoreGroupState(state.group));
  dispatch(restoreImagesState(state.imageTask));
  dispatch(loadPage(1, true));
  const lastPage = state.group.pages.length;
  pageNumberChanged(1, lastPage);
  if (lastPage > 1) {
    dispatch(loadPage(lastPage, true));
  }
};

export const loadLikePost = ({
  board,
  gid
}: IMainPost): AppThunk => async dispatch => {
  const task = new GroupTask(board, gid, 1);
  try {
    const group = await task.execute();
    setTitle(group.title);
    const post = group.posts[0];
    post.title = group.title;
    dispatch(singlePost(post));
    dispatch(imageTaskEnqueue([post]));
    console.log(post);
  } catch (e) {
    toast({ message: e, type: ToastType.error });
  }
};

export const loadSinglePost = ({
  board,
  pid
}: IMainPost): AppThunk => async dispatch => {
  try {
    // console.log(post);
    const task = new PostTask(board, pid);
    const post = await task.execute();
    dispatch(singlePost(post));
    dispatch(imageTaskEnqueue([post]));
  } catch (e) {
    toast({ message: e, type: ToastType.error });
  }
};

export const expandSinglePost = (): AppThunk => async (dispatch, getState) => {
  // console.log("expandSinglePost");
  const post = getState().group.singlePost;
  if (!post) return;
  const html = await ajax({
    url: `https://www.newsmth.net/nForum/article/${post.board}/${post.gid}?s=${post.pid}`,
    headers: {
      "X-Requested-With": "XMLHttpRequest"
    }
  });
  // console.log(html); // location:/article/Apple/1375368?p=1#a4
  const mainPost: IMainPost = {
    board: post.board!,
    title: "",
    gid: post.gid!,
    pid: post.pid,
    single: false
  };
  const url = new URL(html);
  const p = parseInt(url.searchParams.get("p") || "1", 10);
  const floor = parseInt(url.hash.replace("#a", ""), 10);
  console.log(390, floor, p, mainPost);
  const data = await cacheInstance(mainPost);
  dispatch(setFloor(floor));
  dispatch(setMainPost(mainPost));
  if (data) {
    dispatch(restorePage(data));
  }
  dispatch(enqueue(new Array(p).fill(0).map((_, i) => i + 1)));
  dispatch(loadPage(p, true));
};

export const openSingleAuthorPage = (author: string): AppThunk => async (
  dispatch,
  getState
) => {
  const post = getState().group.mainPost;
  const { origin, pathname } = window.location;
  const url = `${origin}${pathname}#/?board=${post.board}&gid=${
    post.gid
  }&author=${author}&title=${encodeURIComponent(post.title)}`;
  openPostPage(url);
};
