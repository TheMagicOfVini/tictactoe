import React from "react";
import { render } from "@testing-library/react";
import axios from "axios";

import Scoreboard from "../components/Scoreboard.js";

jest.mock("axios", () => ({ get: jest.fn(), post: jest.fn(), put: jest.fn() }));

//The ids have gaps and are not sorted, as after a delete
const loadedPlayers = [
  { id: 7, name: "Jeff", wins: 10, losses: 2, draws: 4 },
  { id: 3, name: "Steve", wins: 20, losses: 5, draws: 10 },
  { id: 12, name: "Bob", wins: 0, losses: 2, draws: 1 }
];

beforeEach(() => {
  axios.get.mockReset();
  axios.post.mockReset();
  axios.put.mockReset();
  axios.get.mockResolvedValue({ data: loadedPlayers.map(player => ({ ...player })) });
  axios.put.mockResolvedValue({ data: null });
});

const playerMocks = {
  players: [
      { id: 1, name: "Jeff", wins: 10, losses: 2, draws: 4 },
      { id: 2, name: "Steve", wins: 20, losses: 5, draws: 10 },
      { id: 3, name: "Bob", wins: 0, losses: 2, draws: 1 },
    ]
};

describe("Scoreboard: ", () => {
  it("should render", () => {
    const component = render(<Scoreboard {...playerMocks} />);

    expect(component.queryByTestId("game-scoreboard")).not.toBeNull();
  });
});

describe("Scoreboard returning player", () => {
  //The jsdom in these tests has no MutationObserver, so findBy* and waitFor fail.
  //Let the mocked axios promises settle instead.
  const flushPromises = () => new Promise(resolve => setImmediate(resolve));
  const renderLoaded = async () => {
    const ref = React.createRef();
    const component = render(<Scoreboard ref={ref} />);
    await flushPromises();
    return { ref, component };
  };
  const rows = component =>
    Array.from(component.container.querySelectorAll("tr"))
      .slice(1) //Skip the header row
      .map(row => Array.from(row.querySelectorAll("td")).map(cell => cell.textContent.trim()));

  it("Should return the id of the matching player", async () => {
    const { ref } = await renderLoaded();

    expect(ref.current.playerIndex("Steve")).toBe(3);
    expect(ref.current.playerIndex("Jeff")).toBe(7);
    expect(ref.current.playerIndex("Nobody")).toBeNull();
  });
  it("Should PUT the counters of the matching player to its id", async () => {
    const { ref } = await renderLoaded();

    ref.current.updatePlayer("Steve", "win");
    await flushPromises();

    expect(axios.put).toHaveBeenCalledTimes(1);
    expect(axios.put).toHaveBeenCalledWith("/api/v1/players/3", {
      player: { wins: 21, losses: 5, draws: 10 }
    });
    expect(axios.post).not.toHaveBeenCalled();
  });
  it("Should update only the row of the matching player", async () => {
    const { ref, component } = await renderLoaded();

    ref.current.updatePlayer("Steve", "draw");
    await flushPromises();

    expect(rows(component)).toEqual([
      ["Jeff", "10", "2", "4"],
      ["Steve", "20", "5", "11"],
      ["Bob", "0", "2", "1"]
    ]);
  });
});
