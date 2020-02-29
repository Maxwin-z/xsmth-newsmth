import React, { useEffect, FC } from "react";
import { useDispatch, useSelector } from "react-redux";
import { getMainPost } from "../groupSlice";
import { RootState } from "..";
import Page from "./Page";
import { ArticleStatus } from "../types";
import Loading from "./Loading";

const GroupTitle: FC<{ title: string }> = ({ title }) => <h1>{title}</h1>;
const Pages: FC<{ count: number }> = ({ count }) => (
  <div className="page-list">
    {new Array(count).fill(0).map((_, p) => (
      <Page key={p} p={p + 1} />
    ))}
  </div>
);

const Footer: FC<{}> = () => {
  const { articleStatus, lastLoading, total } = useSelector(
    (state: RootState) => ({
      articleStatus: state.group.articleStatus,
      lastLoading: state.group.lastLoading,
      total: state.group.pages.length
    })
  );
  if (
    articleStatus === ArticleStatus.allLoading ||
    articleStatus === ArticleStatus.allFail
  ) {
    return null;
  }
  if (articleStatus === ArticleStatus.allSuccess) {
    return (
      <Loading hide={true}>
        已加载 {total}/{total}，点击尝试加载最新
      </Loading>
    );
  }
  if (articleStatus === ArticleStatus.middlePageLoading) {
    return (
      <Loading hide={true}>
        正在加载 {lastLoading}/{total}
      </Loading>
    );
  }
  if (articleStatus === ArticleStatus.footerLoading) {
    return (
      <Loading>
        正在加载 {lastLoading}/{total}
      </Loading>
    );
  }
  if (articleStatus === ArticleStatus.footerFail) {
    return (
      <Loading hide={true}>
        加载 {lastLoading}/{total} 失败，点击重试
      </Loading>
    );
  }
  return <Loading>正在加载</Loading>;
};

function Group() {
  const dispatch = useDispatch();
  const { mainPost, pageCount, articleStatus } = useSelector(
    (state: RootState) => ({
      mainPost: state.group.mainPost,
      pageCount: state.group.pages.length,
      articleStatus: state.group.articleStatus
    })
  );
  console.log("mainPost", mainPost);

  useEffect(() => {
    dispatch(getMainPost());
  }, [dispatch]);

  console.log("Group render");

  return (
    <div>
      <GroupTitle title={mainPost.title} />
      {articleStatus === ArticleStatus.allLoading ? (
        <Loading>正在加载</Loading>
      ) : null}
      <Pages count={pageCount} />
      <Footer />
    </div>
  );
}

export default Group;
