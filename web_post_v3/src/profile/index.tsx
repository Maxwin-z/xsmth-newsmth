import React from "react";
import "./index.css";

function App() {
  return (
    <div>
      <div className="header flex-row">
        <img
          className="avatar"
          src="https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=1373357642,1398373029&fm=26&gp=0.jpg"
        />
        <div className="userinfo flex1 flex-column">
          <div className="username flex1">Maxwin</div>
          <div className="nickname flex1">Nickname</div>
          <div className="state flex1">
            <span className="online">●在线</span>
            <span className="offline">●离线</span>
            <span className="location">111.32.62.*</span>
          </div>
        </div>
      </div>
      <div className="cell flex-row">
        <div className="flex1">用户积分</div>
        <div className="">用户积分</div>
      </div>
      <div className="cell flex-row">
        <div className="flex1">用户积分</div>
        <div className="">用户积分</div>
      </div>
      <div className="cell flex-row">
        <div className="flex1">用户积分</div>
        <div className="">用户积分</div>
      </div>
      <div className="tag-section">Tags</div>
      <div className="cell flex-row">
        <div className="flex1">
          <span className="tag">■</span>
          车迷
        </div>
        <div className="delete">⛔️</div>
      </div>
      <div className="cell flex-row">
        <div className="flex1">
          <span className="tag">■</span>
          车迷
        </div>
        <div className="delete">⛔️</div>
      </div>
      <div className="tag-section">我的Tags</div>
      <div className="cell flex-row">
        <div className="flex1">
          <span className="tag">■</span>
          黑子
        </div>
        <div className="delete">➕</div>
      </div>
      <div className="cell">➕添加Tag</div>
    </div>
  );
}

export default App;
