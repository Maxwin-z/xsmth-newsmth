import { IGroup, IXImage, Status, ILike } from "../types";
import { getStorage, ajax, setStorage } from "../../jsapi";

let imageID = 0;
export const POST_PER_PAGE = 10;

export function delay(t: number) {
  return new Promise(rs => {
    setTimeout(rs, t);
  });
}

export function cleanHtml(html: string): string {
  return html
    .replace(/<script.*?<\/script>/gi, "")
    .replace(/<style.*?<\/style>/gi, "")
    .replace(/<style.*?>/gi, "")
    .replace(/<img/gi, "<ximg");
}

export function isErrorPage(html: string) {
  // 论坛信息错误
  if (html.indexOf(`$.setTitle('水木社区-错误信息');;</script>`) !== -1) {
    return retrieveErrorMessage(html);
  }
  return null;
}

function retrieveErrorMessage(html: string) {
  html = cleanHtml(html);
  const div = document.createElement("div");
  div.innerHTML = html;
  return (div.querySelector(".error li") as HTMLLIElement)?.innerText;
}

export function retrieveGroupPosts(html: string, page: number): IGroup {
  html = cleanHtml(html);
  const div = document.createElement("div");
  div.innerHTML = html;
  const title = (div.querySelector(
    ".b-head .n-left"
  ) as HTMLSpanElement).innerText.replace("文章主题: ", "");
  const totalPosts = parseInt(
    (div.querySelector(".pagination i") as HTMLElement).innerText || "0",
    10
  );
  const total = Math.ceil(totalPosts / 10);
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
      const floorText = (table.querySelector(".a-pos") as HTMLSpanElement)
        .innerText;
      const floor =
        floorText === "楼主"
          ? 0
          : parseInt(floorText.replace(/(第|楼)/, ""), 10);
      let postCount = -1;
      let score = -1;
      const dts = table.querySelectorAll(".a-u-info dt");
      const dds = table.querySelectorAll(".a-u-info dd");
      for (let i = 0; i < dts.length; ++i) {
        if ((dts[i] as HTMLDataElement).innerText === "文章") {
          postCount = parseInt((dds[i] as HTMLDetailsElement).innerText, 10);
        }
        if ((dts[i] as HTMLDataElement).innerText === "积分") {
          score = parseInt((dds[i] as HTMLDetailsElement).innerText, 10);
        }
      }
      const body = table.querySelector(".a-content > p")?.innerHTML || "";
      const { date, dateString, nick, content, images } = formatPost(body);
      const likesDom = table.querySelector(".likes") as HTMLElement;
      const likes = formatLikes(likesDom);
      return {
        author,
        nick,
        postCount,
        score,
        floor,
        pid,
        date,
        dateString,
        content,
        images,
        isSingle: false,
        likes
      };
    });

  return {
    title,
    total,
    p: page,
    posts
  };
}
/*
const s = `发信人: vovomoon (vovomoonx), 信区: Divorce <br ?\/?> 标&nbsp;&nbsp;题: 十几万能养个什么档次的小三？ <br ?\/?> 发信站: 水木社区 (Fri Jan 31 21:15:07 2020), 站内 <br ?\/?>&nbsp;&nbsp;<br ?\/?> 我老公每年都有十几万去向不明。 <br ?\/?> 今天我要查账，看到底汇给谁了。他输入密码居然全部错误。然后就登陆不了了，说是去银行才行。 <br ?\/?> 感觉他故意的不想让我看。 <br ?\/?> ——————— <br ?\/?> 为什么我每次发文都上十大，能不能不上十大 <br ?\/?> ——————— <br ?\/?> 更新：我想明白了，应该不是嫖妓，应该真是包小三了。我查过他信用卡，很多次吃饭的记录。（这十几万是一次性提取的，吃饭都是用的他月薪吃的。所以他不攒钱，每个月2万全部花光），有时候信用卡还不上还要找我倒一下。我记得他一个同事有次说XX（我老公名字）都是回家吃饭的吧？可我老公从不回家吃饭，对我号称都是公司加班的。加班应该也是真的，只是吃饭估计跟女人吃了。而且有时候周末也会出去约朋友吃饭，这年龄都有家有口的，谁那么多时间总跟他吃饭！信用卡上好多吃饭记录，一次三四百的，少的二百。估计是约女人吃了 <br ?\/?> -- <br ?\/?> <font class="f006">※ 修改:·vovomoon 于 Feb&nbsp;&nbsp;1 10:36:39 2020 修改本文·[FROM: 61.149.198.*]</font><font class="f000"> <br ?\/?> </font><font class="f000"></font><font class="f002">※ 来源:·水木社区 <a target="_blank" href="http://m.mysmth.net">http://m.mysmth.net</a>·[FROM: 61.149.198.*]</font><font class="f000"> <br ?\/?> </font>`;
*/
export function formatPost(
  body: string
): {
  date: number;
  dateString: string;
  nick: string;
  content: string;
  images: IXImage[];
} {
  const dateRegex = /^发信人:.+?<br ?\/?> 标.+?<br ?\/?> 发信站:.+?\([A-Z][a-z]{2} ([A-Z][a-z]{2}( |&nbsp;&nbsp;)\d+ \d{1,2}:\d{1,2}:\d{1,2} +\d{4})\)/;
  let matches = body.match(dateRegex);
  let date = 0;
  let dateString = "";
  const images: IXImage[] = [];
  if (matches) {
    dateString = matches[1].replace(/&nbsp;/g, " ");
    date = Date.parse(dateString);
  }

  // get nick
  matches = body.match(/^发信人: \w+? \((.*?)\), /);
  const nick = matches ? matches[1] : "";

  // remove top 4 rows
  let content = body.replace(
    /^发信人:.+?<br ?\/?> 标.+?<br ?\/?> 发信站:.+?站内 <br ?\/?>&nbsp;&nbsp;<br ?\/?>/i,
    ""
  );

  // remove <a> around <img />
  content = content.replace(/<a .*?>(<ximg.+?>)<\/a>/g, "$1");
  // replace images
  const imageProtocol = "https:";
  content = content.replace(
    /<ximg.*? src="(.+?)".*?>/gi,
    (_: string, src: string) => {
      // if (src.indexOf("/nForum/img/ubb") === 0) {
      //   return `<img src="${imageProtocol}//www.mysmth.net${src}" />`;
      // }
      const id = ++imageID;
      src.indexOf("//") === 0 && (src = imageProtocol + src);
      src.indexOf("/nForum/") === 0 &&
        (src = imageProtocol + "//www.mysmth.net" + src);
      src = src.replace(/\/(small|middle|large)$/, "");
      images.push({
        id,
        src,
        status: Status.init
      });
      const isEmoji = src.indexOf("/nForum/img/ubb/") !== -1;
      const className = isEmoji ? "ximg-emoji" : "ximg-box";
      return `<div class="${className}">
        <span class="ximg-info" id="ximg-info-${id}">正在加载</span>
        <img src="${src}/middle" data-src="${src}" class="ximg" id="ximg-${id}" alt="图片" />
      </div>`;
    }
  );
  // remove ※ 来源:·水木社区 <font class="f013">※ 来源:·水木社区 newsmth.net·[FROM: 183.253.30.*]</font>
  content = content.replace(
    /<font class="f\w+">※ 来源:.+?\[FROM: .+?\]<\/font>/g,
    ""
  );
  // remove last <br ?\/?>
  content = content.replace('<font class="f000"> <br ?/?> </font>', "");
  content = content.replace(
    '<font class="f000"> <br ?/?>&nbsp;&nbsp;<br ?/?> </font>',
    ""
  );
  return {
    date,
    dateString,
    nick,
    content,
    images
  };
}

