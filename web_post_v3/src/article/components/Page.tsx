import React, { FC } from "react";
import { useSelector } from "react-redux";
import { createSelector } from "reselect";
import { RootState } from "..";
import Post from "./Post";

const pageSelector = createSelector(
  (state: RootState) => ({
    pages: state.group.pages,
    mainPost: state.group.mainPost
  }),
  (_: RootState, p: number) => p,
  ({ pages, mainPost }, p) => {
    return {
      page: pages[p - 1],
      title: mainPost.title,
      board: mainPost.board
    };
  }
);

const Page: FC<{ p: number }> = ({ p }) => {
  const { page, title, board } = useSelector((state: RootState) =>
    pageSelector(state, p)
  );
  return (
    <div>
      Page {page.p}: {page.status}
      {page.posts.map(post => (
        <Post key={post.pid} post={post} title={title} board={board} p={p} />
      ))}
    </div>
  );
};

export default Page;
