import { Json } from "../index.d";
import { Post } from "./postgroup.d";
import { ajax } from "../jsbridge";

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
) {
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
  console.log(html);
  return html;
}
