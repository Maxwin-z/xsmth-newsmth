import { FC, useEffect } from "react";
import React from "react";
import { useDispatch, useSelector } from "react-redux";
import { RootState } from "..";
import { loadImage } from "../slices/imageTask";

const XImageQueue: FC<{}> = () => {
  const dispatch = useDispatch();
  const images = useSelector((state: RootState) => state.group.images);
  useEffect(() => {
    console.log("load images");
    dispatch(loadImage());
  }, [images, dispatch]);
  return <></>;
};

export default XImageQueue;
