import React from "react";
import loadable from "@loadable/component";
import { HashRouter as Router, Switch, Route } from "react-router-dom";
import Loading from "./article/components/Loading";

const Article = loadable(() => import("./article/index"), {
  fallback: <Loading />
});
const Likes = loadable(() => import("./likes/Likes"));
const BridgeTest = loadable(() => import("./BridgeTest"));

function App() {
  // const url = new URL(window.location.href);
  // const isDebug = !!url.searchParams.get("debug");
  return (
    <Router>
      <div className="App">
        {/* {isDebug ? <DebugPage /> : null} */}
        {/* {isDebug ? <BridgeTest /> : null} */}
        {/* <TaskTest /> */}
        {/* <ReduxTest /> */}
        {/* <PostGroupPage /> */}
        {/* <Article /> */}
      </div>
      <Switch>
        <Route path="/likes">
          <Likes />
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
