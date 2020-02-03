import React, { useState, useEffect, FunctionComponent } from "react";
import { postInfo } from "../jsbridge";
import { parseUrl, fetchPostGroup } from "./postUtils";
import { Post } from "./types";
import "./index.css";

enum Status {
  init,
  loading,
  success,
  incomplete,
  fail
}

interface Page {
  title: string;
  total: number;
  index: number;
  posts: Post[];
  status: Status;
  errorMessage?: string;
}

const PostList: FunctionComponent<{ posts: Post[] }> = ({ posts = [] }) => {
  return (
    <div>
      {posts.map(post => (
        <div className="post" key={post.pid}>
          <div>
            {post.author}
            {post.nickname!.length > 0 ? `(${post.nickname})` : ``}
            {new Date(post.date!).toString()}
            {post.floor}
          </div>
          <div dangerouslySetInnerHTML={{ __html: post.content || "" }}></div>
        </div>
      ))}
    </div>
  );
};

export default function PostGroupPage() {
  const postsPerPage = 10;
  // const taskQueue: number[] = [];

  // let incompletePageNumber = 1;
  const [incompletePageNumber, setIncompletePageNumber] = useState(1);
  const [taskQueue, setTaskQueue] = useState<number[]>([]);
  const [mainPost, setMainPost] = useState<Post>({ isSingle: false });
  const [pages, setPages] = useState<Page[]>([
    {
      title: "",
      total: 0,
      index: 1,
      posts: [],
      status: Status.init
    }
  ]);
  const [title, setTitle] = useState("");
  const [pageLoading, setPageLoading] = useState(false);
  const [pageLoadError, setPageLoadError] = useState("");

  async function loadPage(p: number = 1, author?: string): Promise<Page> {
    const page: Page = {
      title: "",
      total: 0,
      index: p,
      posts: [],
      status: Status.init,
      errorMessage: ""
    };
    try {
      const postGroup = await fetchPostGroup(
        mainPost.board!,
        mainPost.gid!,
        p,
        null
      );
      page.posts = postGroup.posts!;
      page.total = postGroup.total!;
      page.title = postGroup.title!;
      page.status =
        page.posts.length >= postsPerPage ? Status.success : Status.incomplete;
    } catch (e) {
      page.status = Status.fail;
      page.errorMessage = e.toString();
    }
    return page;
  }

  async function loadIncompletePage() {
    taskQueue.unshift(incompletePageNumber);
    nextTask();
  }
  async function nextTask() {
    if (taskQueue.length === 0 || pageLoading) return;
    const _pages = [...pages];
    const p = taskQueue[0];
    console.log(`load page ${p}`, pages);

    // change page to loading status
    _pages[p! - 1]!.status = Status.loading;
    setPageLoading(true);
    setPages([..._pages]);

    const page = await loadPage(p);
    if (page.status === Status.fail) {
      console.log("load page error", page);
      return;
    }
    // load success
    if (p === 1) {
      setTitle(page.title);
    }

    const totalPage = Math.ceil(page.total / postsPerPage);
    // put unloaded pages to queue
    for (let i = pages.length + 1; i <= totalPage; ++i) {
      taskQueue.push(i);
      _pages.push({
        title: "",
        total: 0,
        index: i,
        posts: [],
        status: Status.init
      });
    }
    _pages[p! - 1] = page;
    setPages([..._pages]);

    // set last page always incomplete, try to load new posts
    // incompletePageNumber = totalPage;
    setIncompletePageNumber(totalPage);

    // remove current page, task done
    taskQueue.shift();
    setTaskQueue(taskQueue);
    setPageLoading(false);
  }

  // get post info
  useEffect(() => {
    async function main() {
      let post: Post = await postInfo();
      if (post.url) {
        post = parseUrl(post.url);
      }
      console.log("postinfo: ", post);
      setMainPost(post);
    }
    main();
  }, []);

  useEffect(() => {
    console.log("mainpost change");
    mainPost.board && mainPost.gid && loadIncompletePage();
  }, [mainPost]);

  useEffect(() => {
    console.log(`pages changed, ${pages.length}`);
  }, [pages]);

  // useEffect(() => {
  //   if (!pageLoading && mainPost.board && mainPost.gid) {
  //     setTimeout(nextTask, 3000);
  //   }
  // }, [pageLoading]);

  useEffect(() => {
    function handleScroll(e: Event) {
      console.log("scroll: ", e);
    }
    document.addEventListener("scroll", handleScroll);
    return () => document.removeEventListener("scroll", handleScroll);
  });

  return (
    <div>
      <h1>PostGroup {"33" + new Date()}</h1>
      <h1>{title}</h1>
      <div>{pageLoadError}</div>
      <div className="page-list">
        {pages.map(page => (
          <div className="page" key={`${page.index}-${page.status}`}>
            {page.status === Status.success ||
            page.status === Status.incomplete ? (
              <PostList posts={page.posts} />
            ) : null}
            {page.status === Status.fail ? (
              <div>{page.errorMessage}</div>
            ) : null}
            {page.status === Status.loading ? <div>Loading</div> : null}
          </div>
        ))}
      </div>
      <div>footer</div>
    </div>
  );
}
