import React from "react";
import axios from "axios";
import "./Scoreboard.css";

class Scoreboard extends React.Component {
  _state = {
    players: []
  };
  get state() {
    return this._state;
  }
  set state(value) {
    this._state = value;
  }
  componentDidMount() {
    this.downloadPlayers();
    document.title = "Tic Tac Toe";
  }
  downloadPlayers() {
    axios
      .get("/api/v1/players.json")
      .then(response => {
        this.setState({
          players: response.data
        });
      })
      .catch(error => console.log(error));
  }
  //Send one result to the server. The server finds or creates the player by
  //name and adds 1 to the counter, so two quick results both count.
  updatePlayer(name, result) {
    return axios
      .post("/api/v1/players/results", { name, result })
      .then(response => this.savePlayer(response.data))
      .catch(error => console.log(error));
  }

  //Put the saved player in the table: replace the row with the same id, or append it
  savePlayer(player) {
    this.setState(state => {
      const players = state.players.slice();
      const row = players.findIndex(other => other.id === player.id);
      if (row === -1) {
        players.push(player);
      } else {
        players[row] = player;
      }
      return { players };
    });
  }

  render() {
    return (
      <>
        <h4 align="left">Scoreboard</h4>
        <div className="card-score" data-testid="game-scoreboard">
          <table className="blueTable">
            <tbody>
            <tr>
              <th className="row-name">Name</th>
              <th>Wins</th>
              <th>Losses</th>
              <th>Draws</th>
            </tr>
            {this.state.players.map(obj => (
              <tr key={obj.id}>
                <td> {obj.name} </td>
                <td> {obj.wins} </td>
                <td> {obj.losses} </td>
                <td> {obj.draws} </td>
              </tr>
            ))}
            </tbody>
          </table>
        </div>
      </>
    );
  }
}

export default Scoreboard;
