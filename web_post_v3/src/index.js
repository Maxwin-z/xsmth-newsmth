import React from "react";
import ReactDOM from "react-dom";
import "./index.css";
import App from "./App";
import * as serviceWorker from "./serviceWorker";
// import "./jsbridge.ts";
ReactDOM.render(
  <App />,
  document.getElementById("root") || document.querySelector("body")
);
window.history.scrollRestoration = "manual";

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
