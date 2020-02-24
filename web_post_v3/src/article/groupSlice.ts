import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import { postInfo } from "./utils/jsapi";
import { GroupTask } from "./utils/Task";
import { AppThunk } from ".";
export enum Status {
  init,
  loading,
  success,
  fail,
  imcomplete
}
export interface IMainPost {
  board: string;
  title: string;
  gid: number;
}

export interface IXImage {
  id: number;
  src: string;
  status: Status;
}

export interface IPost {
  url?: string;
  board?: string;
  gid?: number;
  pid?: number;
  title?: string;
  author?: string;
  nick?: string;
  floor?: number;
  date?: number;
  dateString?: string;
  content?: string;
  images?: IXImage[];
  isSingle?: boolean;
}

export interface IPage {
  posts: IPost[];
  status: Status;
  p: number;
  errorMessage?: string;
}

export interface IGroup {
  title: string;
  posts: IPost[];
  total: number;
}

export interface ITask {
  status: Status;
  p: number;
}

export interface IGroupState {
  mainPost: IMainPost;
  pages: IPage[];
  tasks: ITask[];
  taskCount: number;
}

const groupInitialState: IGroupState = {
  mainPost: { board: "", title: "", gid: 0 },
  pages: [],
  tasks: [],
  taskCount: 0
};

const group = createSlice({
  name: "group",
  initialState: groupInitialState,
  reducers: {
    setMainPost(state, { payload }: PayloadAction<IMainPost>) {
      state.mainPost = payload;
    },
    enqueue(state, { payload }: PayloadAction<number[] | number>) {
      const newTasks: ITask[] = [];
      const newPages: IPage[] = [];
      new Array<number>(0).concat(payload).forEach(p => {
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
      state.tasks.find(task => task.p === p)!.status = Status.success;
    },
    getPageFail(state, { payload: { p, errorMessage } }: PayloadAction<IPage>) {
      const page = state.pages[p - 1];
      page.status = Status.fail;
      page.errorMessage = errorMessage;
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
  const mainPost = await postInfo();
  dispatch(setMainPost(mainPost));
  dispatch(enqueue(1));
  dispatch(nextTask());
};

export const nextTask = (): AppThunk => async (dispatch, getState) => {
  const taskCountLimit = 2;
  const { group } = getState();
  if (group.taskCount >= taskCountLimit) {
    return;
  }
  const task = group.tasks.find(task => task.status === Status.init);
  if (!task) {
    return;
  }
  const { p } = task;
  const mainPost = group.mainPost;
  const groupTask = new GroupTask(mainPost.board, mainPost.gid, p);
  dispatch(taskCount(1));
  dispatch(taskBegin(p));
  const groupPost = await groupTask.execute();
  dispatch(
    getPageSuccess({
      posts: groupPost.posts,
      status: Status.success,
      p
    })
  );
  dispatch(dequeue(p));
  dispatch(taskCount(-1));
};
