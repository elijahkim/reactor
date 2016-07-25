import createLogger from "redux-logger";
import thunk from "redux-thunk";
import { applyMiddleware, createStore, combineReducers } from "redux";
import { routerReducer } from "react-router-redux";
import reducer from "./reducers";

const logger = createLogger();

const store = createStore(combineReducers({
  reducer: reducer,
  routing: routerReducer,
}), applyMiddleware(thunk, logger));

export default store;
