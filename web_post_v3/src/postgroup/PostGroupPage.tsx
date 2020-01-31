import React, { useState, useEffect } from "react";
import { postInfo } from "../jsbridge";
import { parseUrl, fetchPostGroup } from "./postUtils";
import { Post, PostGroup } from "./types";

export default function PostGroupPage() {
  const [entryPost, setEntryPost] = useState<Post>({ isSingle: false });
  const [pageLoading, setPageLoading] = useState(true);

  async function main() {
    let post: Post = await postInfo();
    const url = post.url;
    post = parseUrl(url!);
    setEntryPost(post);
    console.log(post);
    const postGroup = await fetchPostGroup(post.board!, post.gid!, 1, null);
    console.log(postGroup);
    // fetchPostGroup("Test", 939423);
  }

  useEffect(() => {
    main();
  }, []);

  return (
    <div>
      <h1>PostGroup {"1" + new Date()}</h1>
      {pageLoading ? <div>Loading</div> : <div>Posts</div>}
    </div>
  );
}
