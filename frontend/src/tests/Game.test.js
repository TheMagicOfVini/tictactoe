import React from "react";
import { render, fireEvent } from "@testing-library/react";
import axios from "axios";

import { Board, Square, calculateWinner, playersSet } from "../components/Game.js";

jest.mock("axios", () => ({ get: jest.fn(), post: jest.fn(), put: jest.fn() }));

beforeEach(() => {
  axios.get.mockReset();
  axios.post.mockReset();
  axios.put.mockReset();
  axios.get.mockResolvedValue({ data: [] });
  //The results endpoint returns the saved player
  axios.post.mockImplementation((url, body) =>
    Promise.resolve({
      data: {
        id: axios.post.mock.calls.length,
        name: body.name,
        wins: body.result === "win" ? 1 : 0,
        losses: body.result === "loss" ? 1 : 0,
        draws: body.result === "draw" ? 1 : 0
      }
    })
  );
  axios.put.mockResolvedValue({ data: {} });
});

const submitNames = (board, playerOne, playerTwo) => {
  const findForm = () => board.container.ownerDocument.querySelector("form");
  if (!findForm()) {
    //The popup stays open after a submit, so open it only once
    fireEvent.click(board.getByText("Set Names"));
  }
  const form = findForm();
  form.elements.namedItem("player_one").value = playerOne;
  form.elements.namedItem("player_two").value = playerTwo;
  fireEvent.submit(form);
};

//Read the board: the header, the status line and the marks of the 9 squares
const header = board => board.container.querySelector(".players").textContent.trim();
const status = board => board.container.querySelector(".status").textContent.trim();
const squares = board => board.queryAllByTestId("board-square");
const marks = board => squares(board).map(square => square.innerHTML);
const filledSquares = board => marks(board).filter(mark => mark !== "").length;
//Board moves X first when Math.random() < 0.5. Returns the spy.
const firstMover = mark =>
  jest.spyOn(Math, "random").mockReturnValue(mark === "X" ? 0.1 : 0.9);

afterEach(() => {
  jest.restoreAllMocks();
});

describe("calculateWinner", () => {
  describe("Unfinished game", () => {
    it("Should not have a winner with empty board", () => {
      const board = ["", "", "", "", "", "", "", "", ""];
      const winner = calculateWinner(board);

      expect(winner).toBe(null);
    });
    it("Should not have a winner without a completed line", () => {
      const board = ["X", "O", "", "X", "O", "", "", "", "X"];
      const winner = calculateWinner(board);

      expect(winner).toBe(null);
    });
  });
  describe("Wins: ", () => {
    it("Should be a Win if line is horizontal", () => {
      const board = ["O", "O", "X", "X", "O", "O", "X", "X", "X"];
      const winner = calculateWinner(board);

      expect(winner).toBe("X");
    });
    it("Should be a Win if line is completed vertical", () => {
      const board = ["O", "O", "", "X", "O", "O", "X", "O", "X"];
      const winner = calculateWinner(board);

      expect(winner).toBe("O");
    });
    it("Should be a Win if line is completed diagonal", () => {
      const board = ["O", "x", "O", "X", "O", "", "X", "", "O"];
      const winner = calculateWinner(board);

      expect(winner).toBe("O");
    });
  });
});

describe("Square", () => {
  const renderSquare = squareProps => {
    const elem = render(<Square {...squareProps} />);
    return elem.queryByTestId("board-square");
  };

  it("Should render", () => {
    const square = renderSquare();

    expect(square).toMatchSnapshot();
  });
  it("Should display nothing if not set", () => {
    const square = renderSquare();

    expect(square.innerHTML).toBe("");
  });
  it("Should display O", () => {
    const square = renderSquare({ value: "O" });

    expect(square.innerHTML).toBe("O");
  });
  it("Should display X", () => {
    const square = renderSquare({ value: "X" });

    expect(square.innerHTML).toBe("X");
  });
});

describe("Board", () => {
  const renderBoard = () => render(<Board />);

  it("Should render", () => {
    const board = renderBoard().queryByTestId("game-board");

    expect(board).not.toBeNull();
  });
  it("Should have 9 squares", () => {
    const board = renderBoard();
    const squares = board.queryAllByTestId("board-square");

    expect(squares.length).toBe(9);
  });
});

describe("playersSet", () => {
  it("Should accept two different names", () => {
    expect(playersSet("Bob", "Alice")).toBe(true);
  });
  it("Should reject a blank name", () => {
    expect(playersSet("", "Alice")).toBe(false);
  });
  it("Should reject a whitespace-only name", () => {
    expect(playersSet("   ", "Alice")).toBe(false);
  });
  it("Should reject names that differ only in case", () => {
    expect(playersSet("bob", "Bob")).toBe(false);
  });
  it("Should reject names that differ only in surrounding spaces", () => {
    expect(playersSet("Bob ", "Bob")).toBe(false);
  });
});

