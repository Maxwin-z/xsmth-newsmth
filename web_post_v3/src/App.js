import React from "react";
// import PostGroupPage from "./postgroup/PostGroupPage";
// import BridgeTest from "./BridgeTest";
// import DebugPage from "./DebugPage";
// import TaskTest from "./tests/Task.test";
// import ReduxTest from "./tests/Redux.test";
import Article from "./article/index";
import { HashRouter as Router, Switch, Route, Link } from "react-router-dom";
import Likes from "./likes/Likes";

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
        <Route path="/">
          <Article />
        </Route>
      </Switch>
    </Router>
  );
}

export default App;
