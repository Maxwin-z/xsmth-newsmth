import { getStorage, setStorage } from "../jsapi";

export interface Tag {
  color: string;
  text: string;
}
const tagsKey = "tags";
export async function loadTags() {
  let tags: Tag[] = [];
  try {
    tags = await getStorage(tagsKey);
  } catch (_) {}
  return tags;
}
export async function saveTags(tags: Tag[]) {
  return await setStorage(tagsKey, tags);
}
