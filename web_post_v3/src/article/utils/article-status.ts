import { Status, ArticleStatus } from "../types";

export function articleStatus(ss: Status[]) {
  let firstLoading = -1;
  let firstSuccess = -1;
  let firstFail = -1;
  let lastLoading = -1;
  let lastSuccess = -1;
  let lastFail = -1;
  for (let i = 0; i < ss.length; ++i) {
    if (ss[i] === Status.loading) {
      lastLoading = i;
      firstLoading === -1 && (firstLoading = i);
    }
    if (ss[i] === Status.success) {
      lastSuccess = i;
      firstSuccess === -1 && (firstSuccess = i);
    }
    if (ss[i] === Status.fail) {
      lastFail = i;
      firstFail === -1 && (firstFail = i);
    }
  }

  console.log("firstLoading", firstLoading);
  console.log("firstSuccess", firstSuccess);
  console.log("firstFail", firstFail);
  console.log("lastLoading", lastLoading);
  console.log("lastSuccess", lastSuccess);
  console.log("lastFail", lastFail);
  let articleStatus = ArticleStatus.allLoading;
  if (lastSuccess === -1 && lastFail === -1) {
    articleStatus = ArticleStatus.allLoading;
  } else if (firstLoading < lastSuccess || firstLoading < lastFail) {
    articleStatus = ArticleStatus.middlePageLoading;
  } else if (
    firstLoading === lastLoading &&
    lastLoading > lastSuccess &&
    lastLoading > lastFail
  ) {
    articleStatus = ArticleStatus.footerLoading;
  } else if (
    firstFail === lastFail &&
    lastFail > lastSuccess &&
    lastFail > lastLoading
  ) {
    articleStatus = ArticleStatus.footerFail;
  } else if (firstLoading === -1 && lastSuccess === ss.length - 1) {
    articleStatus = ArticleStatus.allSuccess;
  }
  return articleStatus;

  /*
  allLoading,
  middlePageLoading,
  footerLoading,
  footerFail,
  allFail,
  
  */
  const allLoading = ss.every(s => s === Status.init || s === Status.loading);
}
