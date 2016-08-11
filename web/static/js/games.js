import React, { Component } from "react";
import ReactDOM from "react-dom";
import { Socket } from "phoenix"
import map from "lodash/map";

const elem = document.getElementById("react-app-games");
const user = elem.attributes["js-user"].value

class Games extends Component {
  constructor(props) {
    super(props);

    this.state = {
      games: [],
    }
  }

  componentDidMount() {
    console.log(window.user);
    let socket = new Socket("/socket", {
      logger: ((kind, msg, data) => { console.log(`${kind}: ${msg}, ${data}`) })
    });

    socket.connect();
    socket.onOpen((e) => console.log("Open:", e))
    socket.onError((e) => console.log("Error:", e))
    socket.onClose((e) => console.log("Close:", e))

    this.channel = socket.channel(`game:lobby`)
    this.channel.join()
      .receive("ignore", () => console.log("auth error"))
      .receive("ok", () => this.setState({connected: true}))

    this.channel.on("new:game_update", (msg) => {
      this.setState({games: msg.games})
    });
  }

  renderGames(games) {
    const html = map(games, (game, index) => {
      return (
        <li key={index}>
          <a href={`/games/${game.id}?user=${user}`}>Join {game.name}</a>
        </li>
      )
    })

    return html;
  }

  render() {
    const { games } = this.state;

    return (
      <div>
        <h1>games</h1>

        <ul>
          { this.renderGames(games) }
        </ul>
      </div>
    )
  }
}

if (elem) {
  ReactDOM.render(<Games />, elem);
}

export default Games;
