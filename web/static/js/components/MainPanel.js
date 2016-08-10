import React, { Component } from "react";

class MainPanel extends Component {
  handleColorClick(e, color) {
    e.preventDefault();
    const { onColorClick } = this.props;

    onColorClick(color)
  }

  renderWinner(winner) {
    return (
      <div className="main-panel__winner-announcement-container">
        <h1>{winner} is the winner</h1>
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

  renderMain(colors, winner, state) {
    switch(state) {
      case "in_progress":
        return this.renderColors(colors);
      case "winner_received":
        return this.renderWinner(winner);
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
    const { colors, instruction, state, winner } = this.props;

    return (
      <div className="main-panel__container">
        <div className="main-panel__instruction-container">
          <h1 className="main-panel__color-instruction-text">
            { this.renderInstruction(instruction, state) }
          </h1>
        </div>
        <div className="main-panel__main-container">
          { this.renderMain(colors, winner, state) }
        </div>
      </div>
    );
  }
}

export default MainPanel;
