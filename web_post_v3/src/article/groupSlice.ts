import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import { postInfo, pageNumberChanged } from "./utils/jsapi";
import { GroupTask } from "./utils/Task";
import { AppThunk } from ".";
import { delay } from "./utils/post";
import {
  IGroupState,
  IPage,
  ITask,
  Status,
  IMainPost,
  IGroup,
  ArticleStatus
} from "./types";
import { getArticleStatus } from "./utils/article-status";
import { enqueue as imageTaskEnqueue } from "./slices/imageTask";

const groupInitialState: IGroupState = {
  mainPost: { board: "", title: "", gid: 0 },
  pages: [],
  tasks: [],
  taskCount: 0,
  articleStatus: ArticleStatus.allLoading,
  lastLoading: 0,
  selectedPage: 0
};

function updatePageStatus(
  pages: IPage[],
  tasks: ITask[],
  p: number,
  status: Status,
  errorMessage?: string
) {
  pages[p - 1].status = status;
  pages[p - 1].errorMessage = errorMessage || "";
  tasks.find(task => task.p === p)!.status = status;
  let { articleStatus, maxLoaded, lastLoading } = getArticleStatus(
    pages.map(page => page.status)
  );
  pages.forEach(page => {
    page.hidden =
      (page.status === Status.init || page.status === Status.loading) &&
      page.p >= maxLoaded;
    if (page.posts.length > 0 && articleStatus === ArticleStatus.allLoading) {
      articleStatus = ArticleStatus.reloading;
    }
  });
  console.log(
    new Date(),
    pages.map(page => [page.p, page.hidden])
  );
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
      state.tasks.splice(index, 1);
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
      console.log(state.tasks.map(t => t.p));
    },
    taskCount(state, { payload }: PayloadAction<number>) {
      state.taskCount += payload;
    },
    taskBegin(state, { payload }: PayloadAction<number>) {
      console.log(new Date(), "taskBegin");
      Object.assign(
        state,
        updatePageStatus(state.pages, state.tasks, payload, Status.loading)
      );
    },
    getTitleSuccess(state, { payload }: PayloadAction<string>) {
      state.mainPost.title = payload;
    },
    getPageSuccess(state, { payload: { p }, payload }: PayloadAction<IPage>) {
      console.log("task success");
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
    }
  }
});
export const {
  setMainPost,
  setSelectedPage,
  enqueue,
  dequeue,
  sortQueue,
  taskCount,
  taskBegin,
  getTitleSuccess,
  getPageSuccess,
  getPageFail
} = group.actions;
export default group.reducer;

export const getMainPost = (): AppThunk => async dispatch => {
  let mainPost = await postInfo();
  // debug
  // mainPost = { board: "WorkLife", gid: 2164300, title: "" }; // 20+ pages
  // mainPost = { board: "Tooooold", gid: 41831, title: "" }; // 4 pages
  // https://www.newsmth.net/nForum/article/WorkLife/2199396?ajax=&p=1&_xsmth_disable_cache=1583767005666
  mainPost = { board: "WorkLife", gid: 2199396, title: "" }; // 4 pages
  dispatch(setMainPost(mainPost));
  dispatch(enqueue(1));
};

const handleGroupTask = (group: IGroup): AppThunk => (dispatch, getState) => {
  // console.log("handle group", group);
  const {
    group: { pages }
  } = getState();
  dispatch(getTitleSuccess(group.title));
  dispatch(imageTaskEnqueue(group.posts));

  if (group.total > pages.length) {
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

export const nextTask = (atonce = false): AppThunk => async (
  dispatch,
  getState
) => {
  const taskCountLimit = 1;
  const { group } = getState();
  if (!atonce && group.taskCount >= taskCountLimit) {
    return;
  }
  const task = group.tasks.find(task => task.status === Status.init);
  console.log("find init task", task);
  if (!task) {
    return;
  }
  const { p } = task;
  const mainPost = group.mainPost;
  const groupTask = new GroupTask(mainPost.board, mainPost.gid, p);
  dispatch(taskCount(1));
  dispatch(taskBegin(p));
  try {
    // debug
    await delay(5000);
    const groupPost = await groupTask.execute();
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
  dispatch(sortQueue(page));
  dispatch(nextTask(true));
};
