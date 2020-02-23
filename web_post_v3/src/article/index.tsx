import React from "react";
import { combineReducers } from "redux";
import { Provider } from "react-redux";
import { configureStore } from "@reduxjs/toolkit";

import groupReducer from "./groupSlice";
import Group from "./components/Group";

const rootReducer = combineReducers({
  group: groupReducer
});

const store = configureStore({
  reducer: rootReducer
});

export type RootState = ReturnType<typeof rootReducer>;

function Article() {
  return (
    <Provider store={store}>
      <Group />
    </Provider>
  );
}

export default Article;
