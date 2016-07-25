import React, { Component } from "react";
import ReactDOM from "react-dom";
import { Router, Route, browserHistory } from "react-router";
import { createStore } from "redux";
import { Provider } from "react-redux";
import { syncHistoryWithStore } from "react-router-redux";
import store from "./store";
import Home from "./Home";

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

ReactDOM.render(<Root />, document.getElementById("react-app"));

export default Root;
