import { Json } from "./index.d";
import { Post } from "./postgroup/postgroup.d";

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
  callbacks[callbackID](rsp);
  delete callbacks[callbackID];
};

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
    window.webkit &&
      window.webkit.messageHandlers &&
      window.webkit.messageHandlers.nativeBridge &&
      window.webkit.messageHandlers.nativeBridge.postMessage(message);
  });
}

export function postInfo(): Promise<Post> {
  return sendMessage("postInfo");
}

export function ajax({
  url,
  method = "GET",
  data = {},
  headers = {},
  withXhr = false
}: AjaxOption) {
  if (withXhr) {
    // just for newsmth/nForum
    headers["X-Requested-With"] = "XMLHttpRequest";
  }
  const _url = new URL(url);
  Object.keys(data).map(key => {
    _url.searchParams.append(key, "" + data[key]);
  });
  // debug, disable cache
  _url.searchParams.append("_xsmth_disable_cache", "" + new Date().getTime());

  console.log(_url.toString());

  return sendMessage("ajax", {
    url: _url.toString(),
    method,
    data,
    headers
  });
}
