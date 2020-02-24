import React from "react";
import { combineReducers, Action } from "redux";
import { Provider } from "react-redux";
import { configureStore, ThunkAction } from "@reduxjs/toolkit";

import groupReducer from "./groupSlice";
import Group from "./components/Group";

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
    </Provider>
  );
}

export default Article;
