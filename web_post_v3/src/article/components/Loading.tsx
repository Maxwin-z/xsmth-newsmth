import React, { FC } from "react";
const Loading: FC<{
  hide?: boolean;
  onClick?: (event: React.MouseEvent) => void;
}> = props => (
  <div className="loading-container" onClick={props.onClick || (() => {})}>
    {props.children}
    <div className={"loading-icon " + (props.hide ? "hide" : "")}></div>
  </div>
);

export default Loading;
