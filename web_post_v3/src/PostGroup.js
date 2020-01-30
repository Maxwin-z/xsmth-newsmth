import React from "react";

export default function PostGroup() {
  const onClick = () => {
    console.log("clicked");
    /*
    window.$x.sendMessage(
      "ajax",
      {
        url:
          "https://www.newsmth.net/nForum/fav/0.json?_t=" +
          new Date().getTime(),
        headers: {
          "X-Requested-With": "XMLHttpRequest"
        }
      },
      ret => {
        console.log(ret);
      }
    );
    */

    window.$x.sendMessage(
      "ajax",
      {
        url: "https://m.newsmth.net"
      },
      ret => {
        console.log(ret);
      }
    );
  };
  return (
    <div>
      <h1>PostGroup {"" + new Date()}</h1>
      <button onClick={onClick}>Send Message</button>
    </div>
  );
}
