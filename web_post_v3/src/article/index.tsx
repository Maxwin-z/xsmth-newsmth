import React, { useEffect, FC, memo } from "react";
import { combineReducers, Action } from "redux";
import { Provider, useSelector, useDispatch } from "react-redux";
import { configureStore, ThunkAction } from "@reduxjs/toolkit";

import groupReducer, { nextTask } from "./groupSlice";
import Group from "./components/Group";
import "./index.css";

const rootReducer = combineReducers({
  group: groupReducer
});

const store = configureStore({
  reducer: rootReducer
});

export type RootState = ReturnType<typeof rootReducer>;
export type AppThunk = ThunkAction<void, RootState, null, Action<string>>;

function Article() {
  return (
    <Provider store={store}>
      <Group />
      <TaskQueue />
    </Provider>
  );
}

const TaskQueue: FC<{}> = memo(() => {
  console.log("TaskQueue");
  const queue = useSelector((state: RootState) => state.group.tasks);
  const dispatch = useDispatch();
  useEffect(() => {
    console.log(queue);
    if (queue.length > 0) {
      dispatch(nextTask());
    }
  }, [queue, dispatch]);
  return <></>;
});

export default Article;
