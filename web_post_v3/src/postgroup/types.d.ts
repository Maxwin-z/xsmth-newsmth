export enum Status {
  init = 0,
  loading = 1,
  success = 2,
  incomplete = 3,
  fail = 4
}

export interface XImage {
  id: number;
  src: string;
  status: Status;
}

export interface Post {
  url?: string;
  board?: string;
  gid?: number;
  pid?: number;
  title?: string;
  author?: string;
  nick?: string;
  floor?: number;
  date?: number;
  dateString?: string;
  content?: string;
  images?: XImage[];
  isSingle?: boolean;
}

export interface PostGroup {
  board?: string;
  title?: string;
  total?: number;
  posts?: Post[];
}

export interface Page {
  title: string;
  total: number;
  p: number;
  posts: Post[];
  status: Status;
  errorMessage?: string;
}
