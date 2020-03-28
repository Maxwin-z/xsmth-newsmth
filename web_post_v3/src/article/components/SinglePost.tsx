import { FC } from "react";
import React from "react";
import { useSelector, useDispatch } from "react-redux";
import { RootState } from "..";
import { ArticleStatus } from "../types";
import Loading from "./Loading";
import Post from "./Post";
import { expandSinglePost } from "../groupSlice";

const SinglePost: FC<{}> = () => {
  const post = useSelector((state: RootState) => state.group.singlePost);
  const mainPost = useSelector((state: RootState) => state.group.mainPost);
  const articleStatus = useSelector(
    (state: RootState) => state.group.articleStatus
  );
  const dispatch = useDispatch();

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
          <div className="button" onClick={expand}>
            展开
          </div>
          <div style={{ marginBottom: 100 }}></div>
        </>
      )}
    </div>
  );
};

export default SinglePost;
