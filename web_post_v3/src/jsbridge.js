window.$x = (function() {
  const callbacks = [];
  const nope = () => {};
  function sendMessage(methodName, parameters, callback) {
    callback = callback || nope;
    parameters = parameters || {};
    callbacks.push(callback);
    const message = {
      methodName,
      parameters,
      callbackID: callbacks.length - 1
    };
    window.webkit.messageHandlers.nativeBridge.postMessage(message);
  }
  return {
    sendMessage
  };
})();
