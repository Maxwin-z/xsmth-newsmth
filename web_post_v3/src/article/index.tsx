import React, { useEffect, FC } from "react";
import { combineReducers, Action } from "redux";
import { Provider, useSelector, useDispatch } from "react-redux";
import { configureStore, ThunkAction } from "@reduxjs/toolkit";

import groupReducer, {
  nextTask,
  onSelectPage,
  resetScrollY,
  refreshPage,
  openSingleAuthorPage,
} from "./groupSlice";
import imageReducer, { handleImageDownloadProgress } from "./slices/imageTask";
import Group from "./components/Group";
import "./handlers/theme";
import "./index.css";
import XImageQueue from "./components/XImageQueue";
import { scrollHander } from "./handlers/scroll";
import { clickHander } from "./handlers/click";
import { saveInstance } from "./handlers/pageState";
import SingleAuthor from "./components/SingleAuthor";
import SinglePost from "./components/SinglePost";
import { ajax, toast, ToastType, xLog, xOpen } from "../jsapi";

// new VConsole();

const rootReducer = combineReducers({
  group: groupReducer,
  imageTask: imageReducer,
});

const store = configureStore({
  reducer: rootReducer,
});

(async () => {
  document.addEventListener("scroll", scrollHander);
  document.addEventListener("click", clickHander);

  PubSub.subscribe("DOWNLOAD_PROGRESS", (_: string, data: any) =>
    handleImageDownloadProgress(data)
  );
})();

export type RootState = ReturnType<typeof rootReducer>;
export type AppThunk = ThunkAction<void, RootState, null, Action<string>>;

function Article() {
  return (
    <Provider store={store}>
      <Group />
      <SinglePost />
      <SingleAuthor />
      <XImageQueue />
      <ArticleHooks />
    </Provider>
  );
}

const ArticleHooks: FC<{}> = () => {
  // useScrollHook();
  useResetScrollHook();
  usePubSubHook();
  useTaskQueueHook();
  return <></>;
};

function useResetScrollHook() {
  const dispatch = useDispatch();
  useEffect(() => {
    const handler = () => {
      dispatch(resetScrollY());
    };
    window.addEventListener("scroll", handler);
    document.addEventListener("touchmove", handler);
    document.addEventListener("click", handler);
    return () => {
      window.removeEventListener("scroll", handler);
      document.removeEventListener("touchmove", handler);
      document.removeEventListener("click", handler);
    };
  });
}

function useScrollHook() {
  const { floor, pageScrollY } = useSelector((state: RootState) => ({
    floor: state.group.floor,
    pageScrollY: state.group.pageScrollY,
  }));
  const dispatch = useDispatch();
  useEffect(() => {
    if (pageScrollY === -1 || typeof floor === "number") return;
    const handler = () => {
      // xLog("reset scrolly");
      dispatch(resetScrollY());
    };
    document.addEventListener("touchmove", handler);
    return () => {
      document.removeEventListener("touchmove", handler);
    };
  }, [pageScrollY, floor, dispatch]);
}

function usePubSubHook() {
  const dispatch = useDispatch();
  useEffect(() => {
    const actions: { [x: string]: Function } = {
      PAGE_SELECTED: (_: string, page: number) => {
        dispatch(onSelectPage(page));
      },
      PAGE_CLOSE: async () => {
        // console.log("page close");
        dispatch(saveInstance(true));
      },
      willDisappear: async () => {
        dispatch(saveInstance(false));
      },
      SINGLE_AUTHOR: (_: string, author: string) => {
        dispatch(openSingleAuthorPage(author));
        // dispatch(singleAuthor(author));
      },
      VIEW_AUTHOR: (_: string, author: string) => {
        console.log("view author", author);
        const { origin, pathname } = window.location;
        xOpen(origin + pathname + "#/profile?author=" + author);
      },
      PAGE_REFRESH: () => {
        dispatch(refreshPage());
      },
      DELETE_POST: async (
        _: string,
        { board, pid }: { board: string; pid: string }
      ) => {
        const rsp = await ajax({
          url: `https://www.newsmth.net/nForum/article/${board}/ajax_delete/${pid}.json`,
          method: "POST",
          headers: {
            "x-requested-with": "XMLHttpRequest",
          },
        });
        xLog(rsp);
        const data = JSON.parse(rsp);
        if (data.ajax_code === "0307") {
          toast({ message: data.ajax_msg, type: ToastType.success });
        } else {
          toast({ message: data.ajax_msg, type: ToastType.error });
        }
      },
    };
    const handlers: any[] = Object.keys(actions).map((event) => {
      const action = actions[event];
      const handler = PubSub.subscribe(event, action);
      return handler;
    });

    return () => {
      handlers.forEach((handler) => {
        PubSub.unsubscribe(handler);
      });
    };
  }, [dispatch]);
}

function useTaskQueueHook() {
  const { queue, taskCount } = useSelector((state: RootState) => ({
    queue: state.group.tasks,
    taskCount: state.group.taskCount,
  }));
  const dispatch = useDispatch();

  useEffect(() => {
    // console.log(132, queue, taskCount);
    if (queue.length > 0) {
      dispatch(nextTask());
    }
  }, [queue, taskCount, dispatch]);
}

export default Article;
