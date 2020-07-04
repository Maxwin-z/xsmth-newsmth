import React, { useEffect, useState } from "react";
import "./index.css";
import {
  xOpen,
  ModalStyle,
  ajax,
  Json,
  download,
  setTitle,
  ipInfo
} from "../jsapi";
import { getQuery } from "../article/utils/urlHelper";
import { ITag, loadUserTag, loadTags, saveUserTag, IUserTag } from "./tagUtil";

function App() {
  const { author } = getQuery();
  setTitle(`查看用户 - ${author}`);
  const [user, setUser] = useState<Json>({});
  const [avatar, setAvatar] = useState("");
  const [userTag, setUserTag] = useState<IUserTag>();
  const [tags, setTags] = useState<ITag[]>([]);
  useEffect(() => {
    async function getLocation(ip: string) {
      const matches = ip.match(/^(\d{0,3}\.\d{0,3}\.\d{0,3}\.).*/);
      if (matches) {
        let ipStr = matches[1] + "8";
        let info = null;
        try {
          info = await ipInfo(ipStr);
        } catch (e) {
          return "";
        }
        let location = "";
        if (info.country !== "中国") {
          location = info.country;
        }
        if (info.city.length > 0 && info.city.indexOf(info.province) === -1) {
          location += info.province;
        }
        location += info.city;
        if (info.ISP.length > 0) {
          location += "(" + info.ISP + ")";
        }
        return location;
      }
      return "";
    }

    async function main() {
      const text = await ajax({
        url: `http://www.newsmth.net/nForum/user/query/${author}.json`,
        headers: {
          "X-Requested-With": "XMLHttpRequest"
        }
      });

      const user = JSON.parse(text);
      user.location = await getLocation(user.last_login_ip);

      setUser(user);
      setUserTag(await loadUserTag(author));
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
    userTag?.tags.splice(i, 1);
    setUserTag(Object.assign({}, userTag));
    saveUserTag(author, userTag!);
  };
  const addUserTag = (i: number) => {
    const ts = [...userTag!.tags];
    const tag = tags[i];
    if (
      ts.findIndex(
        (t: ITag) => t.color === tag.color && t.text === tag.text
      ) === -1
    ) {
      ts.push(tag);
    }
    const ut: IUserTag = Object.assign({}, userTag, {
      tags: ts
    });
    setUserTag(ut);
    saveUserTag(author, ut);
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
            <span className="location">
              {user.location || user.last_login_ip}
            </span>
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
      {userTag?.tags.map((tag, i) => (
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
