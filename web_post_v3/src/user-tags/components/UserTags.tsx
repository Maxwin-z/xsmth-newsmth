import { FC } from "react";
import React from "react";
import { IUserTagInfo, EUserPriority } from "../userTagsTypes";
import { setStorage } from "../../jsapi";

const UserTags: FC<{}> = () => {
  const user: IUserTagInfo = {
    priority: EUserPriority.normal,
    tags: [
      {
        color: "#ff00ff",
        text: "Test"
      },
      {
        color: "#ff0000",
        text: "Test"
      },
      {
        color: "#0000ff",
        text: "Test"
      },
      {
        color: "#333666",
        text: "text2"
      },
      {
        color: "#000000",
        text: "text2"
      }
    ],
    description: ""
  };
  setStorage("xsmth_gdff", user);
  return <div>UserTags</div>;
};

export default UserTags;
