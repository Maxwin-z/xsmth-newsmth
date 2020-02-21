import React from "react";
import PostGroupPage from "./postgroup/PostGroupPage";
import BridgeTest from "./BridgeTest";
import DebugPage from "./DebugPage";
import TaskTest from "./tests/Task.test";

function App() {
  const url = new URL(window.location.href);
  const isDebug = !!url.searchParams.get("debug");
  return (
    <div className="App">
      {/* {isDebug ? <DebugPage /> : null} */}
      {/* {isDebug ? <BridgeTest /> : null} */}
      <TaskTest />
      <PostGroupPage />
    </div>
  );
}

export default App;
