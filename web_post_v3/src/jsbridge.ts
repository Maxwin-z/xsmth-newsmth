import { Json } from "./index.d";
import { Post } from "./postgroup/types.d";

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
  withXhr?: boolean;
}

interface Window {
  webkit?: any;
  $xCallback: Function;
}

declare let window: Window;

window.$xCallback = function(callbackID: number, rsp: BridgeResult) {
  if (callbacks[callbackID]) {
    callbacks[callbackID](rsp);
  } else {
    console.error(`callbackID ${callbackID} not exists`);
  }
  delete callbacks[callbackID];
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

export function postInfo(): Promise<Post> {
  if (!isBridgeAvaiable()) {
    return postInfoInWeb();
  }
  return sendMessage("postInfo");
}

export function ajax({
  url,
  method = "GET",
  data = {},
  headers = {},
  withXhr = false
}: AjaxOption): Promise<string> {
  if (withXhr) {
    // just for newsmth/nForum
    headers["X-Requested-With"] = "XMLHttpRequest";
  }
  const _url = new URL(url);
  Object.keys(data).forEach(key => {
    _url.searchParams.append(key, "" + data[key]);
  });
  // debug, disable cache
  _url.searchParams.append("_xsmth_disable_cache", "" + new Date().getTime());

  console.log(_url.toString());

  if (!isBridgeAvaiable()) {
    return ajaxInWeb({
      url: _url.toString(),
      withXhr
    });
  }

  return sendMessage("ajax", {
    url: _url.toString(),
    method,
    data,
    headers
  });
}

function postInfoInWeb(): Promise<Post> {
  return Promise.resolve({
    board: "DigiHome" || "WorkLife",
    gid: 941251 || 2164300
  });
}

async function ajaxInWeb({
  url,
  withXhr = false
}: AjaxOption): Promise<string> {
  console.log("ajax in web");
  const rsp = await fetch("/api", {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      url,
      withXhr
    })
  });
  console.log(rsp);
  return Promise.resolve(rsp.text());
}
