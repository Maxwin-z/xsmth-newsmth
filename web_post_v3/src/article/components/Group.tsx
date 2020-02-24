import React, { useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import { getMainPost, nextTask } from "../groupSlice";
import { RootState } from "..";

function Group() {
  const dispatch = useDispatch();
  const mainPost = useSelector((state: RootState) => state.group.mainPost);
  console.log("mainPost", mainPost);

  useEffect(() => {
    dispatch(getMainPost());
  }, [dispatch]);

  console.log("Group render");

  return (
    <div>
      <div>Group:</div>
      board: {mainPost.board}
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
