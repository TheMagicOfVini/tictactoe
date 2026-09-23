# Tic Tac Toe

## Table of Contents

- [Epics & User Stories](#epics--user-stories)
  - [E1: Player Setup](#e1-player-setup)
    - [E1-S1 Enter player names](#e1-s1-enter-player-names)
    - [E1-S2 Validate player names](#e1-s2-validate-player-names)
    - [E1-S3 Block play until players are set](#e1-s3-block-play-until-players-are-set)
  - [E2: Core Gameplay](#e2-core-gameplay)
    - [E2-S1 Render a 3×3 board](#e2-s1-render-a-33-board)
    - [E2-S2 Randomise who moves first](#e2-s2-randomise-who-moves-first)
    - [E2-S3 Take turns placing marks](#e2-s3-take-turns-placing-marks)
    - [E2-S4 Detect a win](#e2-s4-detect-a-win)
    - [E2-S5 Detect a draw](#e2-s5-detect-a-draw)
    - [E2-S6 Start a new game](#e2-s6-start-a-new-game)
  - [E3: Scoreboard (Front End)](#e3-scoreboard-front-end)
    - [E3-S1 View the scoreboard](#e3-s1-view-the-scoreboard)
    - [E3-S2 Record a result for a new player](#e3-s2-record-a-result-for-a-new-player)
    - [E3-S3 Record a result for a returning player](#e3-s3-record-a-result-for-a-returning-player)
    - [E3-S4 Link game outcome to scoreboard](#e3-s4-link-game-outcome-to-scoreboard)
  - [E4: Player Stats REST API (Back End)](#e4-player-stats-rest-api-back-end)
    - [E4-S1 Player data model](#e4-s1-player-data-model)
    - [E4-S2 List and fetch players](#e4-s2-list-and-fetch-players)
    - [E4-S3 Create a player](#e4-s3-create-a-player)
    - [E4-S4 Update a player's stats](#e4-s4-update-a-players-stats)
    - [E4-S5 Delete a player](#e4-s5-delete-a-player)
    - [E4-S6 Allow cross-origin requests](#e4-s6-allow-cross-origin-requests)
    - [E4-S7 Seed demo data](#e4-s7-seed-demo-data)
  - [E5: Developer Environment, Testing & Delivery](#e5-developer-environment-testing--delivery)
    - [E5-S1 Run locally without Docker](#e5-s1-run-locally-without-docker)
    - [E5-S2 Run in Docker](#e5-s2-run-in-docker)
    - [E5-S3 Front-end unit tests](#e5-s3-front-end-unit-tests)
    - [E5-S4 Back-end model tests](#e5-s4-back-end-model-tests)
    - [E5-S5 Hosted deployment](#e5-s5-hosted-deployment)
  - [E6: Hardening & Defect Fixes](#e6-hardening--defect-fixes)
    - [E6-S1 Fix crash on draw](#e6-s1-fix-crash-on-draw)
    - [E6-S2 Record each result exactly once](#e6-s2-record-each-result-exactly-once)
    - [E6-S3 Look up players by real id](#e6-s3-look-up-players-by-real-id)
    - [E6-S4 Return the updated player from PUT](#e6-s4-return-the-updated-player-from-put)
    - [E6-S5 Server-side result increments](#e6-s5-server-side-result-increments)
    - [E6-S6 Tighten name validation and match lifecycle](#e6-s6-tighten-name-validation-and-match-lifecycle)
    - [E6-S7 Restrict CORS and protect write endpoints](#e6-s7-restrict-cors-and-protect-write-endpoints)
    - [E6-S8 Expand automated test coverage](#e6-s8-expand-automated-test-coverage)
    - [E6-S9 Align docs and tooling versions](#e6-s9-align-docs-and-tooling-versions)

---

## Epics & User Stories

**tictactoe**: a React front end (`frontend/`) with a Ruby on Rails 5.2 REST API (`backend/`) that persists a win/loss/draw scoreboard in SQLite.

Stories in Epics 1–5 describe behaviour as implemented. Where the code falls short of its apparent intent, the gap is noted under the story and turned into a fix story in Epic 6.

| Epic | Theme | Main code |
|------|-------|-----------|
| E1 | Player setup | `frontend/src/components/Game.js` (`Board.handleSubmit`, `playersSet`, Popup form) |
| E2 | Gameplay | `Game.js` (`Square`, `Board`, `calculateWinner`, `resetBoard`) |
| E3 | Scoreboard (UI) | `frontend/src/components/Scoreboard.js` |
| E4 | Player stats API | `backend/app/controllers/api/v1/players_controller.rb`, `app/models/player.rb`, `config/routes.rb`, `db/` |
| E5 | Dev environment, testing & delivery | `Dockerfile`, `docker-compose.yml`, `entrypoint/*.sh`, `README.md`, `spec/`, `frontend/src/tests/` |
| E6 | Hardening & defect fixes | Cross-cutting |

---

## E1: Player Setup

**Goal:** two named players must be registered before a match can be played, so results can be attributed to them.

### E1-S1 Enter player names

As a player, I want to open a "Set Names" dialog and enter names for Player One and Player Two, so that the game knows who is playing.

**Acceptance criteria**

- A "Set Names" button opens a modal (`reactjs-popup`) containing two text inputs (`player_one`, `player_two`) and a Submit button.
- Submitting stores both names in board state without reloading the page (`event.preventDefault()`).
- Player One plays O and Player Two plays X.

### E1-S2 Validate player names

As a player, I want the game to reject an incomplete or duplicate pairing, so that results are never credited to a blank or ambiguous player.

**Acceptance criteria**

- Players are considered "set" only when both names are non-empty and different from each other (`playersSet`).
- Until players are set, the header reads "Set the names of both players." and no status line is shown.
- Once set, the header shows "`<Player One>` Vs. `<Player Two>`".

**Gaps:** whitespace-only names pass validation; comparison is case-sensitive ("bob" ≠ "Bob"); changing names mid-match does not reset the board (see E6).

### E1-S3 Block play until players are set

As a player, I want board clicks to be ignored until both players are named, so that every recorded game has two known participants.

**Acceptance criteria**

- Clicking a square while `playersSet` is false leaves the board unchanged.

---

## E2: Core Gameplay

**Goal:** two people can play a standard game of tic-tac-toe on one device.

### E2-S1 Render a 3×3 board

As a player, I want to see a 3×3 grid of squares, so that I can play the game.

**Acceptance criteria**

- The board (`data-testid="game-board"`) renders exactly 9 `Square` buttons (`data-testid="board-square"`) in three rows.
- An empty square shows no text; a claimed square shows "X" or "O".

### E2-S2 Randomise who moves first

As a player, I want the first move to be assigned at random, so that neither player has a built-in advantage.

**Acceptance criteria**

- On board creation and on every New Game, `xTurn` is set with a 50/50 random draw.

### E2-S3 Take turns placing marks

As a player, I want to click an empty square to place my mark and hand the turn to my opponent, so that play alternates correctly.

**Acceptance criteria**

- Clicking an empty square places "X" or "O" according to whose turn it is, then toggles the turn.
- Clicking an already-claimed square does nothing.
- The status line reads "`<name>`'s turn!" for the player due to move.

### E2-S4 Detect a win

As a player, I want the game to recognise three in a row, so that the winner is declared automatically.

**Acceptance criteria**

- `calculateWinner` checks all 8 lines (3 rows, 3 columns, 2 diagonals) and returns the mark that fills any of them, otherwise `null`.
- When a winner exists the status reads "Winner: `<name>`" and further clicks are ignored.

### E2-S5 Detect a draw

As a player, I want the game to declare a draw when the board fills with no winner, so that the match has a clear outcome.

**Acceptance criteria**

- When no square is null and there is no winner, the status reads "The game is a draw!".

**Gap:** the draw branch calls `this.child.scoreboard.updatePlayer(...)`, which is undefined and throws at runtime (see E6-S1).

### E2-S6 Start a new game

As a player, I want a "New Game" button, so that we can play again without reloading the page.

**Acceptance criteria**

- Clicking New Game clears all 9 squares and re-randomises who moves first.
- Player names are kept.

---

## E3: Scoreboard (Front End)

**Goal:** players can see an all-time record of results that survives page reloads.

### E3-S1 View the scoreboard

As a visitor, I want to see a table of every player's wins, losses and draws, so that I can compare records.

**Acceptance criteria**

- On mount, the Scoreboard fetches `GET /api/v1/players.json` and renders one row per player with Name, Wins, Losses, Draws.
- The browser tab title is set to "Tic Tac Toe".
- Fetch errors are logged to the console; the table renders empty.

### E3-S2 Record a result for a new player

As a first-time player, I want my result saved automatically when a match ends, so that I appear on the scoreboard without signing up.

**Acceptance criteria**

- If the player's name is not in the loaded list, `createPlayer` POSTs `/api/v1/players` with the name and a count of 1 in the matching column (win, loss or draw).
- The new player row is appended to the table from the API response.
- An unrecognised result value shows an alert and nothing is saved.

### E3-S3 Record a result for a returning player

As a returning player, I want my existing record updated, so that my stats accumulate across sessions.

**Acceptance criteria**

- If the name exists, `updatePlayer` increments the correct counter and PUTs `/api/v1/players/:id`.
- On success the row updates in place.

**Gap:** the player's database id is derived from their position in the list (`index + 1`), which breaks once any player is deleted or ids are non-contiguous (see E6-S3).

### E3-S4 Link game outcome to scoreboard

As a player, I want the winner credited with a win and the loser with a loss, so that the scoreboard reflects the match.

**Acceptance criteria**

- On an O win: Player One +1 win, Player Two +1 loss. On an X win: the reverse.
- On a draw: both players +1 draw.

**Gap:** updates are triggered from inside `render()`, so any re-render of a finished board re-submits results (see E6-S2).

---

## E4: Player Stats REST API (Back End)

**Goal:** a small JSON API stores players and their results.

### E4-S1 Player data model

As a developer, I want a Player record with name and result counters, so that stats can be persisted.

**Acceptance criteria**

- `players` table: `name` (string), `wins`, `losses`, `draws` (integers, default 0), timestamps.
- `name` is required (`validates_presence_of :name`).

### E4-S2 List and fetch players

As an API client, I want `GET /api/v1/players` and `GET /api/v1/players/:id`, so that I can display the scoreboard.

**Acceptance criteria**

- Index returns all players as a JSON array; show returns a single player.
- Unknown id returns 404 (`ActiveRecord::RecordNotFound`).

### E4-S3 Create a player

As an API client, I want `POST /api/v1/players`, so that new players can be added with an initial result.

**Acceptance criteria**

- Accepts `{ player: { name, wins, losses, draws } }`.
- Returns 201 with the created player and a Location header, or 422 with validation errors.

### E4-S4 Update a player's stats

As an API client, I want `PUT/PATCH /api/v1/players/:id`, so that result counters can be incremented.

**Acceptance criteria**

- Accepts permitted fields and persists them.
- Returns the updated player, or 422 on validation failure.

**Gap:** the action renders `@list` (never assigned), so success returns `null` and a failure would raise (see E6-S4).

### E4-S5 Delete a player

As an administrator, I want `DELETE /api/v1/players/:id`, so that unwanted entries can be removed.

**Acceptance criteria**

- Deletes the record and returns 204 No Content.

### E4-S6 Allow cross-origin requests

As a front-end developer, I want CORS enabled, so that the React dev server can call the API.

**Acceptance criteria**

- `rack-cors` allows all origins and GET/POST/PUT/PATCH/DELETE/OPTIONS/HEAD.
- The React dev server proxies API calls to `http://0.0.0.0:3001`.

### E4-S7 Seed demo data

As a developer, I want sample players loaded on setup, so that the scoreboard isn't empty in development.

**Acceptance criteria**

- `rake db:setup` runs `db/seeds.rb`, creating five sample players with preset records.

---

## E5: Developer Environment, Testing & Delivery

**Goal:** a developer can run, test and ship the app with minimal setup.

### E5-S1 Run locally without Docker

As a developer, I want documented steps to start both apps, so that I can work on the code.

**Acceptance criteria**

- README covers installing Node and Ruby/Rails, `bundle install`, `rake db:setup`, `rails server -p 3001`, and `npm start` for the front end on port 3000.

### E5-S2 Run in Docker

As a developer, I want a containerised environment, so that I don't have to install Ruby and Node on my machine.

**Acceptance criteria**

- `docker-compose up` builds a Ruby 2.6.1 image with Node 14 and exposes ports 3000 (front end), 3001 (API) and 8080 (code-server).
- `entrypoint/backend.sh` installs dependencies and starts Rails on `0.0.0.0:3001`; `entrypoint/frontend.sh` runs `npm install && npm start`.
- `entrypoint/codeserver.sh` starts a browser-based VS Code on port 8080, using the `PASSWORD` env var.

### E5-S3 Front-end unit tests

As a developer, I want automated tests for game logic and components, so that regressions are caught.

**Acceptance criteria**

- `calculateWinner` is tested for empty board, incomplete lines, and horizontal, vertical and diagonal wins.
- `Square` is tested for empty, "X" and "O" rendering, with a snapshot.
- `Board` is tested to render 9 squares; `Scoreboard` and `App` render without crashing.

### E5-S4 Back-end model tests

As a developer, I want RSpec model specs with FactoryBot/Faker data, so that model rules are verified.

**Acceptance criteria**

- `Player` responds to name/wins/losses/draws, is valid with factory data, and is invalid without a name.

### E5-S5 Hosted deployment

As a stakeholder, I want a live demo, so that people can try the game without installing anything.

**Acceptance criteria**

- The app is deployed to Heroku (URL in README), with the React build served alongside the API.

---

## E6: Hardening & Defect Fixes

**Goal:** close the gaps found while mapping the code. Each story is a proposed change, not existing behaviour.

### E6-S1 Fix crash on draw

As a player, I want a drawn game to record correctly, so that the app doesn't break when the board fills up.

**Acceptance criteria**

- The draw branch calls `this.scoreboard.current.updatePlayer(...)` (matching the win branches).
- A test covers a full-board draw and asserts both players receive +1 draw.

### E6-S2 Record each result exactly once

As a player, I want a finished game counted once, so that stats aren't inflated or duplicated.

**Acceptance criteria**

- Score updates move out of `render()` into the move handler (or `componentDidUpdate` guarded by a "result recorded" flag).
- Re-renders after a game ends make no further API calls.
- Two quick results for a brand-new player don't create duplicate rows.

### E6-S3 Look up players by real id

As a developer, I want the scoreboard to use each player's actual database id, so that updates hit the right record.

**Acceptance criteria**

- `playerIndex` returns the id from the matching player object, not the list position.
- Works when ids have gaps (e.g. after a delete).

### E6-S4 Return the updated player from PUT

As an API client, I want the update endpoint to return the saved player, so that clients can trust the response.

**Acceptance criteria**

- `update` renders `@player` / `@player.errors`.
- The stray `PUT /api/v1/players` route (no id, pointing at the non-namespaced controller) and the unused top-level `PlayersController` are removed.
- Unused `:result` / `:slug` params are removed from the permit lists.

### E6-S5 Server-side result increments

As a product owner, I want the server to increment counters, so that concurrent sessions can't overwrite each other's totals.

**Acceptance criteria**

- New endpoint (e.g. `POST /api/v1/players/:name/results` with `result: win|loss|draw`) finds-or-creates the player and increments atomically.
- Client stops sending absolute counter values.
- Player names are unique (DB index + model validation).

### E6-S6 Tighten name validation and match lifecycle

As a player, I want clean name handling, so that stats aren't split across near-duplicate names.

**Acceptance criteria**

- Names are trimmed; blank-after-trim is rejected; duplicate check is case-insensitive.
- The form shows an error message instead of silently doing nothing.
- Changing names resets the board.

### E6-S7 Restrict CORS and protect write endpoints

As a site operator, I want only the app's own origin to modify data, so that anyone on the internet can't edit or delete scoreboard entries.

**Acceptance criteria**

- CORS origins come from configuration instead of `*`.
- DELETE (and ideally direct PUT) require an admin credential or are removed from the public API.

### E6-S8 Expand automated test coverage

As a developer, I want request specs and interaction tests, so that API and gameplay behaviour are verified end to end.

**Acceptance criteria**

- RSpec request specs cover index, show, create (valid/invalid), update and destroy, using the existing `RequestSpecHelper`.
- React Testing Library tests cover: clicks ignored before names are set, alternating turns, win and draw status messages, New Game reset, and scoreboard API calls (with axios mocked).
- The Scoreboard test is rewritten; it currently passes a `players` prop the component ignores.

### E6-S9 Align docs and tooling versions

As a new contributor, I want consistent setup instructions, so that I can get running first time.

**Acceptance criteria**

- README Ruby version matches the Gemfile/Dockerfile (2.6.1, not 2.5.3).
- README clone URL points at this repository.
- Committed SQLite databases, `development.log` and the `.seeds.rb.swp` swap file are removed and git-ignored.
