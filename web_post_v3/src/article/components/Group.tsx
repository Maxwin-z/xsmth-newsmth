import { useDispatch, useSelector } from "react-redux";
import { ISetPageAction, ACTION_TYPE_SET_PAGES } from "../reducers/group";
import { IStatus } from "../../postgroup/types";
import React, { useEffect } from "react";
import { IStore } from "..";

function Group() {
  const dispatch = useDispatch();

  const fetchData = () => {
    console.log("fetchData");
    function dispatchAction(action: ISetPageAction) {
      dispatch(action);
    }
    setTimeout(() => {
      dispatchAction({
        type: ACTION_TYPE_SET_PAGES,
        pages: new Array(10).fill({
          title: "",
          total: 0,
          p: 1,
          posts: [],
          status: IStatus.init
        })
      });
    });
  };

  console.log("Group render");

  return <GroupInner fetchData={fetchData} />;
}

function GroupInner({ fetchData }: { fetchData: () => void }) {
  useEffect(() => {
    fetchData();
  }, [fetchData]);

  const pages = useSelector(({ pages }: IStore) => pages);

  return (
    <div className="group">
      {pages.map((_, index) => (
        <div key={index}>page: {index}</div>
      ))}
      <button onClick={fetchData}>fetch</button>
    </div>
  );
}

export default Group;
