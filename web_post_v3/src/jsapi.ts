import PubSub from "pubsub-js";
import { IMainPost, ITheme } from "./article/types";
import { IActionPost } from "./article/components/Post";

export interface Json {
  [x: string]: string | number | boolean | Date | Json | JsonArray;
}
export interface JsonArray
  extends Array<string | number | boolean | Date | Json | JsonArray> {}

const callbacks: Array<Function> = [];

interface BridgeResult {
  code: number;
  data: any;
  message: string;
}

interface AjaxOption {
  url: string;
  method?: string;
  data?: Json;
  headers?: Json;
  encoding?: string | null;
}

interface Window {
  webkit?: any;
  $xCallback: Function;
  $x_parseForward: Function;
  $x_pageWillUnload: Function;
  $x_publish: Function;
  scrollBy: Function;
}

declare let window: Window;

window.$xCallback = function (callbackID: number, rsp: BridgeResult) {
  // console.log("$xCallback", callbackID, rsp);
  if (callbacks[callbackID]) {
    callbacks[callbackID](rsp);
  } else {
    console.error(`callbackID ${callbackID} not exists`);
  }
  delete callbacks[callbackID];
};

window.$x_parseForward = function (html: string) {
  const matches = html
    .replace(/<script.*?<\/script>/g, "")
    .match(/<body>(.*?)<\/body>/);
  if (matches) {
    const body = matches[1];

    const div = document.createElement("div");
    div.innerHTML = body;
    const text = (div.querySelector(".menu.sp") as HTMLDivElement).innerText;
    if (text && text.indexOf("发生错误") !== -1) {
      const msg = (div.querySelector(".sp.hl.f") as HTMLDivElement).innerText;
      return msg || "0";
    }
    return "1";
  }
  return "水木未返回是否成功";
};

window.$x_publish = function (message: string, data: number | string | Json) {
  PubSub.publish(message, data);
};

function isBridgeAvaiable() {
  return (
    window.webkit &&
    window.webkit.messageHandlers &&
    window.webkit.messageHandlers.nativeBridge
  );
}

function sendMessage(methodName: string, parameters?: any): Promise<any> {
  return new Promise((resolve, reject) => {
    parameters = parameters || {};
    const cb = ({ code, data, message }: BridgeResult) => {
      if (code === 0) {
        resolve(data);
      } else {
        reject(message);
      }
    };
    callbacks.push(cb);
    const message = {
      methodName,
      parameters,
      callbackID: callbacks.length - 1
    };
    if (isBridgeAvaiable()) {
      window.webkit.messageHandlers.nativeBridge.postMessage(message);
    }
  });
}

export function postInfo(): Promise<IMainPost> {
  if (!isBridgeAvaiable()) {
    return postInfoInWeb();
  }
  return sendMessage("postInfo");
}

export function reply(post: IActionPost): Promise<boolean> {
  return sendMessage("reply", post);
}

export function ajax({
  url,
  method = "GET",
  data = {},
  headers = {},
  encoding = null
}: AjaxOption): Promise<string> {
  const _url = new URL(url);
  Object.keys(data).forEach(key => {
    _url.searchParams.append(key, "" + data[key]);
  });
  // debug, disable cache
  // _url.searchParams.append("_xsmth_disable_cache", "" + new Date().getTime());

  console.log(_url.toString());

  if (!isBridgeAvaiable()) {
    return ajaxInWeb({
      url: _url.toString(),
      headers
    });
  }

  let u = _url.toString();
  // if (Math.random() < 0.5) {
  //   u = "_";
  // }
  return sendMessage("ajax", {
    url: u,
    method,
    data,
    headers,
    encoding
  });
}

function postInfoInWeb(): Promise<IMainPost> {
  // let post = { board: "Children", gid: 932484268 };
  // let post = { board: "Photo", gid: 1936720334, title: "" }; // 1 page
  let post = {
    board: "Photo",
    gid: 1936720211,
    title: "",
    pid: 0,
    single: false
  }; // 2 pages
  // let post = {board: 'DigiHome', gid: 941251}
  // let post = { board: "WorkLife", gid: 2164300 , title: ''}; // 20+ pages
  return Promise.resolve(post);
}

async function ajaxInWeb({ url, headers = {} }: AjaxOption): Promise<string> {
  console.log("ajax in web");
  const rsp = await fetch("/api", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      ...headers
    },
    body: JSON.stringify({
      url,
      headers
    })
  });
  console.log(rsp);
  return Promise.resolve(rsp.text());
}

export function showActivity(post: IActionPost): Promise<boolean> {
  return sendMessage("activity", post);
}

export function setTitle(title: string): Promise<boolean> {
  return sendMessage("setTitle", title);
}

export enum ToastType {
  success = 0,
  error = 1,
  info = 4
}

interface Toast {
  message: string;
  type?: ToastType;
}
export function toast(toast: Toast): Promise<boolean> {
  if (toast.type === undefined) {
    toast.type = ToastType.info;
  }
  return sendMessage("toast", toast);
}

export function xLog(msg: string): Promise<boolean> {
  console.log("xLog", msg);
  return sendMessage("log", msg);
}

export function unloaded(): Promise<boolean> {
  return sendMessage("unloaded");
}

export function download(url: string, id: number = 0): Promise<boolean> {
  return sendMessage("download", {
    id,
    url
  });
}

export function login(): Promise<boolean> {
  return sendMessage("login");
}

export function pageNumberChanged(
  page: Number,
  total: Number
): Promise<boolean> {
  return sendMessage("pageNumberChanged", {
    page,
    total
  });
}

export function getThemeConfig(): Promise<ITheme> {
  return sendMessage("getThemeConfig");
}

export function setStorage(key: string, value: any): Promise<boolean> {
  if (!isBridgeAvaiable()) {
    localStorage.setItem(key, JSON.stringify({ data: value }));
    return Promise.resolve(true);
  }
  return sendMessage("setStorage", {
    key,
    value
  });
}

export function getStorage(key: string): Promise<any> {
  if (!isBridgeAvaiable()) {
    try {
      const json = JSON.parse(localStorage.getItem(key) || "{data: null}");
      return Promise.resolve(json["data"]);
    } catch (e) {}
  }

  return sendMessage("getStorage", key);
}

export function removeStorage(key: string): Promise<boolean> {
  return sendMessage("removeStorage", key);
}

export function xScrollTo(x: number, y: number): Promise<boolean> {
  return sendMessage("scrollTo", { x, y });
}

export function xScrollBy(x: number, y: number): Promise<boolean> {
  if (!isBridgeAvaiable()) {
    return window.scrollBy(x, y);
  }
  return sendMessage("scrollBy", { x, y });
}
export enum ModalStyle {
  automatic,
  formSheet
}
export function xOpen(
  opts: string | { url: string; type: ModalStyle }
): Promise<boolean> {
  let url, type;

  if (typeof opts === "string") {
    url = opts;
    type = ModalStyle.automatic;
  } else {
    url = opts.url;
    type = opts.type;
  }
  return sendMessage("open", {
    url,
    type
  });
}
