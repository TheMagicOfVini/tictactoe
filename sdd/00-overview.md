# Tic Tac Toe: Spec Overview

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

## Specs

### E1: Player Setup

- [01 E1-S1 Enter player names](01-e1-s1-enter-player-names.md)
- [02 E1-S2 Validate player names](02-e1-s2-validate-player-names.md)
- [03 E1-S3 Block play until players are set](03-e1-s3-block-play-until-players-are-set.md)

### E2: Core Gameplay

- [04 E2-S1 Render a 3×3 board](04-e2-s1-render-a-3x3-board.md)
- [05 E2-S2 Randomise who moves first](05-e2-s2-randomise-who-moves-first.md)
- [06 E2-S3 Take turns placing marks](06-e2-s3-take-turns-placing-marks.md)
- [07 E2-S4 Detect a win](07-e2-s4-detect-a-win.md)
- [08 E2-S5 Detect a draw](08-e2-s5-detect-a-draw.md)
- [09 E2-S6 Start a new game](09-e2-s6-start-a-new-game.md)

### E3: Scoreboard (Front End)

- [10 E3-S1 View the scoreboard](10-e3-s1-view-the-scoreboard.md)
- [11 E3-S2 Record a result for a new player](11-e3-s2-record-a-result-for-a-new-player.md)
- [12 E3-S3 Record a result for a returning player](12-e3-s3-record-a-result-for-a-returning-player.md)
- [13 E3-S4 Link game outcome to scoreboard](13-e3-s4-link-game-outcome-to-scoreboard.md)

### E4: Player Stats REST API (Back End)

- [14 E4-S1 Player data model](14-e4-s1-player-data-model.md)
- [15 E4-S2 List and fetch players](15-e4-s2-list-and-fetch-players.md)
- [16 E4-S3 Create a player](16-e4-s3-create-a-player.md)
- [17 E4-S4 Update a player's stats](17-e4-s4-update-a-player-s-stats.md)
- [18 E4-S5 Delete a player](18-e4-s5-delete-a-player.md)
- [19 E4-S6 Allow cross-origin requests](19-e4-s6-allow-cross-origin-requests.md)
- [20 E4-S7 Seed demo data](20-e4-s7-seed-demo-data.md)

### E5: Developer Environment, Testing & Delivery

- [21 E5-S1 Run locally without Docker](21-e5-s1-run-locally-without-docker.md)
- [22 E5-S2 Run in Docker](22-e5-s2-run-in-docker.md)
- [23 E5-S3 Front-end unit tests](23-e5-s3-front-end-unit-tests.md)
- [24 E5-S4 Back-end model tests](24-e5-s4-back-end-model-tests.md)
- [25 E5-S5 Hosted deployment](25-e5-s5-hosted-deployment.md)

### E6: Hardening & Defect Fixes

- [26 E6-S1 Fix crash on draw](26-e6-s1-fix-crash-on-draw.md)
- [27 E6-S2 Record each result exactly once](27-e6-s2-record-each-result-exactly-once.md)
- [28 E6-S3 Look up players by real id](28-e6-s3-look-up-players-by-real-id.md)
- [29 E6-S4 Return the updated player from PUT](29-e6-s4-return-the-updated-player-from-put.md)
- [30 E6-S5 Server-side result increments](30-e6-s5-server-side-result-increments.md)
- [31 E6-S6 Tighten name validation and match lifecycle](31-e6-s6-tighten-name-validation-and-match-lifecycle.md)
- [32 E6-S7 Restrict CORS and protect write endpoints](32-e6-s7-restrict-cors-and-protect-write-endpoints.md)
- [33 E6-S8 Expand automated test coverage](33-e6-s8-expand-automated-test-coverage.md)
- [34 E6-S9 Align docs and tooling versions](34-e6-s9-align-docs-and-tooling-versions.md)
- [35 E6-S10 Record concurrent results without a lock error](35-e6-s10-record-concurrent-results-without-a-lock-error.md)
