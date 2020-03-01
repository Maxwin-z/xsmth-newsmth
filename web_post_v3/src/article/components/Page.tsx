import React, { FC, memo } from "react";
import { useSelector } from "react-redux";
import { RootState } from "..";
import Post from "./Post";
import Loading from "./Loading";
import { IPost, Status } from "../types";

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

const Page: FC<{ p: number }> = memo(({ p }) => {
  const page = useSelector((state: RootState) => state.group.pages[p - 1]);
  return (
    <div className={page.hidden ? "hidden page" : "page"} data-page={p}>
      Page {page.p}: {page.status}
      {page.status === Status.init ? <InitPage p={p} /> : null}
      {page.status === Status.loading ? <LoadingPage p={p} /> : null}
      {page.status === Status.success ? (
        <SuccessPage posts={page.posts} p={p} />
      ) : null}
      {page.status === Status.fail ? (
        <FailPage p={p} error={page.errorMessage!} />
      ) : null}
    </div>
  );
});

export default Page;
