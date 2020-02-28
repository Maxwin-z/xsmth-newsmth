import { isErrorPage, retrieveGroupPosts, formatPost, cleanHtml } from "./post";
import { IPost, IGroup } from "../types";
import { ajax } from "./jsapi";
export class GroupTask {
  board: string;
  gid: number;
  page: number;
  resolve?: ((value: IGroup) => void) | null;
  reject?: ((reason?: any) => void) | null;
  constructor(board: string, gid: number, page: number = 1) {
    this.board = board;
    this.gid = gid;
    this.page = page;
  }

  execute(): Promise<IGroup> {
    return new Promise(async (resolve, reject) => {
      this.reject = reject;
      // await delay(3000);
      const html = await ajax({
        url: `https://www.newsmth.net/nForum/article/${this.board}/${this.gid}?ajax&p=${this.page}`,
        headers: {
          "X-Requested-With": "XMLHttpRequest"
        }
      });
      const error = isErrorPage(html);
      if (error) {
        reject(error);
        this.reject = null;
      }
      resolve(retrieveGroupPosts(html, this.page));
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
      const html = await ajax({
        url: `https://www.newsmth.net/nForum/article/${this.board}/ajax_single/${this.pid}.json`,
        headers: {
          "X-Requested-With": "XMLHttpRequest"
        }
      });
      let data = JSON.parse(html);
      (data.content as string).match(/.{1,100}/g)?.forEach(v => console.log(v));
      data = { ...data, ...formatPost(cleanHtml(data.content)) };
      const post: IPost = {
        board: data["board_name"],
        gid: data["group_id"],
        pid: data["id"],
        title: data["title"],
        author: data["user"]["id"],
        nick: data["user"]["user_name"],
        floor: -1,
        date: data["date"],
        dateString: data["dateString"],
        content: data["content"],
        images: data.images,
        isSingle: true
      };
      resolve(post);
    });
  }

  cancel() {
    if (this.reject) {
      this.reject("request cancel");
      this.reject = null;
    }
  }
}
