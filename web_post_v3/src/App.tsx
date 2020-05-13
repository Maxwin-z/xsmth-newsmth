import React from "react";
import loadable from "@loadable/component";
import { HashRouter as Router, Switch, Route } from "react-router-dom";
import { getThemeConfig } from "./jsapi";
import { setupTheme } from "./article/handlers/theme";
import PubSub from "pubsub-js";
import { ITheme } from "./article/types";

const Article = loadable(() => import("./article/index"));
const Likes = loadable(() => import("./likes/Likes"));
const BridgeTest = loadable(() => import("./BridgeTest"));
const Experimental = loadable(() => import("./experimental/Experimental"));

(async () => {
  const theme = await getThemeConfig();
  setupTheme(theme);

  PubSub.subscribe("THEME_CHANGE", (_: string, style: ITheme) => {
    setupTheme(style);
  });
})();

function App() {
  // const url = new URL(window.location.href);
  // const isDebug = !!url.searchParams.get("debug");
  return (
    <Router>
      <Switch>
        <Route path="/likes">
          <Likes />
        </Route>
        <Route path="/experimental">
          <Experimental />
        </Route>
        <Route path="/bridgetest">
          <BridgeTest />
        </Route>
        <Route path="/">
          <Article />
        </Route>
      </Switch>
    </Router>
  );
}

export default App;
