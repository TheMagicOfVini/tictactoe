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
const loadedRows = [
  ["Jeff", "10", "2", "4"],
  ["Steve", "20", "5", "10"],
  ["Bob", "0", "2", "1"]
];

//The jsdom in these tests has no MutationObserver, so findBy* and waitFor fail.
//Let the mocked axios promises settle instead.
const flushPromises = () => new Promise(resolve => setImmediate(resolve));

//Render the Scoreboard with a ref and let the mocked GET return
const renderLoaded = async () => {
  const ref = React.createRef();
  const component = render(<Scoreboard ref={ref} />);
  await flushPromises();
  return { ref, component };
};

//The table body as text, without the header row
const rows = component =>
  Array.from(component.container.querySelectorAll("tr"))
    .slice(1)
    .map(row => Array.from(row.querySelectorAll("td")).map(cell => cell.textContent.trim()));

beforeEach(() => {
  axios.get.mockReset();
  axios.post.mockReset();
  axios.put.mockReset();
  axios.get.mockResolvedValue({ data: loadedPlayers.map(player => ({ ...player })) });
  //The results endpoint returns the saved player: the loaded row plus 1 in the counter
  axios.post.mockImplementation((url, { name, result }) => {
    const known = loadedPlayers.find(player => player.name === name);
    const player = known ? { ...known } : { id: 99, name, wins: 0, losses: 0, draws: 0 };
    const column = { win: "wins", loss: "losses", draw: "draws" }[result];
    player[column] += 1;
    return Promise.resolve({ data: player });
  });
});

describe("Scoreboard on mount", () => {
  it("Should render", async () => {
    const { component } = await renderLoaded();

    expect(component.queryByTestId("game-scoreboard")).not.toBeNull();
  });
  it("Should fetch the players and render one row each", async () => {
    const { component } = await renderLoaded();

    expect(axios.get).toHaveBeenCalledTimes(1);
    expect(axios.get).toHaveBeenCalledWith("/api/v1/players.json");
    expect(rows(component)).toEqual(loadedRows);
  });
  it("Should set the tab title", async () => {
    document.title = "";

    await renderLoaded();

    expect(document.title).toBe("Tic Tac Toe");
  });
  it("Should log a failed fetch and render an empty table", async () => {
    const error = new Error("Network Error");
    axios.get.mockRejectedValue(error);
    const log = jest.spyOn(console, "log").mockImplementation(() => {});

    const { component } = await renderLoaded();

    expect(log).toHaveBeenCalledWith(error);
    expect(component.queryByTestId("game-scoreboard")).not.toBeNull();
    expect(rows(component)).toEqual([]);
    log.mockRestore();
  });
});

describe("Scoreboard returning player", () => {
  it("Should send the same request for a known player and a new player", async () => {
    const { ref } = await renderLoaded();

    ref.current.updatePlayer("Steve", "win");
    ref.current.updatePlayer("Ann", "win");
    await flushPromises();

    expect(axios.post).toHaveBeenCalledTimes(2);
    expect(axios.post).toHaveBeenNthCalledWith(1, "/api/v1/players/results", { name: "Steve", result: "win" });
    expect(axios.post).toHaveBeenNthCalledWith(2, "/api/v1/players/results", { name: "Ann", result: "win" });
    expect(axios.put).not.toHaveBeenCalled();
  });
  it("Should replace the row with the same id", async () => {
    const { ref, component } = await renderLoaded();

    ref.current.updatePlayer("Steve", "draw");
    await flushPromises();

    expect(rows(component)).toEqual([
      ["Jeff", "10", "2", "4"],
      ["Steve", "20", "5", "11"],
      ["Bob", "0", "2", "1"]
    ]);
  });
  it("Should count two quick results for a known player", async () => {
    //The test decides when each request returns
    const resolvers = [];
    axios.post.mockImplementation(
      () => new Promise(resolve => resolvers.push(resolve))
    );
    const { ref, component } = await renderLoaded();

    ref.current.updatePlayer("Steve", "win");
    ref.current.updatePlayer("Steve", "win");
    await flushPromises();
    //Both results go to the server before any response returns
    expect(axios.post).toHaveBeenCalledTimes(2);
    expect(axios.post.mock.calls.map(call => call[1])).toEqual([
      { name: "Steve", result: "win" },
      { name: "Steve", result: "win" }
    ]);

    resolvers[0]({ data: { id: 3, name: "Steve", wins: 21, losses: 5, draws: 10 } });
    await flushPromises();
    resolvers[1]({ data: { id: 3, name: "Steve", wins: 22, losses: 5, draws: 10 } });
    await flushPromises();

    expect(rows(component)).toEqual([
      ["Jeff", "10", "2", "4"],
      ["Steve", "22", "5", "10"],
      ["Bob", "0", "2", "1"]
    ]);
    expect(axios.put).not.toHaveBeenCalled();
  });
});

describe("Scoreboard new player", () => {
  it("Should append a new player once", async () => {
    axios.get.mockResolvedValue({ data: [] });
    //The test decides when each request returns
    const resolvers = [];
    axios.post.mockImplementation(
      () => new Promise(resolve => resolvers.push(resolve))
    );
    const { ref, component } = await renderLoaded();

    ref.current.updatePlayer("Ann", "win");
    ref.current.updatePlayer("Ann", "win");
    await flushPromises();
    expect(axios.post).toHaveBeenCalledTimes(2);

    resolvers[0]({ data: { id: 5, name: "Ann", wins: 1, losses: 0, draws: 0 } });
    await flushPromises();
    expect(rows(component)).toEqual([["Ann", "1", "0", "0"]]);

    resolvers[1]({ data: { id: 5, name: "Ann", wins: 2, losses: 0, draws: 0 } });
    await flushPromises();

    expect(rows(component)).toEqual([["Ann", "2", "0", "0"]]);
    expect(axios.put).not.toHaveBeenCalled();
  });
  it("Should log a failed result, keep the table and show no alert", async () => {
    const error = new Error("Request failed with status code 422");
    axios.post.mockRejectedValueOnce(error);
    const alert = jest.spyOn(window, "alert").mockImplementation(() => {});
    const log = jest.spyOn(console, "log").mockImplementation(() => {});
    const { ref, component } = await renderLoaded();
    expect(rows(component)).toEqual(loadedRows);

    ref.current.updatePlayer("Ann", "tie");
    await flushPromises();

    expect(axios.post).toHaveBeenCalledWith("/api/v1/players/results", { name: "Ann", result: "tie" });
    expect(rows(component)).toEqual(loadedRows);
    expect(log).toHaveBeenCalledWith(error);
    expect(alert).not.toHaveBeenCalled();
    alert.mockRestore();
    log.mockRestore();
  });
});
