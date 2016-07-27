import React, { Component } from "react";
import { Provider } from "react-redux";
import ReactDOM from "react-dom";
import store from "./store";
import { Socket } from "phoenix"
import map from "lodash/map";
import concat from "lodash/concat";

class Game extends Component {
  constructor(props) {
    super(props);

    this.state = {
      connected: false,
      messages: [],
    }
  }

  componentDidMount() {
    const game_id = window.location.pathname.split("/")[2];
    let socket = new Socket("/socket", {
      logger: ((kind, msg, data) => { console.log(`${kind}: ${msg}, ${data}`) })
    });

    socket.connect({user_id: "123"});
    socket.onOpen((e) => console.log("Open:", e))
    socket.onError((e) => console.log("Error:", e))
    socket.onClose((e) => console.log("Close:", e))

    let channel = socket.channel(`game:${game_id}`, {})
    channel.join()
      .receive("ignore", () => console.log("auth error"))
      .receive("ok", () => this.setState({connected: true}))

    channel.on("new:message", (msg) => {
      const { messages } = this.state;

      this.setState({messages: concat(messages, msg.message)})
    });
  }

  renderMessages(messages) {
    const html = map(messages, (message, index) => {
      return <p key={index}>{message}</p>
    })

    return html;
  }

  render() {
    const { messages } = this.state;

    return (
      <div>
        <div>
          <h1>Welcome</h1>
        </div>

        <div>
          <p>Hello world</p>
        </div>

        <div>
          { this.renderMessages(messages) }
        </div>
      </div>
    );
  }
}

ReactDOM.render(<Game />, document.getElementById("react-app-game"));

export default Game;
