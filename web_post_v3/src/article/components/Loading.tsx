import React, { FC } from "react";
const Loading: FC<{
  hide?: boolean;
}> = props => (
  <div className="loading-container">
    {props.children}
    <div className={"loading-icon " + (props.hide ? "hide" : "")}></div>
  </div>
);

export default Loading;
