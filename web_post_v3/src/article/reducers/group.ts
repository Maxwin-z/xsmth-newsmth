import { IPage } from "../../postgroup/types";

export const ACTION_TYPE_SET_PAGES = "ACTION_TYPE_SET_PAGES";

export interface ISetPageAction {
  type: typeof ACTION_TYPE_SET_PAGES;
  pages: IPage[];
}

export type IPagesAction = ISetPageAction;

export type IPagesState = Array<IPage>;

export function pages(
  state: IPagesState = [],
  action: IPagesAction
): IPagesState {
  switch (action.type) {
    case ACTION_TYPE_SET_PAGES:
      return [...action.pages];
    default:
      return state;
  }
}
