import { getStorage, setStorage } from "../jsapi";

export interface ITag {
  color: string;
  text: string;
}

export interface IUserTag {
  user: string;
  tags: ITag[];
}

const tagsKey = "tags";
export async function loadTags() {
  let tags: ITag[] = [];
  try {
    tags = await getStorage(tagsKey);
  } catch (_) {}
  return tags;
}
export async function saveTags(tags: ITag[]) {
  return await setStorage(tagsKey, tags);
}

export async function loadUserTag(user: string) {
  let userTag: IUserTag = {
    user,
    tags: []
  };
  try {
    userTag = await getStorage(`${tagsKey}_${user}`);
  } catch (_) {}
  return userTag;
}

export async function saveUserTag(user: string, userTag: IUserTag) {
  return await setStorage(`${tagsKey}_${user}`, userTag);
}
