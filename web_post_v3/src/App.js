import React from "react";
import "./postgroup/PostGroup";
import PostGroup from "./postgroup/PostGroup";
import BridgeTest from "./BridgeTest";
import DebugPage from "./DebugPage";

function App() {
  const url = new URL(window.location.href);
  const isDebug = !!url.searchParams.get("debug");
  return (
    <div className="App">
      <button onClick={e => window.location.reload()}>Refresh</button>
      {isDebug ? <DebugPage /> : null}
      {true || isDebug ? <BridgeTest /> : null}
      <PostGroup />
    </div>
  );
}

export default App;
