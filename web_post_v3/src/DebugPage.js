import React, { useState } from "react";

export default function DebugPage() {
  let his = [];
  try {
    his = JSON.parse(localStorage.getItem("raw_history")) || [];
  } catch (ignore) {}
  console.log(his);
  const [html, setHTML] = useState("");
  const [rawHistory, setRawHistory] = useState(his);
  const [rawHtml, setRawHTML] = useState("");
  function transform() {
    // save to history
    const newHis = [...rawHistory];
    newHis.push(rawHtml);
    if (newHis.length > 10) {
      newHis.unshift();
    }
    setRawHistory(newHis);
    localStorage.setItem("raw_history", JSON.stringify(newHis));

    // trans
    const body = rawHtml.replace(/<script.*?<\/script>/g, "");
    setHTML(body);
  }
  return (
    <div>
      <div>
        <select onChange={e => setRawHTML(rawHistory[e.target.value])}>
          <option value="0">--</option>
          {rawHistory.map((html, i) => (
            <option key={Math.random()} value={i}>
              {html.substring(0, 100)}
            </option>
          ))}
        </select>
        <textarea
          style={{ width: "90vw", height: "600px" }}
          onChange={e => setRawHTML(e.target.value)}
          value={rawHtml}
        ></textarea>
      </div>
      <div>
        <button onClick={transform}>Transform</button>
      </div>
      <hr />
      <div
        style={{ border: "1px solid red" }}
        dangerouslySetInnerHTML={{ __html: html }}
      ></div>
    </div>
  );
}
