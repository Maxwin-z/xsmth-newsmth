import { FC } from "react";
import React from "react";
import { useSelector } from "react-redux";
import { RootState } from "..";
import { ArticleStatus } from "../types";
import Loading from "./Loading";
import Post from "./Post";

const SinglePost: FC<{}> = () => {
  const post = useSelector((state: RootState) => state.group.singlePost);
  const articleStatus = useSelector(
    (state: RootState) => state.group.articleStatus
  );
  if (!post) {
    return null;
  }
  return (
    <div className="main">
      {articleStatus === ArticleStatus.allLoading ? (
        <Loading>正在加载...</Loading>
      ) : (
        <>
          <div id="title">{post!.title}</div>
          <Post post={post!} p={1} />
        </>
      )}
    </div>
  );
};

export default SinglePost;
