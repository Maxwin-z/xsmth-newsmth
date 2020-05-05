export enum EUserPriority {
  normal,
  highlight,
  disable
}
export interface IUserTag {
  color: string;
  text: string;
}
export interface IUserTagInfo {
  priority: EUserPriority;
  tags: IUserTag[];
  description: string;
}
