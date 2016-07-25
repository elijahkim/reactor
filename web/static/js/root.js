import React, { Component } from "react";
import ReactDOM from "react-dom";

class Root extends Component {
  render() {
    return (
      <div>
        <p>Hello world</p>
      </div>
    )
  }
}

ReactDOM.render(<Root />, document.getElementById("react-app"));

export default Root;
