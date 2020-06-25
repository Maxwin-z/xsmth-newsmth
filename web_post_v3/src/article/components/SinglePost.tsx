import { FC, useReducer, useRef } from "react";
import React from "react";
import { useSelector, useDispatch } from "react-redux";
import { RootState } from "..";
import { ArticleStatus, IPost } from "../types";
import Loading from "./Loading";
import Post from "./Post";
import { expandSinglePost } from "../groupSlice";
import { toast, ajax, ToastType } from "../../jsapi";

const Likes: FC<{ post: IPost }> = ({ post }) => {
  console.log(post);
  const scoreRef = useRef<HTMLSelectElement>(null);
  const msgRef = useRef<HTMLTextAreaElement>(null);
  const doLike = async () => {
    const msg = (msgRef.current?.value || "").trim();
    if (msg.length === 0) {
      toast({
        type: ToastType.error,
        message: "请输入短评" + msg
      });
      return;
    }
    const html = await ajax({
      url: `http://www.newsmth.net/nForum/article/${post.board}/ajax_add_like/${post.pid}.json`,
      headers: {
        "X-Requested-With": "XMLHttpRequest"
      },
      method: "POST",
      data: {
        score: scoreRef.current?.value || 0,
        msg
      }
    });
    try {
      const json = JSON.parse(html);
      toast({
        type: json.ajax_code === "1801" ? ToastType.success : ToastType.error,
        message: json.ajax_msg
      });
      window.location.reload();
    } catch (e) {
      toast({
        type: ToastType.error,
        message: e.toString()
      });
    }
    console.log(html);
  };
  return (
    <div className="likes">
      <div className="like-compose">
        <textarea
          rows={2}
          maxLength={30}
          placeholder="请输入您的短评，不超过30个字"
          ref={msgRef}
        ></textarea>
        <div className="like-op">
          积分
          <select defaultValue={0} ref={scoreRef}>
            {new Array(11).fill(0).map((_, i) => (
              <option value={i - 5} key={i}>
                {i - 5}
              </option>
            ))}
          </select>
          <div style={{ flex: 1 }}></div>
          <button className="btn-like action tint-color" onClick={doLike}>
            我要Like
          </button>
        </div>
      </div>
    </div>
  );
};

const SinglePost: FC<{}> = () => {
  const post = useSelector((state: RootState) => state.group.singlePost);
  const mainPost = useSelector((state: RootState) => state.group.mainPost);

  const articleStatus = useSelector(
    (state: RootState) => state.group.articleStatus
  );
  const dispatch = useDispatch();
  const isLike = window.location.hash.indexOf("#/likes") === 0;

  const expand = () => {
    dispatch(expandSinglePost());
  };

  if (!post || !mainPost.single) {
    return null;
  }
  // console.log(mainPost, post);
  return (
    <div className="main">
      {articleStatus === ArticleStatus.allLoading ? (
        <Loading>正在加载...</Loading>
      ) : (
        <>
          <div id="title">{post!.title}</div>
          <Post post={post!} p={1} />
          {!isLike ? (
            <div className="button" onClick={expand}>
              展开
            </div>
          ) : (
            <Likes post={{ ...post, board: mainPost.board }} />
          )}
          <div style={{ marginBottom: 100 }}></div>
        </>
      )}
    </div>
  );
};

export default SinglePost;
