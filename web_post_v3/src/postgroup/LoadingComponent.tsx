import React, { FunctionComponent } from "react";
const LoadingComponent: FunctionComponent<{
  hide?: boolean;
}> = props => (
  <div className="loading-container">
    {props.children}
    <div className={"loading-icon " + (props.hide ? "hide" : "")}></div>
  </div>
);

export default LoadingComponent;
