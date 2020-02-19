import React from "react";
import PostGroupPage from "./postgroup/PostGroupPage";
import BridgeTest from "./BridgeTest";
import DebugPage from "./DebugPage";

function App() {
  const url = new URL(window.location.href);
  const isDebug = 1 || !!url.searchParams.get("debug");
  return (
    <div className="App">
      {isDebug ? <DebugPage /> : null}
      {isDebug ? <BridgeTest /> : null}
      <PostGroupPage />
    </div>
  );
}

export default App;
