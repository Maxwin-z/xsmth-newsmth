import React, { useEffect, FC } from "react";
import { useDispatch, useSelector } from "react-redux";
import { getMainPost } from "../groupSlice";
import { RootState } from "..";
import Page from "./Page";

const GroupTitle: FC<{ title: string }> = ({ title }) => <h1>{title}</h1>;
const Pages: FC<{ count: number }> = ({ count }) => (
  <div className="page-list">
    {new Array(count).fill(0).map((_, p) => (
      <Page key={p} p={p + 1} />
    ))}
  </div>
);

function Group() {
  const dispatch = useDispatch();
  const mainPost = useSelector((state: RootState) => state.group.mainPost);
  const pageCount = useSelector(
    (status: RootState) => status.group.pages.length
  );
  console.log("mainPost", mainPost);

  useEffect(() => {
    dispatch(getMainPost());
  }, [dispatch]);

  console.log("Group render");

  return (
    <div>
      <GroupTitle title={mainPost.title} />
      <Pages count={pageCount} />
    </div>
  );
}

export default Group;
