import { Json } from "../index.d";
import { Post, PostGroup } from "./types.d";
import { ajax } from "../jsbridge";

// import "./tests";

export function parseUrl(urlString: string): Post {
  const url = new URL(urlString);
  const params = url.pathname.split("/");
  // shift first element ""
  params.shift();
  if (params[0] === "nForum") {
    params.shift();
  }
  if (params[0] !== "article") {
    throw new Error(`invalid post url: ${url}`);
  }

  const board = params[1];
  let isSingle = false;
  let gid = 0;
  let pid = 0;

  if (params[2] === "single" || params[2] === "ajax_single") {
    // single post
    isSingle = true;
    pid = parseInt(params[3].replace(".json", ""), 10);
  } else {
    gid = pid = parseInt(params[2], 10);
  }

  return {
    url: urlString,
    board,
    gid,
    pid,
    isSingle
  };
}

export async function fetchPostGroup(
  board: string,
  gid: number,
  page: number = 1,
  author?: string | null
): Promise<PostGroup> {
  const data: Json = {};
  if (Number.isInteger(page) && page > 0) {
    data.p = page;
  }
  if (typeof author === "string") {
    data.au = author;
  }
  const html = await ajax({
    url: `https://www.newsmth.net/nForum/article/${board}/${gid}?ajax`,
    data,
    withXhr: true
  });
  return retrieveGroupPosts(html);
}

function cleanHtml(html: string): string {
  return html
    .replace(/<script.*?<\/script>/g, "")
    .replace(/<style.*?<\/style>/g, "")
    .replace(/<style.*?>/g, "");
}

export function retrieveGroupPosts(html: string): PostGroup {
  html = cleanHtml(html);
  const div = document.createElement("div");
  div.innerHTML = html;
  document.body.appendChild(div);
  const title = (document.querySelector(
    ".b-head .n-left"
  ) as HTMLSpanElement).innerText.replace("文章主题: ", "");
  const total = parseInt(
    (document.querySelector(".pagination i") as HTMLElement).innerText || "0",
    10
  );
  const posts = [].slice
    .call(document.querySelectorAll("table.article"))
    .map((table: HTMLTableElement) => {
      const author = (table.querySelector(".a-head a") as HTMLAnchorElement)
        .innerText;
      const pid = parseInt(
        (table.querySelector("a.a-post") as HTMLAnchorElement).href
          .split("/")
          .pop() || "0",
        10
      );
      const content = table.querySelector(".a-content > p")?.innerHTML || "";
      return {
        author,
        pid,
        content,
        isSingle: false
      };
    });

  return {
    title,
    total,
    posts
  };
}
