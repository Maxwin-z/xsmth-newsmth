import React from "react";
import "./App.css";
import "./PostGroup";
import PostGroup from "./PostGroup";
import BridgeTest from "./BridgeTest";

function App() {
  const test = 0;
  return (
    <div className="App">
      {test ? <BridgeTest /> : null}
      <PostGroup />
    </div>
  );
}

export default App;
