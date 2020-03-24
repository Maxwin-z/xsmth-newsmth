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
  const instance = { ...state, group };
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

export const loadSinglePost = ({
  board,
  pid
}: IMainPost): AppThunk => async dispatch => {
  const html = await ajax({
    url: `http://www.newsmth.net/nForum/article/${board}/ajax_single/${pid}.json`,
    headers: {
      "X-Requested-With": "XMLHttpRequest"
    }
  });
  const data = JSON.parse(html);
  const user: Json = data.user;
  const post: IPost = {
    board,
    pid,
    gid: data.group_id as number,
    title: data.title as string,
    author: user.id as string,
    nick: user.user_name as string,
    date: (data.post_time as number) * 1000,
    dateString: "",
    content: data.content as string,
    images: [],
    floor: 0
  };
  return post;
};
