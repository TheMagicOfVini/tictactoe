# TODO

Gaps found while mapping the code. Each item names the spec it was found in and the Epic 6 story that fixes it.

## E1-S2 Validate player names (02-e1-s2-validate-player-names.md)

- [x] whitespace-only names pass validation, and surrounding spaces are kept ("Bob " ≠ "Bob") (see [E6-S6](31-e6-s6-tighten-name-validation-and-match-lifecycle.md)).
- [x] comparison is case-sensitive ("bob" ≠ "Bob") (see [E6-S6](31-e6-s6-tighten-name-validation-and-match-lifecycle.md)).
- [x] invalid names are accepted silently; the form shows no error (see [E6-S6](31-e6-s6-tighten-name-validation-and-match-lifecycle.md)).
- [x] changing names mid-match does not reset the board (see [E6-S6](31-e6-s6-tighten-name-validation-and-match-lifecycle.md)).

## E2-S5 Detect a draw (08-e2-s5-detect-a-draw.md)

- [x] the draw branch calls `this.child.scoreboard.updatePlayer(...)`, which is undefined and throws at runtime (see [E6-S1](26-e6-s1-fix-crash-on-draw.md)).
- [x] no test covers a full-board draw, its status message or the draw recorded for each player (see [E6-S1](26-e6-s1-fix-crash-on-draw.md)).

## E3-S2 Record a result for a new player (11-e3-s2-record-a-result-for-a-new-player.md)

- [x] the spec says that `createPlayer` POSTs a count of 1 to `/api/v1/players`. The client now sends `POST /api/v1/players/results` with `{ name, result }`. Update the spec (see [E6-S5](30-e6-s5-server-side-result-increments.md)).

## E3-S3 Record a result for a returning player (12-e3-s3-record-a-result-for-a-returning-player.md)

- [x] the player's database id is derived from their position in the list (`index + 1`), which breaks once any player is deleted or ids are non-contiguous (see [E6-S3](28-e6-s3-look-up-players-by-real-id.md)).
- [x] `updatePlayer` reads and writes the row at `players[id - 1]`, so a real id would pick the wrong row (see [E6-S3](28-e6-s3-look-up-players-by-real-id.md)).
- [x] no test covers a result for a returning player (see [E6-S3](28-e6-s3-look-up-players-by-real-id.md)).
- [x] the spec says that `updatePlayer` adds 1 to the counter and PUTs `/api/v1/players/:id`. The server now adds 1, and the client sends `POST /api/v1/players/results` with `{ name, result }`. Update the spec (see [E6-S5](30-e6-s5-server-side-result-increments.md)).

## E3-S4 Link game outcome to scoreboard (13-e3-s4-link-game-outcome-to-scoreboard.md)

- [x] updates are triggered from inside `render()`, so any re-render of a finished board re-submits results (see [E6-S2](27-e6-s2-record-each-result-exactly-once.md)).
- [x] a second result for a new player that arrives before the first POST returns sends a second POST and makes a duplicate row (see [E6-S2](27-e6-s2-record-each-result-exactly-once.md)).
- [x] no test covers the win results or checks that a re-render of a finished board sends no request (see [E6-S2](27-e6-s2-record-each-result-exactly-once.md)).
- [x] two results for a known player before the first PUT returns send the same counters, so one result is lost (see [E6-S5](30-e6-s5-server-side-result-increments.md)).
- [x] no endpoint adds one result to a player. The server stores only the absolute counters that the client sends (see [E6-S5](30-e6-s5-server-side-result-increments.md)).
- [x] the client sends absolute counters on POST and on PUT (see [E6-S5](30-e6-s5-server-side-result-increments.md)).
- [x] the client decides POST or PUT from its local list. A stale list (a player that another session made) sends a second POST and makes a duplicate row (see [E6-S5](30-e6-s5-server-side-result-increments.md)).
- [x] the `players` table has no unique index on `name`, and the `Player` model does not validate the uniqueness of `name` (see [E6-S5](30-e6-s5-server-side-result-increments.md)).
- [x] no rule says if the name match is case-sensitive. The server now matches names exactly, so `Alice` and `alice` are two players (see [E6-S5](30-e6-s5-server-side-result-increments.md)).
- [x] the development database has duplicate names, and a second `db:seed` duplicates the demo players. The migration merges the duplicates first, and the seeds skip the players that exist (see [E6-S5](30-e6-s5-server-side-result-increments.md)).
- [x] two first results for the same new name at the same time can make two rows. The server now rescues `ActiveRecord::RecordNotUnique` and finds the player again (see [E6-S5](30-e6-s5-server-side-result-increments.md)).
- [x] the name in the URL path breaks for names with `/` or `.`. The endpoint now takes the name from the JSON body (see [E6-S5](30-e6-s5-server-side-result-increments.md)).
- [x] the client builds the updated row from local values, not from the response. The endpoint now returns the saved player, and the client puts it in the table (see [E6-S5](30-e6-s5-server-side-result-increments.md)).
- [x] the server does not check `result`. The endpoint now returns 422 for a blank `name` or a `result` that is not `win`, `loss` or `draw` (see [E6-S5](30-e6-s5-server-side-result-increments.md)).
- [x] no test covers two quick results for a known player (see [E6-S5](30-e6-s5-server-side-result-increments.md)).

