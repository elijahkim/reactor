import React, { Component } from "react";
import { Provider } from "react-redux";
import ReactDOM from "react-dom";
import store from "./store";
import { Socket } from "phoenix"
import map from "lodash/map";
import join from "lodash/join";
import concat from "lodash/concat";
import qs from "qs";
import MainPanel from "./components/MainPanel";

class Game extends Component {
  constructor(props) {
    super(props);

    this.state = {
      connected: false,
      users: [],
      state: "waiting",
      showReadyButton: true,
      welcomeMessage: "",
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

    this.channel.on("new:welcome_message", (msg) => {
      this.setState({welcomeMessage: msg.message})
    });

    this.channel.on("new:user_update", (msg) => {
      this.setState({users: msg.users});
    });

    this.channel.on("new:round", (msg) => {
      this.setState(Object.assign({}, msg, {
        state: "in_progress",
        receivedAt: new Date(),
        showReadyButton: false,
      }));
    });

    this.channel.on("new:winner", (msg) => {
      const { messages } = this.state;
      this.channel.push("new:winner_received");

      this.setState({
        winner: msg.user,
        state: "winner_received",
        users: msg.users,
      });
    });
  }

  handleReadySubmission(e) {
    const user = qs.parse(window.location.search.split("?")[1])["user"];

    this.channel.push("start_game", {user: user});
  }

  handleClick(color) {
    const { receivedAt } = this.state;
    const time = new Date();
    this.channel.push("new:answer_submission", {submission: color, et: time - receivedAt});
    this.setState({state: "answer_selected"})
  }

  render() {
    const {
      colors,
      instruction,
      showReadyButton,
      state,
      users,
      winner,
      welcomeMessage,
    } = this.state;

    return (
      <div className="game__container">
        <MainPanel
          colors={colors}
          state={state}
          instruction={instruction}
          winner={winner}
          onColorClick={(color) => this.handleClick(color)}
          onStartClick={() => this.handleReadySubmission()}
          users={users}
          welcomeMessage={welcomeMessage}
        />
      </div>
    );
  }
}

const elem = document.getElementById("react-app-game");

if (elem) {
  ReactDOM.render(<Game />, elem);
}

export default Game;
