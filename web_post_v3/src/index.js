import React from "react";
import ReactDOM from "react-dom";
import "./index.css";
import App from "./App";
import * as serviceWorker from "./serviceWorker";

import Analytics from "analytics";
import googleAnalytics from "@analytics/google-analytics";
// import customerIo from "@analytics/customerio";

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

window.analytics = Analytics({
  app: "xsmth-web-post",
  version: 100,
  plugins: [
    googleAnalytics({
      trackingId: "UA-41978299-3"
    })
  ]
});

/* Track a page view */
window.analytics.page();
