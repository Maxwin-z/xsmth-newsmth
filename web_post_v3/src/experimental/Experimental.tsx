import { FC, useEffect, useState } from "react";
import React from "react";
import { getQuery } from "../article/utils/urlHelper";
import { getStorage } from "../jsapi";

const Experimental: FC<{}> = () => {
  const [data, setData] = useState({});
  useEffect(() => {
    async function main() {
      const query = getQuery();
      const board = query.board as string;
      const gid = query.gid as string;
      const storeKey = `post_${board}_${gid}_`;
      const data = await getStorage(storeKey);
      console.log(data);
      setData(data);
    }
    main();
  }, []);

  // const data:Json = await
  return <div>Experimental, {JSON.stringify(data)}</div>;
};

export default Experimental;
