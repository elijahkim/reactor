import React, { Component } from "react";
import { Provider } from "react-redux";
import ReactDOM from "react-dom";
import store from "./store";
import { Socket } from "phoenix"

class Game extends Component {
  constructor(props) {
    super(props);

    this.state = {
      connected: false,
    }
  }

  componentDidMount() {
    let socket = new Socket("/socket", {
      logger: ((kind, msg, data) => { console.log(`${kind}: ${msg}, ${data}`) })
    });

    socket.connect({user_id: "123"});
    socket.onOpen((e) => console.log("Open:", e))
    socket.onError((e) => console.log("Error:", e))
    socket.onClose((e) => console.log("Close:", e))

    let channel = socket.channel("game", {})
    channel.join()
      .receive("ignore", () => console.log("auth error"))
      .receive("ok", () => this.setState({connected: true}))
  }

  renderWelcomeMessage() {
    if (this.state.connected) {
      return (
        <div>
          <p>Welcome</p>
        </div>
      );
    }
  }

  render() {
    return (
      <Provider store={store}>
        <div>
          <div>
            <h1>Welcome</h1>
          </div>

          <div>
            <p>Hello world</p>
          </div>

          { this.renderWelcomeMessage() }
        </div>
      </Provider>
    );
  }
}

ReactDOM.render(<Game />, document.getElementById("react-app-game"));

export default Game;
