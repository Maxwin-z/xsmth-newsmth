import React from "react";

export default function PostGroup() {
  const onClick = () => {
    console.log("clicked");
    window.$x.sendMessage("foo", { code: 0 }, ret => {
      console.log(ret);
    });
  };
  return (
    <div>
      <h1>PostGroup</h1>
      <button onClick={onClick}>Send Message</button>
    </div>
  );
}
