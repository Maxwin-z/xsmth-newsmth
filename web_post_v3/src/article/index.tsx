import React, { useEffect, FC, memo } from "react";
import { combineReducers, Action } from "redux";
import { Provider, useSelector, useDispatch } from "react-redux";
import { configureStore, ThunkAction } from "@reduxjs/toolkit";

import groupReducer, { nextTask } from "./groupSlice";
import imageReducer, { handleImageDownloadProgress } from "./slices/imageTask";
import Group from "./components/Group";
import "./handlers/theme";
import "./index.css";
import { setupTheme } from "./handlers/theme";
import { getThemeConfig } from "./utils/jsapi";
import { ITheme } from "./types";
import XImageQueue from "./components/XImageQueue";
import { scrollHander } from "./handlers/scroll";
import { clickHander } from "./handlers/click";

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
})();

export type RootState = ReturnType<typeof rootReducer>;
export type AppThunk = ThunkAction<void, RootState, null, Action<string>>;

function Article() {
  return (
    <Provider store={store}>
      <Group />
      <TaskQueue />
      <XImageQueue />
    </Provider>
  );
}

const TaskQueue: FC<{}> = memo(() => {
  // console.log("TaskQueue");
  const queue = useSelector((state: RootState) => state.group.tasks);
  const dispatch = useDispatch();
  useEffect(() => {
    // console.log(queue);
    if (queue.length > 0) {
      dispatch(nextTask());
    }
  }, [queue, dispatch]);
  return <></>;
});

export default Article;
