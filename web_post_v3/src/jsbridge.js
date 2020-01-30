window.$x = (function() {
  const callbacks = [];
  function callback(callbackID, rsp) {
    callbacks[callbackID](rsp);
    delete callbacks[callbackID];
  }
  function sendMessage(methodName, parameters) {
    return new Promise((resolve, reject) => {
      parameters = parameters || {};
      const cb = ({ code, data, message }) => {
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
      window.webkit.messageHandlers.nativeBridge.postMessage(message);
    });
  }

  function ajax({ url, method, data, headers, withXhr }) {
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

  return {
    callback,
    ajax
  };
})();
