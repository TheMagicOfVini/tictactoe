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
  axios.post.mockImplementation((url, body) => Promise.resolve({ data: body.player }));
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

describe("Board name form", () => {
  const header = board => board.container.querySelector(".players").textContent.trim();
  const errorText = board => {
    const error = board.container.ownerDocument.querySelector(".name-error");
    return error ? error.textContent : null;
  };
  const filledSquares = board =>
    board.queryAllByTestId("board-square").filter(square => square.innerHTML !== "").length;

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

describe("Board draw", () => {
  //The first mover gets 0, 2, 3, 7, 8 and the second mover gets 1, 4, 5, 6.
  //Neither set has a line, so the game is a draw no matter who moves first.
  const drawOrder = [0, 1, 2, 4, 3, 5, 7, 6, 8];
  const playDraw = board => {
    const squares = board.queryAllByTestId("board-square");
    drawOrder.forEach(i => fireEvent.click(squares[i]));
  };
  const status = board => board.container.querySelector(".status").textContent.trim();

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

    const posted = axios.post.mock.calls.map(call => call[1].player);
    expect(posted).toHaveLength(2);
    expect(posted).toEqual(
      expect.arrayContaining([
        { name: "Bob", wins: 0, losses: 0, draws: 1 },
        { name: "Alice", wins: 0, losses: 0, draws: 1 }
      ])
    );
    expect(axios.put).not.toHaveBeenCalled();
  });
});
