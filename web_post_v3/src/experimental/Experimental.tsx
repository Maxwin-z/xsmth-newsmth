import { FC, useEffect, useState } from "react";
import React from "react";
import { getQuery } from "../article/utils/urlHelper";
import { getStorage, setTitle } from "../jsapi";
import { RootState } from "../article";

import { YAxis, CartesianGrid, AreaChart, Area, Legend } from "recharts";

import "./experimental.css";

interface IUser {
  author: string;
  postCount: number;
  score: number;
  floor: number;
  count: number;
}

interface ICountMap {
  [author: string]: IUser;
}

setTitle("Experimental");

const Experimental: FC<{}> = () => {
  type UserKeys = "floor" | "count" | "postCount" | "score";

  const [title, setTitle] = useState("");
  const [author, setAuthor] = useState("");
  const [authorPostCount, setAuthorPostCount] = useState(0);
  const [postsCount, setPostsCount] = useState(0);
  const [users, setUsers] = useState<IUser[]>([]);
  const [lastSortKey, setLastSortKey] = useState<UserKeys>("floor");
  const [lastSortMethod, setLastSortMethod] = useState(1);

  useEffect(() => {
    async function main() {
      const query = getQuery();
      const board = query.board as string;
      const gid = query.gid as string;
      const storeKey = `post_${board}_${gid}_`;
      const data: RootState = await getStorage(storeKey);
      console.log(data);
      setTitle(data.group.mainPost.title);

      const users: IUser[] = [];
      let postsCount = 0;
      let postAuthor = "";
      const userMap: { [author: string]: IUser } = {};
      data.group.pages.forEach(page => {
        page.posts.forEach(({ postCount, author, score, floor }) => {
          if (!userMap[author]) {
            const user = {
              author,
              postCount,
              score,
              floor,
              count: 1
            };
            users.push(user);
            userMap[author] = user;
          } else {
            ++userMap[author].count;
          }
          ++postsCount;
          if (floor == 0) {
            postAuthor = author;
          }
        });
      });
      setAuthor(postAuthor);
      setAuthorPostCount(userMap[postAuthor].count);
      setPostsCount(postsCount);
      setUsers(users);
    }
    main();
  }, []);

  function sortBy(key: UserKeys) {
    const tmp = [...users];
    let sm = lastSortMethod;
    if (lastSortKey === key) {
      sm = sm * -1;
    } else {
      sm = -1;
    }
    tmp.sort((u1, u2) => {
      return sm * (u1[key] - u2[key]);
    });
    setUsers(tmp);
    setLastSortKey(key);
    setLastSortMethod(sm);
  }

  const anchor = (key: UserKeys) => {
    return lastSortKey === key ? (lastSortMethod == 1 ? "🔼" : "🔽") : "";
  };
  // const data:Json = await
  return (
    <div className="main">
      <h3>{title}</h3>
      <div>
        本文作者{author}，参与互动
        {authorPostCount}个。共{postsCount}
        楼，{users.length}
        人参与本帖。
      </div>
      <div className="chart">
        <AreaChart
          width={400}
          height={100}
          data={users}
          margin={{ top: 10, right: 0, left: 0, bottom: 10 }}
        >
          <defs>
            <linearGradient id="colorPv" x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%" stopColor="#82ca9d" stopOpacity={0.8} />
              <stop offset="95%" stopColor="#82ca9d" stopOpacity={0} />
            </linearGradient>
          </defs>
          <YAxis />
          <Legend />
          <CartesianGrid strokeDasharray="3 3" />
          <Area
            type="monotone"
            dataKey="count"
            stroke="#82ca9d"
            fillOpacity={1}
            fill="url(#colorPv)"
          />
        </AreaChart>
      </div>
      <div>
        <table className="userlist">
          <thead>
            <tr>
              <th onClick={() => sortBy("floor")}>作者{anchor("floor")}</th>
              <th onClick={() => sortBy("postCount")}>
                帖子{anchor("postCount")}
              </th>
              <th onClick={() => sortBy("score")}>积分{anchor("score")}</th>
              <th onClick={() => sortBy("count")}> 回复{anchor("count")}</th>
            </tr>
          </thead>
          <tbody>
            {users.map(user => {
              return (
                <tr key={user.author}>
                  <td>{user.author}</td>
                  <td>{user.postCount}</td>
                  <td>{user.score}</td>
                  <td>{user.count}</td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default Experimental;
