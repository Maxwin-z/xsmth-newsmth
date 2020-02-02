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
  console.log("get post html", html);
  return retrieveGroupPosts(html);
}

function cleanHtml(html: string): string {
  return html
    .replace(/<script.*?<\/script>/gi, "")
    .replace(/<style.*?<\/style>/gi, "")
    .replace(/<style.*?>/gi, "")
    .replace(/<img .+?>/gi, "");
}

export function retrieveGroupPosts(html: string): PostGroup {
  html = cleanHtml(html);
  const div = document.createElement("div");
  div.innerHTML = html;
  const title = (div.querySelector(
    ".b-head .n-left"
  ) as HTMLSpanElement).innerText.replace("文章主题: ", "");
  const total = parseInt(
    (div.querySelector(".pagination i") as HTMLElement).innerText || "0",
    10
  );
  const posts = [].slice
    .call(div.querySelectorAll("table.article"))
    .map((table: HTMLTableElement) => {
      const author = (table.querySelector(".a-head a") as HTMLAnchorElement)
        .innerText;
      const pid = parseInt(
        (table.querySelector("a.a-post") as HTMLAnchorElement).href
          .split("/")
          .pop() || "0",
        10
      );
      const body = table.querySelector(".a-content > p")?.innerHTML || "";
      const { date, content } = formatPost(body);
      return {
        author,
        pid,
        date,
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
/*
const s = `发信人: vovomoon (vovomoon), 信区: Divorce <br> 标&nbsp;&nbsp;题: 十几万能养个什么档次的小三？ <br> 发信站: 水木社区 (Fri Jan 31 21:15:07 2020), 站内 <br>&nbsp;&nbsp;<br> 我老公每年都有十几万去向不明。 <br> 今天我要查账，看到底汇给谁了。他输入密码居然全部错误。然后就登陆不了了，说是去银行才行。 <br> 感觉他故意的不想让我看。 <br> ——————— <br> 为什么我每次发文都上十大，能不能不上十大 <br> ——————— <br> 更新：我想明白了，应该不是嫖妓，应该真是包小三了。我查过他信用卡，很多次吃饭的记录。（这十几万是一次性提取的，吃饭都是用的他月薪吃的。所以他不攒钱，每个月2万全部花光），有时候信用卡还不上还要找我倒一下。我记得他一个同事有次说XX（我老公名字）都是回家吃饭的吧？可我老公从不回家吃饭，对我号称都是公司加班的。加班应该也是真的，只是吃饭估计跟女人吃了。而且有时候周末也会出去约朋友吃饭，这年龄都有家有口的，谁那么多时间总跟他吃饭！信用卡上好多吃饭记录，一次三四百的，少的二百。估计是约女人吃了 <br> -- <br> <font class="f006">※ 修改:·vovomoon 于 Feb&nbsp;&nbsp;1 10:36:39 2020 修改本文·[FROM: 61.149.198.*]</font><font class="f000"> <br> </font><font class="f000"></font><font class="f002">※ 来源:·水木社区 <a target="_blank" href="http://m.newsmth.net">http://m.newsmth.net</a>·[FROM: 61.149.198.*]</font><font class="f000"> <br> </font>`;
*/
function formatPost(
  body: string
): {
  date: number;
  content: string;
} {
  const dateRegex = /^发信人:.+?<br> 标.+?<br> 发信站:.+?\([A-Z][a-z]{2} +([A-Z][a-z]{2} +\d+ +\d{1,2}:\d{1,2}:\d{1,2} +\d{4})\)/;
  let matches = body.match(dateRegex);
  let date = 0;
  if (matches) {
    date = Date.parse(matches[1]);
  }
  // 移除顶部4行
  let content = body.replace(
    /^发信人:.+?<br> 标.+?<br> 发信站:.+?站内 <br>&nbsp;&nbsp;<br>/i,
    ""
  );
  // replace images
  content = content.replace(/<img .+?>/gi, "");
  return {
    date,
    content
  };
}
