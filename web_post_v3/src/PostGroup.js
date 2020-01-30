import React from "react";

export default function PostGroup() {
  const onClick = async () => {
    console.log("clicked");
    const ret = await window.$x.ajax({ url: "https://m.newsmth.net" });
    console.log("html:", ret);
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

    // window.$x.sendMessage(
    //   "ajax",
    //   {
    //     url: "https://m.newsmth.net"
    //   },
    //   ret => {
    //     console.log(ret);
    //   }
    // );
  };
  return (
    <div>
      <h1>PostGroup {"1" + new Date()}</h1>

      <button onClick={onClick}>Send Message</button>
      <button onClick={onClick}>Send Message</button>
    </div>
  );
}
