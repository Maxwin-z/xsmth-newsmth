import { FC } from "react";
import { RootState } from "..";
import { useSelector, useDispatch } from "react-redux";
import { ArticleStatus } from "../types";
import Loading from "./Loading";
import React from "react";
import { loadPage } from "../groupSlice";

const Footer: FC<{}> = () => {
  const { articleStatus, lastLoading, total } = useSelector(
    (state: RootState) => ({
      articleStatus: state.group.articleStatus,
      lastLoading: state.group.lastLoading,
      total: state.group.pages.length
    })
  );

  const dispatch = useDispatch();
  const loadLatest = (e: React.MouseEvent) => {
    dispatch(loadPage(total, true));
  };
  const loadLastPage = (e: React.MouseEvent) => {
    dispatch(loadPage(lastLoading === -1 ? total : lastLoading + 1, true));
  };

  if (
    articleStatus === ArticleStatus.allLoading ||
    articleStatus === ArticleStatus.allFail
  ) {
    return null;
  }
  if (articleStatus === ArticleStatus.allSuccess) {
    return (
      <Loading hide={true} onClick={loadLatest}>
        已加载 {total}/{total}，点击尝试加载最新
      </Loading>
    );
  }
  if (articleStatus === ArticleStatus.middlePageLoading) {
    return (
      <Loading hide={true}>
        正在加载 {lastLoading + 1}/{total}
      </Loading>
    );
  }
  if (articleStatus === ArticleStatus.footerLoading) {
    return (
      <Loading>
        正在加载 {lastLoading + 1}/{total}
      </Loading>
    );
  }
  if (articleStatus === ArticleStatus.footerFail) {
    return (
      <Loading hide={true} onClick={loadLastPage}>
        加载 {lastLoading === -1 ? total : lastLoading + 1}/{total}{" "}
        失败，点击重试
      </Loading>
    );
  }
  return <Loading>正在加载</Loading>;
};

export default Footer;
