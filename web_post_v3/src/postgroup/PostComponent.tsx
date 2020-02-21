import React, { FunctionComponent } from "react";
import { Post } from "./types.d";
import { reply, showActivity } from "../jsbridge";
import { Json } from "..";

const PostComponent: FunctionComponent<{
  post: Post;
  p: number;
  title: string;
  board: string;
}> = ({ post, p, title, board }) => {
  function makeActionPost() {
    let actionPost: Json = {};
    actionPost.title = title;
    actionPost.author = post.author!;
    actionPost.nick = post.nick!;
    actionPost.pid = post.pid!;
    actionPost.board = {
      name: board
    };
    actionPost.content = post
      .content!.replace(/<br\/?>/g, "\n")
      .replace(/<.*?>/g, "")
      .replace(/&nbsp;/g, " ")
      .replace(/&lt;/g, "<")
      .replace(/&gt;/g, ">")
      .replace(/&amp;/g, "&");
    return actionPost;
  }
  function doReply() {
    reply(makeActionPost());
  }
  function doActivity() {
    showActivity(makeActionPost());
  }
  return (
    <div className="post" data-page={p} data-floor={post.floor}>
      <div className="post-title">
        <div>
          {post.author}
          {post.nick!.length > 0 ? `(${post.nick})` : ``}
        </div>
        <div className="post-info">
          <span className="floor">
            {post.floor === 0 ? "楼主" : `${post.floor}楼`}
          </span>
          <span className="date">{post.dateString}</span>
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
      <div dangerouslySetInnerHTML={{ __html: post.content || "" }}></div>
    </div>
  );
};

export default PostComponent;
