import React, { FC } from "react";
import { IPost } from "../groupSlice";
import { reply, showActivity } from "../utils/jsapi";

export interface IActionPost {
  title: string;
  author: string;
  nick: string;
  pid: number;
  board: {
    name: string;
  };
  content: string;
}

const Post: FC<{
  post: IPost;
  p: number;
  title: string;
  board: string;
}> = ({
  post: { author, nick, dateString, content, floor },
  p,
  title,
  board
}) => {
  function makeActionPost() {
    const actionPost: IActionPost = {
      title,
      author,
      nick,
      pid: 0,
      board: {
        name: board
      },
      content: content!
        .replace(/<br\/?>/g, "\n")
        .replace(/<.*?>/g, "")
        .replace(/&nbsp;/g, " ")
        .replace(/&lt;/g, "<")
        .replace(/&gt;/g, ">")
        .replace(/&amp;/g, "&")
    };

    return actionPost;
  }
  function doReply() {
    reply(makeActionPost());
  }
  function doActivity() {
    showActivity(makeActionPost());
  }
  return (
    <div className="post" data-page={p} data-floor={floor}>
      <div className="post-title">
        <div>
          {author}
          {nick!.length > 0 ? `(${nick})` : ``}
        </div>
        <div className="post-info">
          <span className="floor">{floor === 0 ? "楼主" : `${floor}楼`}</span>
          <span className="date">{dateString}</span>
        </div>
        <div className="post-action">
          <div className="action replay" onClick={doReply}>
            回复
          </div>
          <div className="action more" onClick={doActivity}>
            ···
          </div>
        </div>
      </div>
      <div dangerouslySetInnerHTML={{ __html: content || "" }}></div>
    </div>
  );
};

export default Post;
