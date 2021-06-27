import { IMainPost, IPost } from "../article/types";
import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import { LikesThunk } from "./Likes";
import { getQuery } from "../article/utils/urlHelper";
import { GroupTask } from "../article/utils/Task";

export interface ILikesState {
  mainPost: IMainPost;
  post: IPost | null;
  error: string;
}
const likesInitialState: ILikesState = {
  mainPost: { board: "", title: "", gid: 0, pid: 0, single: false },
  post: null,
  error: ""
};

const group = createSlice({
  name: "group",
  initialState: likesInitialState,
  reducers: {
    setMainPost(state, { payload }: PayloadAction<IMainPost>) {
      state.mainPost = payload;
    },
    setPost(state, { payload }: PayloadAction<IPost>) {
      state.post = payload;
    },
    setError(state, { payload }: PayloadAction<string>) {
      state.error = payload;
    }
  }
});

const { setMainPost, setPost, setError } = group.actions;

export const {} = group.actions;

export default group.reducer;

export const loadLikes = (): LikesThunk => async dispatch => {
  const query = getQuery();
  const board = query["board"];
  const gid = parseInt(query["gid"], 10);
  const task = new GroupTask(board, gid, 1);
  try {
    const group = await task.execute();
    const mainPost: IMainPost = {
      title: group.title,
      board,
      gid,
      pid: 0,
      single: false
    };
    dispatch(setMainPost(mainPost));
    const post = group.posts[0];
    console.log(post);
    dispatch(setPost(post));
  } catch (e) {
    dispatch(setError(e));
  }
};
