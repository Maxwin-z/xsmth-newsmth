import { Status, ArticleStatus } from "../article/types";
import { expect } from "chai";
import "mocha";
import { articleStatus } from "../article/utils/article-status";

function test(ss: Status[], status: ArticleStatus) {
  expect(articleStatus(ss)).to.equal(status);
}

const I = Status.init;
const L = Status.loading;
const S = Status.success;
const F = Status.fail;

/*
export enum ArticleStatus {
  allLoading,
  middlePageLoading,
  footerLoading,
  footerFail,
  allSuccess,
  allFail
}
*/

describe("ArticleStatus", () => {
  it("allLoading", () => {
    test([L, I, I, I], ArticleStatus.allLoading);
  });
  it("middlePageLoading", () => {
    test([S, S, I, L, I, S, I], ArticleStatus.middlePageLoading);
  });
  it("footerLoading", () => {
    test([S, S, L], ArticleStatus.footerLoading);
  });
  it("footerLoading", () => {
    test([S, S, L, I, I], ArticleStatus.footerLoading);
  });
  it("footerFail", () => {
    test([S, S, F], ArticleStatus.footerFail);
  });
  it("allLoading", () => {
    test([L, I, I, I], ArticleStatus.allLoading);
  });
});