## E4-S1 Player data model (14-e4-s1-player-data-model.md)

- [x] the spec has no unique name rule. Add the unique index on `name`, the uniqueness validation and the case-sensitive match (see [E6-S5](30-e6-s5-server-side-result-increments.md)).

## E4-S3 Create a player (16-e4-s3-create-a-player.md)

- [x] the spec does not say that a POST with a known name returns 422 (see [E6-S5](30-e6-s5-server-side-result-increments.md)).

## E4-S4 Update a player's stats (17-e4-s4-update-a-player-s-stats.md)

- [x] the action renders `@list` (never assigned), so success returns `null` and a failure would raise (see [E6-S4](29-e6-s4-return-the-updated-player-from-put.md)).
- [x] a failed update (for example a blank `name`) calls `@list.errors` and returns 500 instead of 422 (see [E6-S4](29-e6-s4-return-the-updated-player-from-put.md)).
- [x] the stray `PUT /api/v1/players` route (no id) goes to the unused top-level `PlayersController`, which always returns 404 (see [E6-S4](29-e6-s4-return-the-updated-player-from-put.md)).
- [x] `:result` is permitted but is not a column, so a POST or PUT that sends it returns 500 (see [E6-S4](29-e6-s4-return-the-updated-player-from-put.md)).
- [x] no request spec covers the update (see [E6-S4](29-e6-s4-return-the-updated-player-from-put.md)).
- [x] the spec does not say that a PUT that sets the name of another player returns 422. PUT still accepts absolute counters; [E6-S7](32-e6-s7-restrict-cors-and-protect-write-endpoints.md) covers the protection of this endpoint (see [E6-S5](30-e6-s5-server-side-result-increments.md)).

## E4-S6 Allow cross-origin requests (19-e4-s6-allow-cross-origin-requests.md)

- [x] `cors.rb` allowed all origins (see [E6-S7](32-e6-s7-restrict-cors-and-protect-write-endpoints.md)).
- [x] the spec stated all origins as the target (see [E6-S7](32-e6-s7-restrict-cors-and-protect-write-endpoints.md)).
- [x] no env var fed the origins (see [E6-S7](32-e6-s7-restrict-cors-and-protect-write-endpoints.md)).
- [x] no test covered CORS (see [E6-S7](32-e6-s7-restrict-cors-and-protect-write-endpoints.md)).

## E4-S7 Seed demo data (20-e4-s7-seed-demo-data.md)

- [x] the spec does not say that a second `db:seed` makes no duplicate player (see [E6-S5](30-e6-s5-server-side-result-increments.md)).

## E5-S4 Back-end model tests (24-e5-s4-back-end-model-tests.md)

- [x] the spec has no criterion for a test of the uniqueness of `name` (see [E6-S5](30-e6-s5-server-side-result-increments.md)).

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
- [x] E6-S5 Server-side result increments ([30-e6-s5-server-side-result-increments.md](30-e6-s5-server-side-result-increments.md))
  - [x] New endpoint `POST /api/v1/players/results` with the body `{ name, result }` (`result: win|loss|draw`) finds-or-creates the player and increments atomically. The name is in the body, not in the path.
  - [x] Client stops sending absolute counter values.
  - [x] Player names are unique (DB index + model validation).
- [x] E6-S6 Tighten name validation and match lifecycle ([31-e6-s6-tighten-name-validation-and-match-lifecycle.md](31-e6-s6-tighten-name-validation-and-match-lifecycle.md))
  - [x] Names are trimmed; blank-after-trim is rejected; duplicate check is case-insensitive.
  - [x] The form shows an error message instead of silently doing nothing.
  - [x] Changing names resets the board.
- [ ] E6-S7 Restrict CORS and protect write endpoints ([32-e6-s7-restrict-cors-and-protect-write-endpoints.md](32-e6-s7-restrict-cors-and-protect-write-endpoints.md))
  - [x] CORS origins come from `CORS_ORIGINS` instead of `*`. Production fails to boot when the variable is not set.
  - [ ] DELETE (and ideally direct PUT) require an admin credential or are removed from the public API.
- [ ] E6-S8 Expand automated test coverage ([33-e6-s8-expand-automated-test-coverage.md](33-e6-s8-expand-automated-test-coverage.md))
  - [ ] RSpec request specs cover index, show, create (valid/invalid), update and destroy, using the existing `RequestSpecHelper`.
  - [ ] React Testing Library tests cover: clicks ignored before names are set, alternating turns, win and draw status messages, New Game reset, and scoreboard API calls (with axios mocked).
  - [ ] The Scoreboard test is rewritten; it currently passes a `players` prop the component ignores.
- [ ] E6-S9 Align docs and tooling versions ([34-e6-s9-align-docs-and-tooling-versions.md](34-e6-s9-align-docs-and-tooling-versions.md))
  - [ ] README Ruby version matches the Gemfile/Dockerfile (2.6.1, not 2.5.3).
  - [ ] README clone URL points at this repository.
  - [ ] Committed SQLite databases, `development.log` and the `.seeds.rb.swp` swap file are removed and git-ignored.
