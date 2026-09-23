import React from "react";
import { render, fireEvent } from "@testing-library/react";

import { Board, Square, calculateWinner, playersSet } from "../components/Game.js";

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
