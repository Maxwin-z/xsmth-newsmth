import { Json } from "../../jsapi";

export function getQuery() {
  const hash = window.location.hash;
  const queryString = hash.split("?")[1] || "";
  const query: { [x: string]: string } = {};
  queryString.split("&").forEach(item => {
    const [k, v] = item.split("=");
    if (k) {
      query[k] = decodeURIComponent(v || "");
    }
  });
  return query;
}
