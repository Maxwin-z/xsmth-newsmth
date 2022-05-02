import React, { useEffect, useState, ChangeEvent, useRef } from "react";
import { setTitle, toast, ToastType } from "../jsapi";
import "./index.css";
import { loadTags, ITag, saveTags } from "./tagUtil";

setTitle("管理Tags");

export default function AddTag() {
  const [selectedColor, setSelectedColor] = useState("#F44336");
  const [tags, setTags] = useState<ITag[]>([]);
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
    "#FFC107",
  ];
  const textInput = useRef<HTMLInputElement>(null);
  useEffect(() => {
    loadTags().then((tags) => setTags(tags));
  }, []);
  const onAddTagClick = () => {
    const color = selectedColor;
    const text = textInput.current?.value;
    if (!text || text.trim().length === 0) {
      toast({ type: ToastType.error, message: "请输入Tag" });
      return;
    }
    const ts = [
      ...tags,
      {
        color,
        text,
      },
    ];
    setTags(ts);
    saveTags(ts);
  };
  const onDeleteTagClick = (index: number) => {};
  return (
    <div className="main">
      <div className="section-header">管理Tags</div>
      {tags.map((tag, i) => (
        <div className="cell flex-row" key={tag.text}>
          <div className="flex1">
            <span
              className="tag"
              style={{
                color: tag.color,
              }}
            >
              ■
            </span>
            {tag.text}
          </div>
          <div className="delete" onClick={() => onDeleteTagClick(i)}>
            ⛔️
          </div>
        </div>
      ))}

      <div className="color-panel">
        {colors.map((color) => (
          <div
            key={color}
            className="color"
            style={{
              borderColor: selectedColor === color ? color : transparent,
            }}
            onClick={() => setSelectedColor(color)}
          >
            <div
              className="box"
              style={{
                backgroundColor: color,
              }}
            ></div>
          </div>
        ))}
      </div>
      <div className="add-tag-container flex-row">
        <div
          className="box"
          style={{
            backgroundColor: selectedColor,
          }}
        ></div>
        <input className="tag-input" ref={textInput} placeholder="Tag内容" />
        <a className="btn-addtag" onClick={onAddTagClick}>
          新增
        </a>
      </div>
    </div>
  );
}
