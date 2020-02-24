import React, { useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import { getMainPost, nextTask } from "../groupSlice";
import { RootState } from "..";
import Page from "./Page";

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
      <div>Group:</div>
      board: {mainPost.board}
      <div className="page-list">
        {new Array(pageCount).fill(0).map((_, p) => (
          <Page key={p} p={p + 1} />
        ))}
      </div>
      <TaskQueue />
    </div>
  );
}

function TaskQueue() {
  const queue = useSelector((state: RootState) => state.group.tasks);
  const dispatch = useDispatch();
  useEffect(() => {
    console.log(queue);
    if (queue.length > 0) {
      dispatch(nextTask());
    }
  }, [queue, dispatch]);
  return <></>;
}

export default Group;
