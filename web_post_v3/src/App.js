import React from "react";
import PostGroupPage from "./postgroup/PostGroupPage";
import BridgeTest from "./BridgeTest";
import DebugPage from "./DebugPage";

function App() {
  const url = new URL(window.location.href);
  const isDebug = !!url.searchParams.get("debug");
  return (
    <div className="App">
      <button onClick={e => window.location.reload()}>Refresh</button>
      {isDebug ? <DebugPage /> : null}
      {isDebug ? <BridgeTest /> : null}
      <PostGroupPage />
    </div>
  );
}

export default App;