function formatLikes(dom: HTMLElement): Array<ILike> {
  if (!dom) {
    return [];
  }
  const likes = [].slice.call(dom.querySelectorAll("ul li")).map(
    (li: HTMLLIElement): ILike => {
      const score = parseInt(
        li
          .querySelector("span")!
          .innerText.replace(/[\[\]]/g, "")
          .trim() || "0",
        10
      );
      const user = li.querySelector("span.like_user")!.innerHTML.slice(0, -1);
      const message = li.querySelector("span.like_msg")!.innerHTML;
      const dateString = li
        .querySelector("span.like_time")!
        .innerHTML.replace(/(^\(|\)$)/g, "");
      return {
        score,
        user,
        message,
        dateString
      };
    }
  );
  return likes;
}

export async function getBoardID(board: string): Promise<number> {
  const key = `board_id_${board}`;
  let bid: number = 0;
  try {
    bid = await getStorage(key);
    return bid;
  } catch (ignore) {}

  const html = await ajax({
    url: `https://www.mysmth.net/bbsdoc.php?board=${board}`,
    encoding: "GBK"
  });
  const matches = html.match(/var c = new docWriter\('\w+?',(\d+),/);
  if (matches) {
    bid = parseInt(matches[1], 10);
    console.log("get bid", board, bid);
    await setStorage(key, bid);
    return bid;
  } else {
    console.error(`get bid fail`);
    logLongString(html);
  }
  return bid;
}

export function logLongString(str: string) {
  str.match(/.{1,100}/g)?.forEach(v => console.log(v));
}

/*
function fill0(v: number, length: number = 2): string {
  const s = "" + v;
  return s.length > length
    ? s
    : new Array(s.length - length).fill("0").join("") + s;
}

function formatDate(timestamp: number) {
  const d = new Date(timestamp);
  const year = "" + d.getFullYear();
  const month = fill0(d.getMonth() + 1);
  const date = fill0(d.getDate());
  const hour = fill0(d.getHours());
  const mins = fill0(d.getMinutes());
  const secs = fill0(d.getSeconds());
  return `${hour}:${mins}:${secs} ${month}-${date}-${year}`;
}
*/
