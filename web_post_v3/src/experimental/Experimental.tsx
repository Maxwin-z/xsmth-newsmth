import { FC, useEffect } from "react";
import React from "react";
import { getQuery } from "../article/utils/urlHelper";
import { getStorage } from "../jsapi";

const Experimental: FC<{}> = () => {
  useEffect(() => {
    async function main() {
      const query = getQuery();
      const board = query.board as string;
      const gid = query.gid as string;
      const storeKey = `post_${board}_${gid}_`;
      const data = await getStorage(storeKey);
      console.log(data);
    }
    main();
  }, []);

  // const data:Json = await
  return <div>Experimental, JSON.stringify(query)</div>;
};

export default Experimental;
