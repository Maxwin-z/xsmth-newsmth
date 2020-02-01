import React, { useState } from "react";
import * as $x from "./jsbridge";

export default function BridgeTest() {
  const [log, setLog] = useState("");
  const methods = {
    ajaxUTF8: async () => {
      return await $x.ajax({
        url: "https://m.newsmth.net"
      });
    },
    ajaxGBK: async () => {
      return await $x.ajax({
        url: "http://www.newsmth.net/nForum/#!mainpage"
      });
    },
    ajaxNForumJSON: async () => {
      return await $x.ajax({
        url: "https://www.newsmth.net/nForum/fav/0.json",
        withXhr: true
      });
    },
    postInfo: async () => {
      return await $x.postInfo();
    }
  };
  const test = fn => async () => {
    setLog(`test ${fn}...`);
    try {
      const ret = await methods[fn]();
      setLog(`test ${fn} \nret: ${JSON.stringify(ret, true, 2)}`);
    } catch (e) {
      setLog(`test ${fn} \nerror: ${e}`);
    }
  };
  return (
    <div>
      <textarea
        style={{ width: "100vw" }}
        rows="10"
        placeholder="log"
        value={log}
        readOnly
      ></textarea>
      <ul>
        {Object.keys(methods).map(m => (
          <li key={m}>
            <button onClick={test(m)}>{m}</button>
          </li>
        ))}
      </ul>
    </div>
  );
}