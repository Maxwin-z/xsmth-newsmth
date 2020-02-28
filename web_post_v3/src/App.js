import React from "react";
import PostGroupPage from "./postgroup/PostGroupPage";
// import BridgeTest from "./BridgeTest";
// import DebugPage from "./DebugPage";
// import TaskTest from "./tests/Task.test";
// import ReduxTest from "./tests/Redux.test";
// import Article from "./article/index";

function App() {
  // const url = new URL(window.location.href);
  // const isDebug = !!url.searchParams.get("debug");
  return (
    <div className="App">
      {/* {isDebug ? <DebugPage /> : null} */}
      {/* {isDebug ? <BridgeTest /> : null} */}
      {/* <TaskTest /> */}
      {/* <ReduxTest /> */}
      <PostGroupPage />
      {/* <Article /> */}
    </div>
  );
}

export default App;
