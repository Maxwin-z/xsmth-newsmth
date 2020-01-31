import { html } from "./test-data";
export {};
function cleanHtml(html: string): string {
  return html
    .replace(/<script.*?<\/script>/g, "")
    .replace(/<style.*?<\/style>/g, "")
    .replace(/<style.*?>/g, "");
}

function retrieveGroupPosts(html: string) {
  html = cleanHtml(html);
  const div = document.createElement("div");
  div.innerHTML = html;
  document.body.appendChild(div);
  const title = (document.querySelector(
    ".b-head .n-left"
  ) as HTMLSpanElement).innerText.replace("文章主题: ", "");
  const total = parseInt(
    (document.querySelector(".pagination i") as HTMLElement).innerText || "0",
    10
  );
  const posts = [].slice
    .call(document.querySelectorAll("table.article"))
    .map((table: HTMLTableElement) => {
      const author = (table.querySelector(".a-head a") as HTMLAnchorElement)
        .innerText;
      const pid = parseInt(
        (table.querySelector("a.a-post") as HTMLAnchorElement).href
          .split("/")
          .pop() || "0",
        10
      );
      const content = table.querySelector(".a-content > p")?.innerHTML;
      return {
        author,
        pid,
        content
      };
    });

  return {
    title,
    total,
    posts
  };
}
console.log(retrieveGroupPosts(html));
