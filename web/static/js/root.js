import React, { Component } from "react";
import ReactDOM from "react-dom";
import { Router, Route, browserHistory } from "react-router";
import { createStore, combineReducers } from "redux";
import { Provider } from "react-redux";
import { syncHistoryWithStore, routerReducer } from "react-router-redux";

const reducer = function(initialState = {}, state) {
  return state;
}

const store = createStore(combineReducers({
  reducer: reducer,
  routing: routerReducer,
}));

const history = syncHistoryWithStore(browserHistory, store)

class Root extends Component {
  render() {
    return (
      <Provider store={store}>
        <Router history={history}>
          <Route path="/" component={Home} />
        </Router>
      </Provider>
    );
  }
}

class Home extends Component {
  render() {
    return (
      <div>
        <p>Hello World</p>
      </div>
    );
  }
}

ReactDOM.render(<Root />, document.getElementById("react-app"));

export default Root;
