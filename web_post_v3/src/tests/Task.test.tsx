import React from "react";
import { GroupTask, PostTask } from "../article/utils/Task";
import "./test.css";
export default function TaskTest() {
  let task: GroupTask;
  let postTask: PostTask;

  async function click() {
    task = new GroupTask("WorkLife", 2177468, 2);
    const postgroup = await task.execute();
    console.log(postgroup);
  }
  async function click2() {
    // postTask = new PostTask("WorkLife", 2177468);
    postTask = new PostTask("Picture", 2185856);
    const post = await postTask.execute();
    console.log(post);
  }

  function cancel() {
    task && task.cancel();
    postTask && postTask.cancel();
  }
  return (
    <div>
      <button onClick={click}>fetch posts</button>
      <button onClick={click2}>fetch post</button>
      <button onClick={cancel}>cancel</button>
    </div>
  );
}
