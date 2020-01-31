const callbacks: Array<Function> = [];

interface BridgeResult {
  code: number;
  data: any;
  message: string;
}

interface RequestHeader {
  "X-Requested-With": string;
}

interface AjaxOption {
  url: string;
  method: string;
  data: Object;
  headers: RequestHeader;
  withXhr: boolean;
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

interface PostInfo {
  url: string;
  board: string;
  gid: number;
  pid: number;
}

export function postInfo(): Promise<PostInfo> {
  return sendMessage("postInfo");
}

export function ajax({ url, method, data, headers, withXhr }: AjaxOption) {
  method = method || "GET";
  data = data || {};
  headers = headers || {};
  if (withXhr) {
    // just for newsmth/nForum
    headers["X-Requested-With"] = "XMLHttpRequest";
  }
  return sendMessage("ajax", {
    url,
    method,
    data,
    headers
  });
}
