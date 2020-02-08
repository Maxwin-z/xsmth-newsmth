import { Json } from "..";

export interface Post {
  url?: string;
  board?: string;
  gid?: number;
  pid?: number;
  title?: string;
  author?: string;
  nick?: string;
  floor?: string;
  date?: number;
  dateString?: string;
  content?: string;
  images?: Json[];
  isSingle?: boolean;
}

export interface PostGroup {
  board?: string;
  title?: string;
  total?: number;
  posts?: Post[];
}
