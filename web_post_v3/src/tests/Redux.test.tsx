import React, { FunctionComponent, memo } from "react";
import { createStore, combineReducers } from "redux";
import { Provider, useDispatch, useSelector, connect } from "react-redux";
import { createReducer } from "@reduxjs/toolkit";

import "./test.css";

interface Window {
  __REDUX_DEVTOOLS_EXTENSION__?: Function | null;
}
declare let window: Window;

const ACTION_ADD = "ACTION_ADD";
const ACTION_MINUS = "ACTION_MINUS";
const ACTION_ADD_TODO = "ACTION_ADD_TODO";
const ACTION_TODO_UPDATE = "ACTION_TODO_UPDATE";

interface AddAction {
  type: typeof ACTION_ADD;
}

interface MinusAction {
  type: typeof ACTION_MINUS;
}

type CounterActionTypes = AddAction | MinusAction;

interface AddTodoAction {
  type: typeof ACTION_ADD_TODO;
}

interface UpdateTodoAction {
  type: typeof ACTION_TODO_UPDATE;
  index: number;
  text: string;
}

type TotoActinTypes = AddTodoAction | UpdateTodoAction;

interface IStore {
  counter: number;
  todos: string[];
}

function counter(state: number = 0, action: CounterActionTypes): number {
  switch (action.type) {
    case ACTION_ADD:
      return state + 1;
    case ACTION_MINUS:
      return state - 1;
    default:
      return state;
  }
}

function todos(state: string[] = ["a", "b"], action: TotoActinTypes): string[] {
  switch (action.type) {
    case ACTION_ADD_TODO:
      return [...state, new Date().toString()];
    case ACTION_TODO_UPDATE:
      const { index, text } = action;
      state[index] = text;
      return state;
    default:
      return state;
  }
}

const magicReducer = createReducer(["a", "b"], {
  ACTION_ADD_TODO: (state: string[], action: AddTodoAction) => {
    return [...state, new Date().toString()];
  },
  ACTION_TODO_UPDATE: (state: string[], action: UpdateTodoAction) => {
    const { index, text } = action;
    state[index] = text;
  }
});

const rootReducer = combineReducers({
  counter,
  todos: magicReducer
});

const store = createStore(
  rootReducer,
  window.__REDUX_DEVTOOLS_EXTENSION__ && window.__REDUX_DEVTOOLS_EXTENSION__()
);

const Counter: FunctionComponent<{ n: number }> = ({ n }) => {
  const dispatch = useDispatch();
  function add() {
    dispatch({
      type: ACTION_ADD
    });
  }
  console.log("Counter render");
  return (
    <div>
      Counter = {n}
      <button onClick={add}>Add</button>
    </div>
  );
};

const Todo: FunctionComponent<{ text: string }> = memo(({ text }) => {
  console.log("todo render", text);
  return <div style={{ color: "green" }}>{text}</div>;
});

const TodoWithIndex: FunctionComponent<{ index: number }> = React.memo(
  ({ index }) => {
    const text = useSelector((state: IStore) => {
      return state.todos[index];
    });
    console.log("todo with index render", index);
    return <div style={{ color: "red" }}>{text}</div>;
  }
);

const WrappedTodoWithIndex = connect(
  (state: { todos: string[] }, ownProps: { index: number }) => {
    return { text: state.todos[ownProps.index] };
  }
)(Todo);

const Todos: FunctionComponent<{ count: number; todos: string[] }> = ({
  count = 0,
  todos = []
}) => {
  const dispatch = useDispatch();
  function addTodo() {
    dispatch({
      type: ACTION_ADD_TODO
    });
  }
  function update1() {
    dispatch({
      type: ACTION_TODO_UPDATE,
      index: 1,
      text: "updated" + new Date().toString()
    });
  }
  console.log("todos render");
  return (
    <div>
      {/* {new Array(count).fill(0).map((_, i) => (
        <WrappedTodoWithIndex key={i} index={i} />
      ))} */}
      {/* {new Array(count).fill(0).map((_, index) => (
        <TodoWithIndex key={index} index={index} />
      ))} */}
      {todos.map(text => (
        <Todo text={text} key={text} />
      ))}
      {/* todos.map((_, index) => (
        <WrappedTodoWithIndex key={index} index={index} />
      ))}
      {todos.map((_, index) => {
        return connect();
      })} */}

      <button onClick={addTodo}>add todo</button>
      <button onClick={update1}>update 1</button>
    </div>
  );
};

const WrappedCounter = connect((state: { counter: number }) => ({
  n: state.counter
}))(Counter);
const WrappedTodos = connect((state: { todos: string[] }) => ({
  count: state.todos.length,
  todos: state.todos
}))(Todos);

const App: FunctionComponent = () => {
  return (
    <Provider store={store}>
      <WrappedCounter />
      <WrappedTodos />
    </Provider>
  );
};

export default App;
