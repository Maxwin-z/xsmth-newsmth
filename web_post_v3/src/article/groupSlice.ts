import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import { postInfo } from "./utils/jsapi";
import { GroupTask } from "./utils/Task";
import { AppThunk } from ".";
import { delay } from "./utils/post";
import { IGroupState, IPage, ITask, Status, IMainPost, IGroup } from "./types";

const groupInitialState: IGroupState = {
  mainPost: { board: "", title: "", gid: 0 },
  pages: [],
  tasks: [],
  taskCount: 0
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
}

const group = createSlice({
  name: "group",
  initialState: groupInitialState,
  reducers: {
    setMainPost(state, { payload }: PayloadAction<IMainPost>) {
      state.mainPost = payload;
    },
    enqueue(state, { payload }: PayloadAction<number[] | number>) {
      console.log("enqueue", payload);
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
    taskCount(state, { payload }: PayloadAction<number>) {
      state.taskCount += payload;
    },
    taskBegin(state, { payload }: PayloadAction<number>) {
      state.tasks.find(task => task.p === payload)!.status = Status.loading;
    },
    getPageSuccess(state, { payload: { p }, payload }: PayloadAction<IPage>) {
      state.pages[p - 1] = payload;
      const task = state.tasks.find(task => task.p === p);
      console.log("page success", task, p);
      state.tasks.find(task => task.p === p)!.status = Status.success;
    },
    getPageFail(
      state,
      { payload: { p, error } }: PayloadAction<{ p: number; error: string }>
    ) {
      const page = state.pages[p - 1];
      page.status = Status.fail;
      page.errorMessage = error;
      state.tasks.find(task => task.p === p)!.status = Status.fail;
    }
  }
});
export const {
  setMainPost,
  enqueue,
  dequeue,
  taskCount,
  taskBegin,
  getPageSuccess,
  getPageFail
} = group.actions;
export default group.reducer;

export const getMainPost = (): AppThunk => async dispatch => {
  let mainPost = await postInfo();
  // debug
  mainPost = { board: "WorkLife", gid: 2164300, title: "" }; // 20+ pages
  mainPost = { board: "Tooooold", gid: 41831, title: "" }; // 4 pages
  dispatch(setMainPost(mainPost));
  dispatch(enqueue(1));
};

const handleGroupTask = (group: IGroup): AppThunk => (dispatch, getState) => {
  console.log("handle group", group);
  const {
    group: { pages }
  } = getState();
  dispatch(
    getPageSuccess({
      posts: group.posts,
      status: Status.success,
      p: group.p
    })
  );
  dispatch(
    enqueue(
      new Array(group.total - pages.length)
        .fill(0)
        .map((_, i) => i + pages.length + 1)
    )
  );
};

export const nextTask = (): AppThunk => async (dispatch, getState) => {
  const taskCountLimit = 2;
  const { group } = getState();
  if (group.taskCount >= taskCountLimit) {
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
    // await delay(3000);
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
