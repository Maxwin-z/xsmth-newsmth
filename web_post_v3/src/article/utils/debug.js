export const _log = (...args) => {
  console.log.apply(console, args);
};

export const _unexpected = (...args) => {
  args = ["[UNEXPECTED", ...args];
  console.error.apply(console, ...args);
  throw args.join(" ");
};
