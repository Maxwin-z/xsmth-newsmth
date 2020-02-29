import { FC } from "react";
import { RootState } from "..";
import { useSelector } from "react-redux";
import { ArticleStatus } from "../types";
import Loading from "./Loading";
import React from "react";

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

export default Footer;
