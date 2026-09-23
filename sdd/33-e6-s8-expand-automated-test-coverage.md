# E6-S8 Expand automated test coverage

**Epic:** E6: Hardening & Defect Fixes

**Epic goal:** close the gaps found while mapping the code. Each story is a proposed change, not existing behaviour.

As a developer, I want request specs and interaction tests, so that API and gameplay behaviour are verified end to end.

**Acceptance criteria**

- RSpec request specs cover index, show, create (valid/invalid), update and destroy, using the existing `RequestSpecHelper` (E5-S4):
  - Index returns 200 and a JSON array with every player and its fields.
  - Show returns 200 and the player. An unknown id raises `ActiveRecord::RecordNotFound`, which Rails maps to 404.
  - Create returns 201, the player and a `Location` header. A blank name returns 422 and the errors, and creates no player.
  - Update and destroy keep the specs of E6-S7.
- React Testing Library tests cover: clicks ignored before names are set, alternating turns, win and draw status messages, New Game reset, and scoreboard API calls (with axios mocked) (E5-S3):
  - A click before the names are set leaves the board unchanged.
  - The marks alternate, the status names the player due to move, and a click on a claimed square does nothing.
  - The status reads "Winner: `<name>`" after a win, and clicks after a win are ignored.
  - The status reads "The game is a draw!" after a draw.
  - New Game clears the squares, keeps the names and re-randomises the first mover.
  - The Scoreboard sends `GET /api/v1/players.json` on mount, sets the tab title, logs a failed fetch and renders empty, and sends `POST /api/v1/players/results` for a result.
  - Every component test, `App.test.js` included, mocks `axios`.
- The Scoreboard test is rewritten; it currently passes a `players` prop the component ignores (E5-S3). The test feeds the component through the mocked `GET` and defines each helper once.
