import { FC, useEffect, useState } from "react";
import React from "react";
import { getThemeConfig, ajax } from "../jsapi";
import { ITheme, IPost } from "../article/types";
import "./likes.css";
import { getQuery } from "../article/utils/urlHelper";
import { GroupTask } from "../article/utils/Task";
import Post from "../article/components/Post";
import { combineReducers, Action } from "redux";

import likesReducer, { loadLikes } from "./likesSlice";
import { configureStore, ThunkAction } from "@reduxjs/toolkit";
import { Provider, useDispatch, useSelector } from "react-redux";

const rootReducer = combineReducers({
  group: likesReducer
});
const store = configureStore({
  reducer: rootReducer
});
export type LikesRootState = ReturnType<typeof rootReducer>;
export type LikesThunk = ThunkAction<
  void,
  LikesRootState,
  null,
  Action<string>
>;

const Likes: FC<{}> = () => {
  const post = useSelector((state: LikesRootState) => state.group.post);
  const error = useSelector((state: LikesRootState) => state.group.error);
  const dispatch = useDispatch();
  useEffect(() => {
    dispatch(loadLikes());
  }, [dispatch]);
  return (
    <div className="main">
      {post && <Post post={post} p={1} />}
      <div>{error}</div>
    </div>
  );
};

function App() {
  return (
    <Provider store={store}>
      <Likes />
    </Provider>
  );
}

export default App;
