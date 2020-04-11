import { AppThunk, RootState } from "..";
import {
  setStorage,
  getStorage,
  unloaded,
  removeStorage
} from "../utils/jsapi";
import { IMainPost, Status } from "../types";
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
  group.taskCount = 0;
  group.pages = group.pages.map(page => {
    if (page.status !== Status.success) {
      return Object.assign({}, page, {
        status: Status.init
      });
    }
    return page;
  });
  group.tasks = group.tasks.map(task => {
    const t = Object.assign({}, task, {
      status: Status.init
    });
    console.log(t);
    return t;
  });
  const imageTask = { ...state.imageTask };
  imageTask.images = imageTask.images.map(img =>
    Object.assign({}, img, { staus: Status.init })
  );
  const instance = { ...state, group, imageTask };
  // console.log("save instance", instance);
  await setStorage(storageKey(post), instance);
  unloaded();
};

export const cacheInstance = async (post: IMainPost) => {
  // removeStorage(storageKey(post));
  try {
    let data: RootState = await getStorage(storageKey(post));
    console.log("load instance", data);
    return data;
  } catch (ignore) {}
  return null;
};

export const loadInstance = (post: IMainPost): AppThunk => async dispatch => {
  const data = await cacheInstance(post);
  data && dispatch(restorePage(data));
};

export const removeInstance = async (post: IMainPost) => {
  await removeStorage(storageKey(post));
};
