import React, { useState, useEffect } from "react";
import * as $x from "../jsbridge";
/**
 * 一些关键数据
 * board: 版面的英文名，如“Apple”
 * bid: board id，如Apple版bid为719
 * post: 帖子
 * pid: post_id，xsmth定义的属性，用于唯一表示一个帖子。水木直接使用的id
 * gid: group_id，同主题阅读的id，这个id是一楼帖子的pid。水木应该是便于区分，取别名为gid
 * au: author，作者
 * p: page，页码
 *
 * 同主题链接案例：
 * http://m.newsmth.net/article/Divorce/1557529?p=2&au=pmps
 * http://www.newsmth.net/nForum/article/Divorce/1557529?ajax&p=2&au=pmps
 *
 * regex:
 * m.newsmth.net            /article/[board]/[gid]?p=[page]&au=[author]
 * www.newsmth.net/nForum   /article/[board]/[gid]?ajax&p=[page]&au=[author]
 *
 * **************************************************************
 * // 单个帖子特有数据
 * replay_id: 被回复的帖子id，用于溯源
 * previous_id: 上一篇
 * next_id: 下一篇
 * threads_previous_id: 同主题上一篇
 * threads_next_id: 同主题下一篇
 *
 *
 *
 *
 * 单贴链接案例：
 * http://m.newsmth.net/article/AutoWorld/single/1943009563/0
 * http://www.newsmth.net/nForum/article/AutoWorld/ajax_single/1943009563.json
 *
 * regex:
 * m.newsmth.net            /article/[board]/single/[pid]/0
 * www.newsmth.net/nForum   /article/[board]/ajax_single/[pid].json
 *
 * 当前帖子展开，依赖如下链接：链接会返回：location:/article/[board]/[gid]?p=2#a15，包含了楼主信息、页码和位置
 * http://www.newsmth.net/nForum/article/[board]/[gid]?s=[pid]
 * m.newsmth.net也有”展开“，不过采用的是HTTP 302，为了简化工作，暂不采用
 */

async function main() {
  const postInfo = await $x.postInfo();
  console.log(postInfo);
}

export default function PostGroup() {
  const [pageLoading, setPageLoading] = useState(true);

  useEffect(() => {
    main();
  });
  return (
    <div>
      <h1>PostGroup {"1" + new Date()}</h1>
      {pageLoading ? <div>Loading</div> : <div>Posts</div>}
    </div>
  );
}
