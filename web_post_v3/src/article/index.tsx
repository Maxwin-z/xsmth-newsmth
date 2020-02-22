import React from "react";
import { createStore, combineReducers } from "redux";
import { Provider } from "react-redux";

import { pages, IPagesState } from "./reducers/group";
import Group from "./components/Group";

interface Window {
  __REDUX_DEVTOOLS_EXTENSION__?: Function | null;
}
declare let window: Window;

export interface IStore {
  pages: IPagesState;
}

const store = createStore(
  combineReducers({
    pages
  }),
  window.__REDUX_DEVTOOLS_EXTENSION__ && window.__REDUX_DEVTOOLS_EXTENSION__()
);

function Article() {
  return (
    <Provider store={store}>
      <Group />
    </Provider>
  );
}

export default Article;
