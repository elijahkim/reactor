import React, { Component } from "react";
import { Provider } from "react-redux";
import ReactDOM from "react-dom";
import store from "./store";
import { Socket } from "phoenix"
import map from "lodash/map";
import join from "lodash/join";
import concat from "lodash/concat";
import qs from "qs";

class Game extends Component {
  constructor(props) {
    super(props);

    this.state = {
      connected: false,
      messages: [],
      users: [],
      state: null,
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
      this.setState({users: msg.users});
    })

    this.channel.on("new:round", (msg) => {
      this.setState(Object.assign({}, msg, { state: "in_progress" }))
    })
  }

  handleReadySubmission(e) {
    e.preventDefault();
    const user = qs.parse(window.location.search.split("?")[1])["user"];

    this.channel.push("start_game", {user: user});
  }

  renderMessages(messages) {
    const html = map(messages, (message, index) => {
      return <p key={index}>{message}</p>
    })

    return html;
  }

  renderUsers(users) {
    const joinedUsers = join(map(users, "name"), ", ")
    return <p>{ joinedUsers }</p>;
  }

  renderColors(colors) {
    return (
      <div className="game__colors-container">
        <div className="game__color-instruction-container">
          <h1 className="game__color-instruction-text">
            Green
          </h1>
        </div>
        <div className="game__colors-row">
          <button className="game__color-block blue">
          </button>
          <button className="game__color-block red">
          </button>
        </div>
        <div className="game__colors-row">
          <button className="game__color-block green">
          </button>
          <button className="game__color-block yellow">
          </button>
        </div>
      </div>
    )
  }

  renderWaiting() {
    return (
      <div className="game__colors-container">
        <div className="game__color-instruction-container">
          <h1 className="game__color-instruction-text">
            Waiting for round to begin
          </h1>
        </div>
        <div className="game__colors-row">
        </div>
        <div className="game__colors-row">
        </div>
      </div>
    )
  }

  render() {
    const { messages, users, colors, state } = this.state;

    return (
      <div className="game__container">
        { state == "in_progress" ? this.renderColors(colors) : this.renderWaiting() }

        <div className="game__sidebar-container">
          <div className="game__users-container">
            { this.renderUsers(users) }
          </div>
          <div className="game__chat-container">
            <div className="game__messages-container">
              { this.renderMessages(messages) }
            </div>

          </div>
          <button
            onClick={(e) => this.handleReadySubmission(e)}
            type="button"
          >
            Ready
          </button>
        </div>
      </div>
    );
  }
}

ReactDOM.render(<Game />, document.getElementById("react-app-game"));

export default Game;
