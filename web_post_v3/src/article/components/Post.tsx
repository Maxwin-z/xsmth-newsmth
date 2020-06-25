import React, { FC, memo, useEffect } from "react";
import { reply, showActivity, xLog, xOpen } from "../../jsapi";
import { IPost } from "../types";
import { useSelector, useDispatch } from "react-redux";
import { RootState } from "..";
import { setFloor } from "../groupSlice";

import "../assets/iconfont/css/fontello.css";

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
}> = memo(
  ({ post: { author, nick, dateString, content, floor, pid, likes }, p }) => {
    const mainPost = useSelector((state: RootState) => state.group.mainPost);
    const scrollToFloor = useSelector((state: RootState) => state.group.floor);
    const domHeights = useSelector(
      (state: RootState) => state.group.domHeights
    );
    function makeActionPost() {
      const actionPost: IActionPost = {
        title: mainPost.title.replace(/^Re: /, ""),
        author,
        nick,
        pid,
        board: {
          name: mainPost.board
        },
        content: content!
          .replace(/<br\s*\/?>/g, "\n")
          .replace(/<.*?>/g, "")
          .replace(/&nbsp;/g, " ")
          .replace(/&lt;/g, "<")
          .replace(/&gt;/g, ">")
          .replace(/&amp;/g, "&")
      };
      // console.log("actionPost", actionPost);
      return actionPost;
    }
    function doReply() {
      reply(makeActionPost());
    }
    function doActivity() {
      showActivity(makeActionPost());
    }

    function viewAuthor(id: string) {
      const { origin, pathname } = window.location;
      xOpen(origin + pathname + "#/profile?author=" + (id || author));
    }

    const dispatch = useDispatch();
    useEffect(() => {
      if (scrollToFloor === floor) {
        const el = document.querySelector(
          `[data-floor="${floor}"]`
        ) as HTMLDivElement;
        const rect = el.getBoundingClientRect();
        window.scrollBy(0, rect.top);
        console.log("scroll to ", rect.top);
        dispatch(setFloor(-1));
      }
    }, [scrollToFloor, floor, dispatch]);

    const domHeight = domHeights && domHeights[floor];
    // console.log(floor, domHeight);
    return (
      <div
        className="post"
        style={{
          minHeight: domHeight && Number.isInteger(domHeight) ? domHeight : 0
        }}
        data-page={p}
        data-floor={floor}
      >
        <div className="post-title">
          <div
            className="tint-color skip-scroll"
            onClick={() => viewAuthor(author)}
          >
            {author}
            {nick!.length > 0 ? `(${nick})` : ``}
          </div>
          <div className="post-info">
            <span className="floor">{floor === 0 ? "楼主" : `${floor}楼`}</span>
            <span className="date">{dateString}</span>
          </div>
          <div className="post-action">
            <div className="action replay skip-scroll" onClick={doReply}>
              回复
            </div>
            <div className="action more skip-scroll" onClick={doActivity}>
              ···
            </div>
          </div>
        </div>
        <div dangerouslySetInnerHTML={{ __html: content || "" }}></div>
        <div className="likes">
          <ul className="likes-list">
            {likes?.map(like => (
              <li key={like.user}>
                <span
                  className={
                    like.score == 0
                      ? ""
                      : like.score > 0
                      ? "score_1"
                      : "score_2"
                  }
                >
                  <span
                    className={
                      like.score === 0
                        ? ""
                        : like.score > 0
                        ? "icon-thumbs-up"
                        : "icon-thumbs-down"
                    }
                  >
                    &#xe800;
                  </span>
                  {like.score == 0 ? "  " : like.score}
                </span>
                <span
                  className="tint-color skip-scroll"
                  onClick={() => viewAuthor(like.user)}
                >
                  {like.user}:
                </span>
                {like.message}
                <span className="f006">({like.dateString})</span>
              </li>
            ))}
          </ul>
        </div>
      </div>
    );
  }
);

export default Post;
