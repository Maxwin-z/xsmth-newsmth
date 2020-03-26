import { AppThunk, RootState } from "..";
import { setStorage, getStorage, unloaded, ajax, Json } from "../utils/jsapi";
import { IMainPost, Status, IPost } from "../types";
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
  group.pages = group.pages.map(page => {
    if (page.status != Status.success) {
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
  //   console.log("save instance", instance);
  await setStorage(storageKey(post), instance);
  unloaded();
};

export const loadInstance = (post: IMainPost): AppThunk => async dispatch => {
  try {
    let data: RootState = await getStorage(storageKey(post));
    // console.log("load instance", data);
    dispatch(restorePage(data));
  } catch (ignore) {}
};