describe("Board before names", () => {
  it("Should ignore a click before the names are set", () => {
    const board = render(<Board />);
    fireEvent.click(squares(board)[0]);

    expect(filledSquares(board)).toBe(0);
    expect(header(board)).toBe("Set the names of both players.");
    expect(status(board)).toBe("");
  });
});

describe("Board name form", () => {
  const errorText = board => {
    const error = board.container.ownerDocument.querySelector(".name-error");
    return error ? error.textContent : null;
  };

  it("Should trim the names before it shows them", () => {
    const board = render(<Board />);
    submitNames(board, "  Bob ", " Alice  ");

    expect(header(board)).toBe("Bob Vs. Alice");
    expect(errorText(board)).toBeNull();
  });
  it("Should show an error for a whitespace-only name", () => {
    const board = render(<Board />);
    submitNames(board, "   ", "Alice");

    expect(header(board)).toBe("Set the names of both players.");
    expect(errorText(board)).toBe("Both players need a name.");
  });
  it("Should show an error for names that differ only in case", () => {
    const board = render(<Board />);
    submitNames(board, "bob", "Bob");

    expect(header(board)).toBe("Set the names of both players.");
    expect(errorText(board)).toBe("The players need different names.");
  });
  it("Should keep the current names when a pair is rejected", () => {
    const board = render(<Board />);
    submitNames(board, "Bob", "Alice");
    submitNames(board, "", "Alice");

    expect(header(board)).toBe("Bob Vs. Alice");
    expect(errorText(board)).toBe("Both players need a name.");
  });
  it("Should reset the board when the names change", () => {
    const board = render(<Board />);
    submitNames(board, "Bob", "Alice");
    fireEvent.click(board.queryAllByTestId("board-square")[0]);
    expect(filledSquares(board)).toBe(1);

    submitNames(board, "Carol", "Alice");

    expect(filledSquares(board)).toBe(0);
  });
  it("Should keep the board when the same names are submitted again", () => {
    const board = render(<Board />);
    submitNames(board, "Bob", "Alice");
    fireEvent.click(board.queryAllByTestId("board-square")[0]);

    submitNames(board, "Bob", "Alice");

    expect(filledSquares(board)).toBe(1);
  });
});

describe("Board turns", () => {
  //O is Player One's mark and X is Player Two's mark
  it("Should place X then O and name the player due to move when X moves first", () => {
    firstMover("X");
    const board = render(<Board />);
    submitNames(board, "Bob", "Alice");
    expect(status(board)).toBe("Alice's turn!");

    fireEvent.click(squares(board)[0]);
    expect(marks(board)[0]).toBe("X");
    expect(status(board)).toBe("Bob's turn!");

    fireEvent.click(squares(board)[1]);
    expect(marks(board)[1]).toBe("O");
    expect(status(board)).toBe("Alice's turn!");
  });
  it("Should place O then X and name the player due to move when O moves first", () => {
    firstMover("O");
    const board = render(<Board />);
    submitNames(board, "Bob", "Alice");
    expect(status(board)).toBe("Bob's turn!");

    fireEvent.click(squares(board)[0]);
    expect(marks(board)[0]).toBe("O");
    expect(status(board)).toBe("Alice's turn!");

    fireEvent.click(squares(board)[1]);
    expect(marks(board)[1]).toBe("X");
    expect(status(board)).toBe("Bob's turn!");
  });
  it("Should ignore a click on a claimed square", () => {
    firstMover("X");
    const board = render(<Board />);
    submitNames(board, "Bob", "Alice");
    fireEvent.click(squares(board)[0]);

    fireEvent.click(squares(board)[0]);

    expect(marks(board)[0]).toBe("X");
    expect(filledSquares(board)).toBe(1);
    expect(status(board)).toBe("Bob's turn!");
  });
});

describe("Board new game", () => {
  const newGame = board => fireEvent.click(board.getByText("New Game"));

  it("Should clear the squares and keep the names", () => {
    firstMover("X");
    const board = render(<Board />);
    submitNames(board, "Bob", "Alice");
    fireEvent.click(squares(board)[0]);
    fireEvent.click(squares(board)[4]);
    expect(filledSquares(board)).toBe(2);

    newGame(board);

    expect(filledSquares(board)).toBe(0);
    expect(header(board)).toBe("Bob Vs. Alice");
    expect(status(board)).toBe("Alice's turn!");
  });
  it("Should re-randomise who moves first", () => {
    const random = firstMover("X");
    const board = render(<Board />);
    submitNames(board, "Bob", "Alice");
    fireEvent.click(squares(board)[0]);
    expect(marks(board)[0]).toBe("X");

    random.mockReturnValue(0.9);
    newGame(board);
    fireEvent.click(squares(board)[0]);

    expect(marks(board)[0]).toBe("O");
  });
  it("Should send no request when the game is not finished", () => {
    const board = render(<Board />);
    submitNames(board, "Bob", "Alice");
    fireEvent.click(squares(board)[0]);

    newGame(board);

    expect(axios.post).not.toHaveBeenCalled();
  });
});

