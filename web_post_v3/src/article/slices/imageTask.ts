import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import { IXImage, IPost, Status } from "../types";
import { AppThunk } from "..";
import { download } from "../utils/jsapi";

interface IImagesState {
  images: IXImage[];
  count: number;
  taskCount: number;
}

const initialState: IImagesState = {
  images: [],
  count: 0,
  taskCount: 0
};

const imageTask = createSlice({
  name: "imageTask",
  initialState,
  reducers: {
    enqueue(state, { payload }: PayloadAction<IPost[]>) {
      // console.log("enqueue", payload);
      const images: IXImage[] = payload.map(({ images }) => images).flat();
      if (images.length > 0) {
        state.images = state.images.concat(images);
        state.count = state.images.length;
      }
    },
    loadBegin(state, { payload }: PayloadAction<number>) {
      state.images[payload].status = Status.loading;
      state.taskCount += 1;
    },
    loadSuccess(state, { payload }: PayloadAction<number>) {
      state.images[payload].status = Status.success;
      state.taskCount -= 1;
    },
    loadFail(state, { payload }: PayloadAction<number>) {
      state.images[payload].status = Status.fail;
      state.taskCount -= 1;
    },
    reset(state) {
      state.images = [];
      state.taskCount = 0;
    }
  }
});

export const {
  enqueue,
  loadBegin,
  loadSuccess,
  loadFail,
  reset
} = imageTask.actions;

export default imageTask.reducer;

export const loadImage = (): AppThunk => async (dispatch, getState) => {
  const maxTaskCount = 2;
  const { images, taskCount } = getState().imageTask;
  if (taskCount >= maxTaskCount) {
    return;
  }
  const index = images.findIndex(img => img.status === Status.init);
  if (index === -1) {
    console.log("no init images");
    return;
  }
  let { id, src } = images[index];
  dispatch(loadBegin(index));
  let ret = false;
  try {
    ret = await download(src, id);
  } catch (ignore) {}
  if (ret === false) {
    try {
      src += "/large";
      ret = await download(src, id);
    } catch (ignore) {}
  }

  if (ret === true) {
    (document.querySelector(
      `#ximg-${id}`
    ) as HTMLImageElement).src = `ximg://_?url=${encodeURIComponent(src)}`;
    dispatch(loadSuccess(index));
    const span = document.querySelector(`#ximg-info-${id}`) as HTMLSpanElement;
    span.style.display = "none";
  } else {
    console.log(`load image fail: ${src}`);
    dispatch(loadFail(index));
  }
  dispatch(loadImage());
};

export const handleImageDownloadProgress = (data: any) => {
  const { id, progress, completed, total } = data;
  let info = "";
  if (total > 0) {
    const p = Math.floor(progress * 100) + "%";
    info = `正在加载${p}, ${formatSize(total)}`;
  } else {
    info = `正在加载${formatSize(completed)}`;
  }
  try {
    (document.querySelector(
      `#ximg-info-${id}`
    ) as HTMLSpanElement).innerHTML = info;
  } catch (e) {
    console.log("image not found", id, e);
  }
};

function formatSize(size: number): string {
  if (size < 1000) {
    return size + "B";
  }
  if (size < 1000 * 1000) {
    return Math.floor(size / 1000) + "K";
  }
  if (size < 1000 * 1000 * 1000) {
    return Math.floor(size / 1000 / 1000) + "M";
  }
  return "";
}
