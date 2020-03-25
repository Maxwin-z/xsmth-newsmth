import React, { useEffect, FC, memo, useLayoutEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import { getMainPost, resetScrollY } from "../groupSlice";
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
  const { mainPost, pageCount, articleStatus, pageScrollY } = useSelector(
    (state: RootState) => ({
      mainPost: state.group.mainPost,
      pageCount: state.group.pages.length,
      articleStatus: state.group.articleStatus,
      pageScrollY: state.group.pageScrollY
    })
  );
  // console.log("mainPost", mainPost);

  useEffect(() => {
    dispatch(getMainPost());
  }, [dispatch]);

  useEffect(() => {
    if (pageScrollY === -1) return;
    const resize = () => {
      console.log("scroll to ", pageScrollY);
      window.scrollTo(0, pageScrollY);
    };
    window.addEventListener("resize", resize);
    return () => window.removeEventListener("resize", resize);
  }, [pageScrollY, dispatch]);

  if (mainPost.single) {
    return null;
  }

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