describe("Board draw", () => {
  //The first mover gets 0, 2, 3, 7, 8 and the second mover gets 1, 4, 5, 6.
  //Neither set has a line, so the game is a draw no matter who moves first.
  const drawOrder = [0, 1, 2, 4, 3, 5, 7, 6, 8];
  const playDraw = board => drawOrder.forEach(i => fireEvent.click(squares(board)[i]));

  it("Should show the draw status without an error", () => {
    const board = render(<Board />);
    submitNames(board, "Bob", "Alice");

    expect(() => playDraw(board)).not.toThrow();
    expect(status(board)).toBe("The game is a draw!");
  });
  it("Should give each player exactly one draw", () => {
    const board = render(<Board />);
    submitNames(board, "Bob", "Alice");
    playDraw(board);

    expect(axios.post).toHaveBeenCalledTimes(2);
    expect(axios.post.mock.calls).toEqual(
      expect.arrayContaining([
        ["/api/v1/players/results", { name: "Bob", result: "draw" }],
        ["/api/v1/players/results", { name: "Alice", result: "draw" }]
      ])
    );
    expect(axios.put).not.toHaveBeenCalled();
  });
  it("Should send one results request for each player, with only name and result", () => {
    const board = render(<Board />);
    submitNames(board, "Bob", "Alice");
    playDraw(board);

    expect(axios.post).toHaveBeenCalledTimes(2);
    axios.post.mock.calls.forEach(([url, body]) => {
      expect(url).toBe("/api/v1/players/results");
      expect(Object.keys(body).sort()).toEqual(["name", "result"]);
    });
    expect(axios.post.mock.calls.map(call => call[1].name).sort()).toEqual(["Alice", "Bob"]);
    expect(axios.put).not.toHaveBeenCalled();
  });
});

describe("Board win", () => {
  //The first mover gets the top row: 0, 1, 2. The second mover gets 3, 4.
  const winOrder = [0, 3, 1, 4, 2];
  const playWin = board => winOrder.forEach(i => fireEvent.click(squares(board)[i]));
  const posted = () =>
    axios.post.mock.calls.map(([url, body]) => {
      expect(url).toBe("/api/v1/players/results");
      return body;
    });

  it("Should show the winner status on an O win", () => {
    firstMover("O");
    const board = render(<Board />);
    submitNames(board, "Bob", "Alice");
    playWin(board);

    expect(status(board)).toBe("Winner: Bob");
  });
  it("Should show the winner status on an X win", () => {
    firstMover("X");
    const board = render(<Board />);
    submitNames(board, "Bob", "Alice");
    playWin(board);

    expect(status(board)).toBe("Winner: Alice");
  });
  it("Should ignore a click after a win", () => {
    firstMover("O");
    const board = render(<Board />);
    submitNames(board, "Bob", "Alice");
    playWin(board);

    fireEvent.click(squares(board)[8]);

    expect(marks(board)[8]).toBe("");
    expect(filledSquares(board)).toBe(winOrder.length);
    expect(status(board)).toBe("Winner: Bob");
  });
  it("Should give Player One a win and Player Two a loss on an O win", () => {
    firstMover("O");
    const board = render(<Board />);
    submitNames(board, "Bob", "Alice");
    playWin(board);

    expect(posted()).toHaveLength(2);
    expect(posted()).toEqual(
      expect.arrayContaining([
        { name: "Bob", result: "win" },
        { name: "Alice", result: "loss" }
      ])
    );
  });
  it("Should give Player One a loss and Player Two a win on an X win", () => {
    firstMover("X");
    const board = render(<Board />);
    submitNames(board, "Bob", "Alice");
    playWin(board);

    expect(posted()).toHaveLength(2);
    expect(posted()).toEqual(
      expect.arrayContaining([
        { name: "Bob", result: "loss" },
        { name: "Alice", result: "win" }
      ])
    );
  });
  it("Should send no request when the board renders again after the game ends", async () => {
    firstMover("O");
    const board = render(<Board />);
    submitNames(board, "Bob", "Alice");
    playWin(board);
    //Let the results requests return, so both players are known to the Scoreboard
    await new Promise(resolve => setImmediate(resolve));

    submitNames(board, "Bob", "Alice");
    submitNames(board, "", "Alice");
    fireEvent.click(squares(board)[8]);
    await new Promise(resolve => setImmediate(resolve));

    expect(axios.post).toHaveBeenCalledTimes(2);
    expect(axios.put).not.toHaveBeenCalled();
  });
});
