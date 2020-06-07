import React, { useEffect } from "react";
import "@simonwep/pickr/dist/themes/classic.min.css"; // 'classic' theme
import "@simonwep/pickr/dist/themes/monolith.min.css"; // 'monolith' theme

import Pickr from "@simonwep/pickr";
// import Pickr from "@simonwep/pickr/dist/pickr.es5.min";

import "./index.css";
import { xOpen, ModalStyle } from "../jsapi";

function App() {
  const addTags = () => {
    const { origin, pathname } = window.location;
    xOpen({
      url: origin + pathname + "#/addtags",
      type: ModalStyle.modal
    });
  };
  const showPicker = () => {
    const picker = Pickr.create({
      el: ".color-picker",
      theme: "monolith", // or 'monolith', or 'nano'
      //   position: "bottom-middle",
      //   container: ".picker-container",
      swatches: [
        "rgba(244, 67, 54, 1)",
        "rgba(233, 30, 99, 0.95)",
        "rgba(156, 39, 176, 0.9)",
        "rgba(103, 58, 183, 0.85)",
        "rgba(63, 81, 181, 0.8)",
        "rgba(33, 150, 243, 0.75)",
        "rgba(3, 169, 244, 0.7)",
        "rgba(0, 188, 212, 0.7)",
        "rgba(0, 150, 136, 0.75)",
        "rgba(76, 175, 80, 0.8)",
        "rgba(139, 195, 74, 0.85)",
        "rgba(205, 220, 57, 0.9)",
        "rgba(255, 235, 59, 0.95)",
        "rgba(255, 193, 7, 1)"
      ],

      components: {
        // Main components
        preview: true,
        opacity: true,
        hue: true,

        // Input / output Options
        interaction: {
          hex: true,
          rgba: true,
          hsla: true,
          hsva: true,
          cmyk: true,
          input: true,
          clear: true,
          save: true
        }
      }
    });
  };

  return (
    <div className="main">
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
      <div className="cell" onClick={addTags}>
        ➕添加Tag
      </div>
      <div
        className="cell picker-container"
        // style={{
        //   justifyContent: "center",
        //   alignItems: "center"
        // }}
      >
        Picker <div className="color-picker"></div>
      </div>
    </div>
  );
}

export default App;
