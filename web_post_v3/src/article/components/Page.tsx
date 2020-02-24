import React, { FC } from "react";
import { useSelector } from "react-redux";
import { RootState } from "..";
import Post from "./Post";

const Page: FC<{ p: number }> = ({ p }) => {
  const { page, title, board } = useSelector((state: RootState) => ({
    page: state.group.pages[p - 1],
    title: state.group.mainPost.title,
    board: state.group.mainPost.board
  }));
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
