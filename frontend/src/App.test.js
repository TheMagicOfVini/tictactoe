import React from "react";
import { render } from "@testing-library/react";
import axios from "axios";

import App from "./App";

jest.mock("axios", () => ({ get: jest.fn(), post: jest.fn(), put: jest.fn() }));

beforeEach(() => {
  axios.get.mockReset();
  axios.get.mockResolvedValue({ data: [] });
});

it("renders the game and the scoreboard with axios mocked", () => {
  const app = render(<App />);

  expect(app.queryByTestId("game")).not.toBeNull();
  expect(app.queryByTestId("game-scoreboard")).not.toBeNull();
  expect(axios.get).toHaveBeenCalledTimes(1);
  expect(axios.get).toHaveBeenCalledWith("/api/v1/players.json");
});
