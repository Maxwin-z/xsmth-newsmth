import React, { useEffect, useState } from "react";
import "./index.css";
import { xOpen, ModalStyle, ajax, Json, download, setTitle } from "../jsapi";
import { getQuery } from "../article/utils/urlHelper";
import { Tag, loadUserTags, loadTags, saveUserTags } from "./tagUtil";

function App() {
  const { author } = getQuery();
  setTitle(`查看用户 - ${author}`);
  const [user, setUser] = useState<Json>({});
  const [avatar, setAvatar] = useState("");
  const [userTags, setUserTags] = useState<Tag[]>([]);
  const [tags, setTags] = useState<Tag[]>([]);
  useEffect(() => {
    async function main() {
      const text = await ajax({
        url: `http://www.newsmth.net/nForum/user/query/${author}.json`,
        headers: {
          "X-Requested-With": "XMLHttpRequest"
        }
      });
      const user = JSON.parse(text);
      setUser(user);
      setUserTags(await loadUserTags(author));
      setTags(await loadTags());
      const url = `https:${user.face_url}`;
      download(url).then(ret => {
        console.log(ret);
        setAvatar(`ximg://_?url=${encodeURIComponent(url)}`);
      });
    }
    main();
  }, []);

  const removeUserTag = (i: number) => {
    const ts = [...userTags];
    console.log(ts);
    console.log(ts.splice(i, 1));
    setUserTags(ts);
    saveUserTags(author, ts);
  };
  const addUserTag = (i: number) => {
    const ts = [...userTags];
    const tag = tags[i];
    if (
      ts.findIndex((t: Tag) => t.color === t.color && t.text === t.text) === -1
    ) {
      ts.push(tag);
    }
    setUserTags(ts);
    saveUserTags(author, ts);
  };

  const addTags = () => {
    const { origin, pathname } = window.location;
    xOpen({
      url: origin + pathname + "#/addtag",
      type: ModalStyle.modal
    });
  };

  return (
    <div className="main">
      <div className="header flex-row">
        <img className="avatar" src={avatar} />
        <div className="userinfo flex1 flex-column">
          <div className="username flex1">{author}</div>
          <div className="nickname flex1">{user.user_name}</div>
          <div className="state flex1">
            {user.is_online ? (
              <span className="online">●在线</span>
            ) : (
              <span className="offline">●离线</span>
            )}{" "}
            <span className="location">{user.last_login_ip}</span>
          </div>
        </div>
      </div>
      <div className="cell flex-row">
        <div className="flex1">论坛身份</div>
        <div className="">{user.level}</div>
      </div>
      <div className="cell flex-row">
        <div className="flex1">帖子总数</div>
        <div className="">{user.post_count}</div>
      </div>
      <div className="cell flex-row">
        <div className="flex1">登录次数</div>
        <div className="">{user.login_count}</div>
      </div>
      <div className="cell flex-row">
        <div className="flex1">用户积分</div>
        <div className="">{user.score_user}</div>
      </div>
      <div className="tag-section">Tags</div>
      {userTags.map((tag, i) => (
        <div className="cell flex-row" key={`${tag.text}_${tag.color}`}>
          <div className="flex1">
            <span
              className="tag"
              style={{
                color: tag.color
              }}
            >
              ■
            </span>
            {tag.text}
          </div>
          <div className="delete" onClick={() => removeUserTag(i)}>
            ⛔️
          </div>
        </div>
      ))}

      <div className="tag-section">我的Tags</div>
      {tags.map((tag, i) => (
        <div className="cell flex-row" key={`${tag.text}_${tag.color}`}>
          <div className="flex1">
            <span
              className="tag"
              style={{
                color: tag.color
              }}
            >
              ■
            </span>
            {tag.text}
          </div>
          <div className="delete" onClick={() => addUserTag(i)}>
            ➕
          </div>
        </div>
      ))}
      <div className="flex-row flex-center">
        <a className="btn btn-manager-tags" onClick={addTags}>
          管理Tags
        </a>
      </div>
    </div>
  );
}

export default App;
