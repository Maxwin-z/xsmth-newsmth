import { FC } from "react";
import React from "react";
import { useSelector, useDispatch } from "react-redux";
import { RootState } from "..";
import { ArticleStatus, IPost } from "../types";
import Loading from "./Loading";
import Post from "./Post";
import { expandSinglePost } from "../groupSlice";

const Likes: FC<{ post: IPost }> = ({ post }) => {
  return (
    <ul className="likes">
      {post.likes?.map(like => (
        <li key={like.user}>
          <span
            className={
              like.score == 0 ? "" : like.score > 0 ? "score_1" : "score_2"
            }
          >
            [{like.score == 0 ? "  " : like.score}]
          </span>
          <strong>{like.user}</strong>
          {like.message}
          <span className="f006">({like.dateString})</span>
        </li>
      ))}
    </ul>
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
            <Likes post={post} />
          )}
          <div style={{ marginBottom: 100 }}></div>
        </>
      )}
    </div>
  );
};

export default SinglePost;
