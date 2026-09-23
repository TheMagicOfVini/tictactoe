# TODO

Gaps found while mapping the code. Each item names the spec it was found in and the Epic 6 story that fixes it.

## E1-S2 Validate player names (02-e1-s2-validate-player-names.md)

- [x] whitespace-only names pass validation, and surrounding spaces are kept ("Bob " ≠ "Bob") (see E6-S6).
- [x] comparison is case-sensitive ("bob" ≠ "Bob") (see E6-S6).
- [x] invalid names are accepted silently; the form shows no error (see E6-S6).
- [x] changing names mid-match does not reset the board (see E6-S6).

## E2-S5 Detect a draw (08-e2-s5-detect-a-draw.md)

- [x] the draw branch calls `this.child.scoreboard.updatePlayer(...)`, which is undefined and throws at runtime (see [E6-S1](26-e6-s1-fix-crash-on-draw.md)).
- [x] no test covers a full-board draw, its status message or the draw recorded for each player (see [E6-S1](26-e6-s1-fix-crash-on-draw.md)).

## E3-S3 Record a result for a returning player (12-e3-s3-record-a-result-for-a-returning-player.md)

- [x] the player's database id is derived from their position in the list (`index + 1`), which breaks once any player is deleted or ids are non-contiguous (see [E6-S3](28-e6-s3-look-up-players-by-real-id.md)).
- [x] `updatePlayer` reads and writes the row at `players[id - 1]`, so a real id would pick the wrong row (see [E6-S3](28-e6-s3-look-up-players-by-real-id.md)).
- [x] no test covers a result for a returning player (see [E6-S3](28-e6-s3-look-up-players-by-real-id.md)).

## E3-S4 Link game outcome to scoreboard (13-e3-s4-link-game-outcome-to-scoreboard.md)

- [x] updates are triggered from inside `render()`, so any re-render of a finished board re-submits results (see [E6-S2](27-e6-s2-record-each-result-exactly-once.md)).
- [x] a second result for a new player that arrives before the first POST returns sends a second POST and makes a duplicate row (see [E6-S2](27-e6-s2-record-each-result-exactly-once.md)).
- [x] no test covers the win results or checks that a re-render of a finished board sends no request (see [E6-S2](27-e6-s2-record-each-result-exactly-once.md)).
- [ ] two results for a known player before the first PUT returns send the same counters, so one result is lost (see [E6-S5](30-e6-s5-server-side-result-increments.md)).

## E4-S4 Update a player's stats (17-e4-s4-update-a-player-s-stats.md)

- [x] the action renders `@list` (never assigned), so success returns `null` and a failure would raise (see [E6-S4](29-e6-s4-return-the-updated-player-from-put.md)).
- [x] a failed update (for example a blank `name`) calls `@list.errors` and returns 500 instead of 422 (see [E6-S4](29-e6-s4-return-the-updated-player-from-put.md)).
- [x] the stray `PUT /api/v1/players` route (no id) goes to the unused top-level `PlayersController`, which always returns 404 (see [E6-S4](29-e6-s4-return-the-updated-player-from-put.md)).
- [x] `:result` is permitted but is not a column, so a POST or PUT that sends it returns 500 (see [E6-S4](29-e6-s4-return-the-updated-player-from-put.md)).
- [x] no request spec covers the update (see [E6-S4](29-e6-s4-return-the-updated-player-from-put.md)).

## E6: Hardening & Defect Fixes

Each story is a proposed change, not existing behaviour. Sub-items are the story's acceptance criteria.

- [x] E6-S1 Fix crash on draw ([26-e6-s1-fix-crash-on-draw.md](26-e6-s1-fix-crash-on-draw.md))
  - [x] The draw branch calls `this.scoreboard.current.updatePlayer(...)` (matching the win branches).
  - [x] A test covers a full-board draw and asserts both players receive +1 draw.
- [x] E6-S2 Record each result exactly once ([27-e6-s2-record-each-result-exactly-once.md](27-e6-s2-record-each-result-exactly-once.md))
  - [x] Score updates move out of `render()` into the move handler (or `componentDidUpdate` guarded by a "result recorded" flag).
  - [x] Re-renders after a game ends make no further API calls.
  - [x] Two quick results for a brand-new player don't create duplicate rows.
- [x] E6-S3 Look up players by real id ([28-e6-s3-look-up-players-by-real-id.md](28-e6-s3-look-up-players-by-real-id.md))
  - [x] `playerIndex` returns the id from the matching player object, not the list position.
  - [x] Works when ids have gaps (e.g. after a delete).
- [x] E6-S4 Return the updated player from PUT ([29-e6-s4-return-the-updated-player-from-put.md](29-e6-s4-return-the-updated-player-from-put.md))
  - [x] `update` renders `@player` / `@player.errors`.
  - [x] The stray `PUT /api/v1/players` route (no id, pointing at the non-namespaced controller) and the unused top-level `PlayersController` are removed.
  - [x] Unused `:result` / `:slug` params are removed from the permit lists.
- [ ] E6-S5 Server-side result increments ([30-e6-s5-server-side-result-increments.md](30-e6-s5-server-side-result-increments.md))
  - [ ] New endpoint (e.g. `POST /api/v1/players/:name/results` with `result: win|loss|draw`) finds-or-creates the player and increments atomically.
  - [ ] Client stops sending absolute counter values.
  - [ ] Player names are unique (DB index + model validation).
- [x] E6-S6 Tighten name validation and match lifecycle ([31-e6-s6-tighten-name-validation-and-match-lifecycle.md](31-e6-s6-tighten-name-validation-and-match-lifecycle.md))
  - [x] Names are trimmed; blank-after-trim is rejected; duplicate check is case-insensitive.
  - [x] The form shows an error message instead of silently doing nothing.
  - [x] Changing names resets the board.
- [ ] E6-S7 Restrict CORS and protect write endpoints ([32-e6-s7-restrict-cors-and-protect-write-endpoints.md](32-e6-s7-restrict-cors-and-protect-write-endpoints.md))
  - [ ] CORS origins come from configuration instead of `*`.
  - [ ] DELETE (and ideally direct PUT) require an admin credential or are removed from the public API.
- [ ] E6-S8 Expand automated test coverage ([33-e6-s8-expand-automated-test-coverage.md](33-e6-s8-expand-automated-test-coverage.md))
  - [ ] RSpec request specs cover index, show, create (valid/invalid), update and destroy, using the existing `RequestSpecHelper`.
  - [ ] React Testing Library tests cover: clicks ignored before names are set, alternating turns, win and draw status messages, New Game reset, and scoreboard API calls (with axios mocked).
  - [ ] The Scoreboard test is rewritten; it currently passes a `players` prop the component ignores.
- [ ] E6-S9 Align docs and tooling versions ([34-e6-s9-align-docs-and-tooling-versions.md](34-e6-s9-align-docs-and-tooling-versions.md))
  - [ ] README Ruby version matches the Gemfile/Dockerfile (2.6.1, not 2.5.3).
  - [ ] README clone URL points at this repository.
  - [ ] Committed SQLite databases, `development.log` and the `.seeds.rb.swp` swap file are removed and git-ignored.
