import { FC, useEffect } from "react";
import React from "react";
import { useDispatch, useSelector } from "react-redux";
import { RootState } from "..";
import { loadImage } from "../slices/imageTask";

const XImageQueue: FC<{}> = () => {
  const dispatch = useDispatch();
  const count = useSelector((state: RootState) => state.imageTask.count);
  useEffect(() => {
    // console.log("load images");
    dispatch(loadImage());
  }, [count, dispatch]);
  return <></>;
};

export default XImageQueue;
