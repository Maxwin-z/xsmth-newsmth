import { FC, useEffect, useState } from "react";
import React from "react";
import Post from "../article/components/Post";
import { combineReducers, Action } from "redux";

import likesReducer, { loadLikes } from "./likesSlice";
import { configureStore, ThunkAction } from "@reduxjs/toolkit";
import { Provider, useDispatch, useSelector } from "react-redux";

import "./likes.css";
import "../article/index.css";
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
  const title = useSelector(
    (state: LikesRootState) => state.group.mainPost.title
  );
  const post = useSelector((state: LikesRootState) => state.group.post);
  const error = useSelector((state: LikesRootState) => state.group.error);
  const dispatch = useDispatch();
  useEffect(() => {
    dispatch(loadLikes());
  }, [dispatch]);
  return (
    <div className="main">
      <div id="title">{title}</div>
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
