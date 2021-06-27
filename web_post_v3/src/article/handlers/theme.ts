import { Json } from "../../jsapi";
import { ITheme } from "../types";

export function setupTheme(style: ITheme) {
  // console.log("styles", style);
  var sheet = document.styleSheets[0] as CSSStyleSheet;

  for (let i = sheet.rules.length - 1; i >= 0; --i) {
    sheet.deleteRule(i);
  }

  sheet.addRule(
    "body.xsmth",
    style2string({
      "background-color": style.bgColor,
      color: style.textColor,
      "font-family": style.fontFamily,
      "font-size": style.fontSize,
      "line-height": style.lineHeight
    }),
    0
  );

  sheet.addRule(
    ".f006",
    style2string({
      color: style.quoteColor
    }),
    0
  );

  sheet.addRule(
    "a",
    style2string({
      color: style.tintColor
    }),
    0
  );

  sheet.addRule(
    "div.post",
    style2string({
      // "border-top": "1px solid " + style.quoteColor
    }),
    0
  );

  sheet.addRule(
    ".tint-color",
    style2string({
      color: style.tintColor
    }),
    0
  );

  sheet.addRule(
    "div.post .action",
    style2string({
      color: style.tintColor,
      "border-color": style.tintColor,
      "background-color": style.bgColor
    }),
    0
  );

  document.body.className = "xsmth";
}

function style2string(styles: Json) {
  const res: string[] = [];
  Object.keys(styles).forEach(key => {
    const value = styles[key];
    res.push(key + ":" + value + ";");
  });
  return res.join("");
}
