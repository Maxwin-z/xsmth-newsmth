import { RootState } from ".";

export enum Status {
  init,
  loading,
  success,
  fail,
  imcomplete
}

export enum ArticleStatus {
  allLoading,
  middlePageLoading,
  footerLoading,
  footerFail,
  allSuccess,
  allFail,
  reloading
}

export interface IMainPost {
  board: string;
  title: string;
  gid: number;
}

export interface IXImage {
  id: number;
  src: string;
  status: Status;
}

export interface IPost {
  url?: string;
  board?: string;
  gid?: number;
  pid: number;
  title?: string;
  author: string;
  nick: string;
  floor: number;
  date: number;
  dateString: string;
  content: string;
  images: IXImage[];
  isSingle?: boolean;
}

export interface IPage {
  posts: IPost[];
  status: Status;
  p: number;
  hidden?: boolean;
  errorMessage?: string;
}

export interface IGroup {
  title: string;
  posts: IPost[];
  p: number;
  total: number;
}

export interface ITask {
  status: Status;
  p: number;
}

export interface IGroupState {
  mainPost: IMainPost;
  pages: IPage[];
  tasks: ITask[];
  taskCount: number;
  articleStatus: ArticleStatus;
  lastLoading: number;
  selectedPage: number;
  pageScrollY: number;
}

export interface ITheme {
  fontFamily: string;
  fontSize: string;
  lineHeight: string;
  bgColor: string;
  textColor: string;
  tintColor: string;
  quoteColor: string;
}
