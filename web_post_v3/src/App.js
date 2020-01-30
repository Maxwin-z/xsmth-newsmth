import React from "react";
import logo from "./logo.svg";
import "./App.css";
import "./PostGroup";
import PostGroup from "./PostGroup";
import BridgeTest from "./BridgeTest";

function App() {
  return (
    <div className="App">
      <BridgeTest />
      <PostGroup />
    </div>
  );
}

export default App;
