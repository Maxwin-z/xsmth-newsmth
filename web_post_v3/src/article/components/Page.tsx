import React, { FC, memo, useEffect, useLayoutEffect } from "react";
import { useSelector, useDispatch } from "react-redux";
import { RootState } from "..";
import Post from "./Post";
import Loading from "./Loading";
import { IPost, Status, IPage } from "../types";
import { setSelectedPage } from "../groupSlice";

const InitPage: FC<{ p: number }> = ({ p }) => {
  return (
    <div className="page-placeholder page-init">
      <div>{p}</div>
    </div>
  );
};

const LoadingPage: FC<{ p: number }> = ({ p }) => {
  return (
    <div className="page-placeholder">
      <Loading>
        <div className="page-loading">正在加载第{p}页</div>
      </Loading>
    </div>
  );
};

const FailPage: FC<{ p: number; error: string }> = ({ p, error }) => {
  return (
    <div className="page-placeholder">
      <div>加载失败：{error}</div>
      {error === "您未登录,请登录后继续操作" ? (
        <button className="login-button">登录后重试</button>
      ) : null}
    </div>
  );
};

const SuccessPage: FC<{ posts: IPost[]; p: number }> = ({ posts, p }) => (
  <>
    {posts.map(post => (
      <Post key={post.pid} post={post} p={p} />
    ))}
  </>
);

const _Page: FC<{ page: IPage }> = ({ page }) => {
  const { p, posts, status } = page;
  if (posts.length > 0) {
    return <SuccessPage posts={posts} p={p} />;
  } else if (status === Status.init) {
    return <InitPage p={p} />;
  } else if (status === Status.loading) {
    return <LoadingPage p={p} />;
  } else {
    return <FailPage p={p} error={page.errorMessage!} />;
  }
};

let _id = 0;
const Page: FC<{ p: number }> = memo(({ p }) => {
  const batchID = ++_id;
  const page = useSelector((state: RootState) => state.group.pages[p - 1]);
  const selectedPage = useSelector(
    (state: RootState) => state.group.selectedPage
  );
  const { hidden } = page;
  if (selectedPage === p) {
    console.log(batchID, p, "select p", selectedPage, p, hidden);
  }
  const dispatch = useDispatch();
  useEffect(() => {
    if (selectedPage === p && !hidden) {
      const el = document.querySelector(`[data-page="${p}"]`) as HTMLDivElement;
      console.log(batchID, p, "needScrollToPage el", el);
      if (el) {
        const rect = el.getBoundingClientRect();
        console.log("scroll rect", rect, hidden);
        if (rect.height > 0) {
          window.scrollTo(0, rect.top + window.pageYOffset);
          dispatch(setSelectedPage(0));
        }
      }
    }
  }, [selectedPage, hidden, p, dispatch]);

  const dom = document.querySelector(`[data-page="${p}"]`);
  const lastHeight = dom ? dom.getBoundingClientRect().height : 0;
  useLayoutEffect(() => {
    const dom = document.querySelector(`[data-page="${p}"]`);
    if (!dom) return;
    const rect = dom.getBoundingClientRect();
    if (lastHeight !== rect.height && rect.top < 0) {
      window.scrollBy(0, rect.height - lastHeight);
    }
  });

  return (
    <div className={page.hidden ? "hidden page" : "page"} data-page={p}>
      <_Page page={page} />
    </div>
  );
});

export default Page;
