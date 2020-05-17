import { FC, useEffect, useState } from "react";
import React from "react";
import { getQuery } from "../article/utils/urlHelper";
import { getStorage, setTitle } from "../jsapi";
import { RootState } from "../article";
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
  const [title, setTitle] = useState("");
  const [author, setAuthor] = useState("");
  const [users, setUsers] = useState<IUser[]>([]);
  const [countMap, setCountMap] = useState<ICountMap>({});
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
      data.group.pages.forEach(page => {
        page.posts.forEach(({ postCount, author, score, floor }) => {
          users.push({
            author,
            postCount,
            score,
            floor,
            count: 0
          });
          if (floor == 0) {
            setAuthor(author);
          }
        });
      });

      const countMap: ICountMap = {};
      users.forEach(user => {
        if (!countMap[user.author]) {
          countMap[user.author] = user;
        }
        countMap[user.author].count++;
      });
      setUsers(users);
      setCountMap(countMap);
    }
    main();
  }, []);

  // const data:Json = await
  return (
    <div className="main">
      <h3>{title}</h3>
      <div>
        本文作者{author}，参与互动
        {countMap[author] ? countMap[author].count : "--"}个。共{users.length}
        楼，{Object.keys(countMap).length}
        人参与本帖。
      </div>
      <div>
        <table className="userlist">
          <thead>
            <tr>
              <th>作者🔼</th>
              <th>帖子🔽</th>
              <th>积分</th>
              <th> 回复</th>
            </tr>
          </thead>
          <tbody>
            {Object.keys(countMap).map(author => {
              const user = countMap[author];
              return (
                <tr key={author}>
                  <td>{author}</td>
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
