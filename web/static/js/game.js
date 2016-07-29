import React, { Component } from "react";
import { Provider } from "react-redux";
import ReactDOM from "react-dom";
import store from "./store";
import { Socket } from "phoenix"
import map from "lodash/map";
import concat from "lodash/concat";
import qs from "qs";

class Game extends Component {
  constructor(props) {
    super(props);

    this.state = {
      connected: false,
      messages: [],
      users: [],
    }
  }

  componentDidMount() {
    const game_id = window.location.pathname.split("/")[2];
    const user = qs.parse(window.location.search.split("?")[1])["user"];

    let socket = new Socket("/socket", {
      logger: ((kind, msg, data) => { console.log(`${kind}: ${msg}, ${data}`) })
    });

    socket.connect({user: user});
    socket.onOpen((e) => console.log("Open:", e))
    socket.onError((e) => console.log("Error:", e))
    socket.onClose((e) => console.log("Close:", e))

    this.channel = socket.channel(`game:${game_id}`, {user: user})
    this.channel.join()
      .receive("ignore", () => console.log("auth error"))
      .receive("ok", () => this.setState({connected: true}))

    this.channel.on("new:message", (msg) => {
      const { messages } = this.state;

      this.setState({messages: concat(messages, msg.message)})
    });

    this.channel.on("new:user_update", (msg) => {
      this.setState({users: msg.users})
    })
  }

  handleReadySubmission(e) {
    e.preventDefault();
    const user = qs.parse(window.location.search.split("?")[1])["user"];

    this.channel.push("new:user_ready", {user: user});
  }

  renderMessages(messages) {
    const html = map(messages, (message, index) => {
      return <p key={index}>{message}</p>
    })

    return html;
  }

  renderUsers(users) {
    const html = map(users, (user, index) => {
      return <p key={index}>{user.name}</p>
    })

    return html;
  }

  render() {
    const { messages, users } = this.state;

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

        <div>
          { this.renderUsers(users) }
        </div>

        <button onClick={(e) => this.handleReadySubmission(e)}>
          Ready
        </button>
      </div>
    );
  }
}

ReactDOM.render(<Game />, document.getElementById("react-app-game"));

export default Game;
