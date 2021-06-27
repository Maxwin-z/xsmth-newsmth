import {
  isErrorPage,
  retrieveGroupPosts,
  formatPost,
  cleanHtml,
  logLongString
} from "./post";
import { IPost, IGroup } from "../types";
import { ajax, Json } from "../../jsapi";
export class GroupTask {
  board: string;
  gid: number;
  page: number;
  author: string | null;
  resolve?: ((value: IGroup) => void) | null;
  reject?: ((reason?: any) => void) | null;
  constructor(
    board: string,
    gid: number,
    page: number = 1,
    author: string = ""
  ) {
    this.board = board;
    this.gid = gid;
    this.page = page;
    this.author = author;
  }

  execute(): Promise<IGroup> {
    return new Promise(async (resolve, reject) => {
      this.reject = reject;
      // await delay(3000);
      try {
        const data: Json = {
          p: this.page
        };
        if (this.author) {
          data["au"] = this.author;
        }
        const html = await ajax({
          url: `https://www.mysmth.net/nForum/article/${this.board}/${this.gid}?ajax`,
          data,
          headers: {
            "X-Requested-With": "XMLHttpRequest"
          }
        });
        const error = isErrorPage(html);
        if (error) {
          reject(error);
          this.reject = null;
          return;
        }
        resolve(retrieveGroupPosts(html, this.page));
      } catch (e) {
        reject(e);
      }
    });
  }

  cancel() {
    if (this.reject) {
      this.reject("request cancel");
      this.reject = null;
    }
  }
}

export class PostTask {
  board: string;
  pid: number;
  reject?: ((reason?: any) => void) | null;
  constructor(board: string, pid: number) {
    this.board = board;
    this.pid = pid;
  }

  execute(): Promise<IPost> {
    return new Promise(async (resolve, reject) => {
      this.reject = reject;
      try {
        const html = await ajax({
          url: `https://www.mysmth.net/nForum/article/${this.board}/ajax_single/${this.pid}.json`,
          headers: {
            "X-Requested-With": "XMLHttpRequest"
          }
        });
        let data = JSON.parse(html);
        if (!data["id"] || !data["content"]) {
          return reject(data["ajax_msg"]);
        }
        logLongString(data.content);
        data = { ...data, ...formatPost(cleanHtml(data.content)) };
        const post: IPost = {
          board: data["board_name"],
          gid: data["group_id"],
          pid: data["id"],
          title: data["title"],
          author: data["user"]["id"],
          nick: data["user"]["user_name"],
          postCount: data["user"]["post_count"],
          score: data["user"]["score_user"],
          floor: -1,
          date: data["date"],
          dateString: data["dateString"],
          content: data["content"],
          images: data["images"],
          isSingle: true
        };
        resolve(post);
        this.reject = null;
      } catch (e) {
        reject(e);
      }
    });
  }

  cancel() {
    if (this.reject) {
      this.reject("request cancel");
      this.reject = null;
    }
  }
}
