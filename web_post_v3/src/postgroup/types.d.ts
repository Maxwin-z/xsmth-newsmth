export interface Post {
  url?: string;
  board?: string;
  gid?: number;
  pid?: number;
  title?: string;
  author?: string;
  date?: number;
  content?: string;
  isSingle?: boolean;
}

export interface PostGroup {
  board?: string;
  title?: string;
  total?: number;
  posts?: Post[];
}