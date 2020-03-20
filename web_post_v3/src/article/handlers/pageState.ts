import { AppThunk, RootState } from "..";
import { setStorage, getStorage, unloaded } from "../utils/jsapi";
import { IMainPost } from "../types";
import { restorePage } from "../groupSlice";

function storageKey(post: IMainPost) {
  return `post_${post.board}_${post.gid}`;
}

export const saveInstance = (): AppThunk => async (dispatch, getState) => {
  const state = getState();
  const post = state.group.mainPost;
  if (!post) {
    return;
  }
  const group = { ...state.group };
  group.pageScrollY = window.scrollY;
  const instance = { ...state, group };
  await setStorage(storageKey(post), instance);
  unloaded();
};

export const loadInstance = (post: IMainPost): AppThunk => async dispatch => {
  try {
    let data: RootState = await getStorage(storageKey(post));
    console.log("load instance", data);
    dispatch(restorePage(data));
  } catch (ignore) {}
};
