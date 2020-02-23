import { createSlice, PayloadAction, Action } from "@reduxjs/toolkit";
import { ThunkAction } from "redux-thunk";

import { postInfo } from "./utils/jsapi";
import { GroupTask } from "./utils/Task";
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

export type AppThunk = ThunkAction<void, IGroupState, null, Action<string>>;

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
    taskCount(state, { payload }: PayloadAction<number>) {
      state.taskCount += payload;
    },
    getPageSuccess(state, { payload }: PayloadAction<IPage>) {
      const p = payload.p;
      state.pages[p - 1] = payload;
    }
  }
});
export const {
  setMainPost,
  enqueue,
  taskCount,
  getPageSuccess
} = group.actions;
export default group.reducer;

export const getMainPost = (): AppThunk => async dispatch => {
  const mainPost = await postInfo();
  dispatch(setMainPost(mainPost));
  dispatch(enqueue(1));
};

export const nextTask = (): AppThunk => async (dispatch, getState) => {
  const taskCountLimit = 2;
  const state = getState();
  if (state.taskCount >= taskCountLimit) {
    return;
  }
  const next = getState().tasks.find(task => task.status === Status.init);
  if (!next) {
    // done
    return;
  }
  const { p } = next;
  const mainPost = getState().mainPost;
  const task = new GroupTask(mainPost.board, mainPost.gid, p);
  dispatch(taskCount(1));
  const group = await task.execute();
  dispatch(
    getPageSuccess({
      posts: group.posts,
      status: Status.success,
      p
    })
  );
  dispatch(taskCount(-1));
};
