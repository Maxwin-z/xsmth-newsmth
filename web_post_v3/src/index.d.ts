export interface Json {
  [x: string]: string | number | boolean | Date | Json | JsonArray;
}
export interface JsonArray
  extends Array<string | number | boolean | Date | Json | JsonArray> {}
