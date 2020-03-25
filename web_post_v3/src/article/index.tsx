import React, { useEffect, FC, memo } from "react";
import { combineReducers, Action } from "redux";
import { Provider, useSelector, useDispatch } from "react-redux";
import { configureStore, ThunkAction } from "@reduxjs/toolkit";

import groupReducer, {
  nextTask,
  onSelectPage,
  resetScrollY,
  singleAuthor
} from "./groupSlice";
import imageReducer, { handleImageDownloadProgress } from "./slices/imageTask";
import Group from "./components/Group";
import "./handlers/theme";
import "./index.css";
import { setupTheme } from "./handlers/theme";
import { getThemeConfig, unloaded } from "./utils/jsapi";
import { ITheme } from "./types";
import XImageQueue from "./components/XImageQueue";
import { scrollHander } from "./handlers/scroll";
import { clickHander } from "./handlers/click";
import { saveInstance } from "./handlers/pageState";
import SingleAuthor from "./components/SingleAuthor";
import SinglePost from "./components/SinglePost";

const rootReducer = combineReducers({
  group: groupReducer,
  imageTask: imageReducer
});

const store = configureStore({
  reducer: rootReducer
});

(async () => {
  const theme = await getThemeConfig();
  setupTheme(theme);

  document.addEventListener("scroll", scrollHander);
  document.addEventListener("click", clickHander);

  PubSub.subscribe("THEME_CHANGE", (_: string, style: ITheme) => {
    setupTheme(style);
  });

  PubSub.subscribe("DOWNLOAD_PROGRESS", (_: string, data: any) =>
    handleImageDownloadProgress(data)
  );

  PubSub.subscribe("SINGLE_AUTHOR", (_: string, data: string) => {
    const author = data;
    console.log("single author", author);
  });
})();

export type RootState = ReturnType<typeof rootReducer>;
export type AppThunk = ThunkAction<void, RootState, null, Action<string>>;

function Article() {
  return (
    <Provider store={store}>
      <Group />
      <SinglePost />
      <SingleAuthor />
      <TaskQueue />
      <XImageQueue />
    </Provider>
  );
}

const TaskQueue: FC<{}> = memo(() => {
  // console.log("TaskQueue");
  const queue = useSelector((state: RootState) => state.group.tasks);
  const pageScrollY = useSelector(
    (state: RootState) => state.group.pageScrollY
  );
  const dispatch = useDispatch();
  useEffect(() => {
    // console.log(queue);
    if (queue.length > 0) {
      dispatch(nextTask());
    }
  }, [queue, dispatch]);

  useEffect(() => {
    if (pageScrollY === -1) return;
    const handler = () => {
      dispatch(resetScrollY());
    };
    document.addEventListener("touchmove", handler);
    return () => {
      document.removeEventListener("touchmove", handler);
    };
  }, [pageScrollY, dispatch]);

  useEffect(() => {
    const actions: { [x: string]: Function } = {
      PAGE_SELECTED: (_: string, page: number) => {
        dispatch(onSelectPage(page));
      },
      PAGE_CLOSE: async () => {
        console.log("page close");
        dispatch(saveInstance());
      },
      SINGLE_AUTHOR: (_: string, author: string) => {
        dispatch(singleAuthor(author));
      }
    };
    const handlers: any[] = Object.keys(actions).map(event => {
      const action = actions[event];
      const handler = PubSub.subscribe(event, action);
      return handler;
    });

    return () => {
      handlers.forEach(handler => {
        PubSub.unsubscribe(handler);
      });
    };
  }, [dispatch]);
  return <></>;
});

export default Article;
