import { FC } from "react";
import React from "react";
import { useSelector } from "react-redux";
import { RootState } from "..";
import { ArticleStatus } from "../types";
import Loading from "./Loading";
import Post from "./Post";

const SinglePost: FC<{}> = () => {
  const singlePost = useSelector((state: RootState) => state.group.singlePost);
  const articleStatus = useSelector(
    (state: RootState) => state.group.articleStatus
  );
  if (!singlePost) {
    return null;
  }
  return (
    <div>
      {articleStatus === ArticleStatus.allLoading ? (
        <Loading>正在加载...</Loading>
      ) : (
        <Post post={singlePost!} p={1} />
      )}
    </div>
  );
};

export default SinglePost;
