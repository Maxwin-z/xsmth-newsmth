import React, { useState, useEffect, FunctionComponent } from "react";
import { postInfo } from "../jsbridge";
import { parseUrl, fetchPostGroup } from "./postUtils";
import { Post, PostGroup } from "./types";
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

const PostList: FunctionComponent<{ posts?: Post[] }> = ({ posts = [] }) => {
  return (
    <div>
      {posts.map(post => (
        <div className="post" key={post.pid}>
          {post.content}
        </div>
      ))}
    </div>
  );
};

export default function PostGroupPage() {
  let maxPage = 0;
  const postsPerPage = 10;
  const [mainPost, setMainPost] = useState<Post>({ isSingle: false });
  const [pages, setPages] = useState<Page[]>([]);
  const [title, setTitle] = useState("");
  const [pageLoading, setPageLoading] = useState(true);
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
  async function main() {
    let post: Post = await postInfo();
    if (post.url) {
      post = parseUrl(post.url);
    }
    console.log("postinfo: ", post);
    setMainPost(post);
  }

  async function renderFirstPage() {
    const page = await loadPage(1);
    if (page.status === Status.fail) {
      setPageLoadError(page.errorMessage!);
      return;
    }
    setTitle(page.title);
    // init
    maxPage = Math.max(maxPage, page.index);
    const totalPage = Math.ceil(page.total / postsPerPage);
    const _pages: Page[] = new Array(totalPage).fill(0).map((_, i) => ({
      title: "",
      total: page.total,
      index: i,
      posts: [],
      status: Status.init
    }));
    _pages[0] = page;
    setPages(_pages);
  }

  useEffect(() => {
    main();
  }, []);

  useEffect(() => {
    console.log("mainPost:", mainPost);
    mainPost.gid && renderFirstPage();
  }, [mainPost]);

  return (
    <div>
      <h1>PostGroup {"1" + new Date()}</h1>
      {pageLoading ? <div>Loading</div> : null}
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
            {page.status === Status.init && page.index < maxPage ? (
              <div>click to load</div>
            ) : null}
          </div>
        ))}
      </div>
      <div>footer</div>
    </div>
  );
}
