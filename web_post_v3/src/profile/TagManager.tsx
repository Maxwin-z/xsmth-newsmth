import React, { useEffect, useState } from "react";
import { setTitle } from "../jsapi";
import "./index.css";

setTitle("管理Tags");

export default function AddTag() {
  const [selectedColor, setSelectedColor] = useState("#F44336");
  const transparent = "#ffffff00";
  const colors = [
    "#F44336",
    "#E91E63",
    "#9C27B0",
    "#673AB7",
    "#3F51B5",
    "#2196F3",
    "#03A9F4",
    "#00BCD4",
    "#009688",
    "#4CAF50",
    "#8BC34A",
    "#CDDC39",
    "#FFEB3B",
    "#FFC107"
  ];
  return (
    <div className="main">
      <div className="section-header">管理Tags</div>
      <div className="cell flex-row">
        <div className="flex1">
          <span className="tag">■</span>
          车迷
        </div>
        <div className="delete">⛔️</div>
      </div>
      <div className="color-panel">
        {colors.map(color => (
          <div
            key={color}
            className="color"
            style={{
              borderColor: selectedColor === color ? color : transparent
            }}
            onClick={() => setSelectedColor(color)}
          >
            <div
              className="box"
              style={{
                backgroundColor: color
              }}
            ></div>
          </div>
        ))}
      </div>
      <div className="add-tag-container flex-row">
        <div
          className="box"
          style={{
            backgroundColor: selectedColor
          }}
        ></div>
        <input className="tag-input" placeholder="Tag内容" />
        <a className="btn-addtag">新增</a>
      </div>
    </div>
  );
}
