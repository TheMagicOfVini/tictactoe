# E5-S3 Front-end unit tests

**Epic:** E5: Developer Environment, Testing & Delivery

**Epic goal:** a developer can run, test and ship the app with minimal setup.

As a developer, I want automated tests for game logic and components, so that regressions are caught.

**Acceptance criteria**

- `calculateWinner` is tested for empty board, incomplete lines, and horizontal, vertical and diagonal wins.
- `Square` is tested for empty, "X" and "O" rendering, with a snapshot.
- `Board` is tested to render 9 squares.
- Every component test uses React Testing Library and mocks `axios`. No test sends a real request. `App` and `Scoreboard` render without crashing with the mock in place.
- A test shows that a click on a square before both names are set leaves the board unchanged (E1-S3).
- Tests show that the marks alternate: the first click places the first mover's mark, the next click places the other mark, and the status reads "`<name>`'s turn!" for the player due to move. A click on a claimed square changes neither the square nor the turn (E2-S3).
- Tests show that the status reads "Winner: `<name>`" for an O win and for an X win, and that a click after a win leaves the board unchanged (E2-S4).
- A test shows that the status reads "The game is a draw!" on a full board with no winner (E2-S5).
- Tests show that a click on "New Game" clears all 9 squares, keeps the player names and re-randomises who moves first (E2-S6).
- Tests show the Scoreboard API calls with `axios` mocked: on mount it sends `GET /api/v1/players.json` and renders one row per player; it sets the tab title to "Tic Tac Toe"; a failed fetch is logged and the table renders empty; a result sends `POST /api/v1/players/results` with `{ name, result }` (E3-S1, E3-S4).
- The Scoreboard test passes no `players` prop. The component reads no props; the test feeds it through the mocked `GET`. The test file defines each helper once.
