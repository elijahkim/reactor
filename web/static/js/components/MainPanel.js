import React, { Component } from "react";
import map from "lodash/map";
import sortBy from "lodash/sortBy";

class MainPanel extends Component {
  handleColorClick(e, color) {
    e.preventDefault();
    const { onColorClick } = this.props;

    onColorClick(color)
  }

  handleStartClick(e) {
    e.preventDefault();
    const { onStartClick } = this.props;

    onStartClick();
  }

  renderWinner(winner, users) {
    const sortedUsers = sortBy(users, (user) => -(user.score));
    const usersHtml = map(sortedUsers, (user, index) => {
      return <li key={index}><h3>{user.name}: {user.score}</h3></li>
    });

    return (
      <div className="main-panel__winner-announcement-container">
        <h1>{winner} is the winner</h1>
        <ul>
          { usersHtml }
        </ul>
      </div>
    )
  }

  renderColors(colors, instruction) {
    return (
      <div className="main-panel__colors-container">
        <button
          className={`main-panel__color-block ${colors[0]}`}
          onClick={(e) => this.handleColorClick(e, colors[0])}
        >
        </button>
        <button
          className={`main-panel__color-block ${colors[1]}`}
          onClick={(e) => this.handleColorClick(e, colors[1])}
        >
        </button>
        <button
          className={`main-panel__color-block ${colors[2]}`}
          onClick={(e) => this.handleColorClick(e, colors[2])}
        >
        </button>
        <button
          className={`main-panel__color-block ${colors[3]}`}
          onClick={(e) => this.handleColorClick(e, colors[3])}
        >
        </button>
      </div>
    )
  }

  renderWaiting() {
    return (
      <div className="main-panel__winner-announcement-container">
        <h1>Waiting for results</h1>
      </div>
    )
  }

  renderStartButton() {
    return (
      <a
        onClick={(e) => this.handleStartClick(e)}
        className="main-panel__start-button"
      >
        <h1>Press to begin</h1>
      </a>
    )
  }

  renderMain(colors, winner, users, state) {
    switch(state) {
      case "waiting":
        return this.renderStartButton();
      case "in_progress":
        return this.renderColors(colors);
      case "winner_received":
        return this.renderWinner(winner, users);
      case "answer_selected":
        return this.renderWaiting();
      default:
        return;
    }
  }

  renderInstruction(instruction, state) {
    switch(state) {
      case "waiting":
        return "Waiting for round to begin";
      case "in_progress":
        return instruction;
      default:
        return;
    }
  }

  render() {
    const { colors, instruction, state, winner, users } = this.props;

    return (
      <div className="main-panel__container">
        <div className="main-panel__instruction-container">
          <h1 className="main-panel__color-instruction-text">
            { this.renderInstruction(instruction, state) }
          </h1>
        </div>
        <div className="main-panel__main-container">
          { this.renderMain(colors, winner, users, state) }
        </div>
      </div>
    );
  }
}

export default MainPanel;
