import React, { FC, useState, useEffect } from "react";
import { useSelector, useDispatch } from "react-redux";
import { RootState } from "..";
import { xScrollBy } from "../utils/jsapi";
import { singleAuthor } from "../groupSlice";

const SingleAuthor: FC<{}> = () => {
  const [prev, setPrev] = useState(-1);
  const [next, setNext] = useState(-1);
  const [current, setCurrent] = useState(-1);
  const [index, setIndex] = useState(-1);
  const [total, setTotal] = useState(-1);
  const { author, pages } = useSelector((state: RootState) => ({
    author: state.group.author,
    pages: state.group.pages
  }));
  const posts = pages
    .map(page => page.posts)
    .flat()
    .filter(post => post.author === author);

  useEffect(() => {
    // console.log(author, posts);

    let _prev = -1;
    let _next = -1;
    posts.forEach(post => {
      const floor = post.floor;
      const dom = document.querySelector(`[data-floor='${floor}']`);
      const top = dom?.getBoundingClientRect().top || -1;
      if (top < -1) {
        _prev = floor;
      }
      if (top > -1 && _next === -1) {
        _next = floor;
      }
    });
    setPrev(_prev);
    setNext(_next);
    setCurrent(-1);
    setTotal(posts.length);
  }, [author, pages, posts]);

  const toFloor = (floor: number) => {
    if (floor === -1) return;
    const dom = document.querySelector(`[data-floor='${floor}']`);
    const top = dom?.getBoundingClientRect().top || -1;
    xScrollBy(0, top);
    const index = posts.findIndex(post => post.floor === floor);
    index > 0 ? setPrev(posts[index - 1].floor) : setPrev(-1);
    index < posts.length - 1 ? setNext(posts[index + 1].floor) : setNext(-1);
    setCurrent(floor);
    setIndex(index);
  };

  const dispatch = useDispatch();
  const clear = () => {
    dispatch(singleAuthor(null));
  };
  if (!author) {
    return null;
  }

  return (
    <div className="single-author-box skip-scroll">
      <div onClick={() => toFloor(prev)} className="arrow"></div>
      <div onClick={() => toFloor(prev)}>{prev === -1 ? "-" : prev}</div>
      <div>
        <strong>{current === -1 ? "-" : current}</strong>
      </div>
      <div onClick={() => toFloor(next)}>{next === -1 ? "-" : next}</div>
      <div onClick={() => toFloor(next)} className="arrow down"></div>
      <div>
        {index === -1 ? "#" : index + 1}/{total}
      </div>
      <div onClick={clear} className="del btn"></div>
    </div>
  );
};

export default SingleAuthor;
