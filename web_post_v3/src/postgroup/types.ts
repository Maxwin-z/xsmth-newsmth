export enum IStatus {
  init = 0,
  loading = 1,
  success = 2,
  incomplete = 3,
  fail = 4
}

export interface IXImage {
  id: number;
  src: string;
  status: IStatus;
}

export interface IPost {
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
  images?: IXImage[];
  isSingle?: boolean;
}

export interface IGroup {
  board?: string;
  title?: string;
  total?: number;
  posts?: IPost[];
}

export interface IPage {
  title: string;
  total: number;
  p: number;
  posts: IPost[];
  status: IStatus;
  errorMessage?: string;
}

export interface Theme {
  fontFamily: string;
  fontSize: string;
  lineHeight: string;
  bgColor: string;
  textColor: string;
  tintColor: string;
  quoteColor: string;
}
