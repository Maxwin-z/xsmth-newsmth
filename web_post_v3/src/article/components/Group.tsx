import React, { useEffect, FC, memo } from "react";
import { useDispatch, useSelector } from "react-redux";
import { getMainPost } from "../groupSlice";
import { RootState } from "..";
import Page from "./Page";
import { ArticleStatus } from "../types";
import Loading from "./Loading";
import Footer from "./Footer";

const GroupTitle: FC<{ title: string }> = ({ title }) => (
  <div id="title">{title}</div>
);
const Pages: FC<{ count: number }> = memo(({ count }) => (
  <div className="page-list">
    {new Array(count).fill(0).map((_, p) => (
      <Page key={p} p={p + 1} />
    ))}
  </div>
));

function Group() {
  const dispatch = useDispatch();
  const { mainPost, pageCount, articleStatus } = useSelector(
    (state: RootState) => ({
      mainPost: state.group.mainPost,
      pageCount: state.group.pages.length,
      articleStatus: state.group.articleStatus
    })
  );
  // console.log("mainPost", mainPost);

  useEffect(() => {
    dispatch(getMainPost());
  }, [dispatch]);

  // console.log("Group render");

  return (
    <div className="main">
      <GroupTitle title={mainPost.title} />
      {articleStatus === ArticleStatus.allLoading ? (
        <Loading>正在加载...</Loading>
      ) : null}
      <Pages count={pageCount} />
      <Footer />
    </div>
  );
}

export default Group;
