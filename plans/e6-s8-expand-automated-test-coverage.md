# Expand automated test coverage (E6-S8)

## Context

The step 2 check (`plans/e6-s8-expand-automated-test-coverage-check.md`) found that each of the three E6-S8 criteria is a partial gap. Update and destroy request specs exist. The draw status test exists. The rest is missing, and the Scoreboard "should render" test passes a `players` prop that the component ignores.

Step 3 put the target behavior in two specs. This plan numbers their new criteria.

Front end, `sdd/23-e5-s3-front-end-unit-tests.md`:
- F1: every component test uses React Testing Library and mocks `axios`. `App` and `Scoreboard` render with the mock in place.
- F2: a click before both names are set leaves the board unchanged.
- F3: the marks alternate, the status reads "`<name>`'s turn!", and a click on a claimed square changes nothing.
- F4: the status reads "Winner: `<name>`" for an O win and for an X win. A click after a win leaves the board unchanged.
- F5: the status reads "The game is a draw!" on a draw. Already covered by `Game.test.js` "Board draw".
- F6: New Game clears all 9 squares, keeps the names and re-randomises the first mover.
- F7: the Scoreboard sends `GET /api/v1/players.json` on mount and renders one row per player, sets the tab title, logs a failed fetch and renders empty, and sends `POST /api/v1/players/results` for a result.
- F8: the Scoreboard test passes no `players` prop and defines each helper once.

Back end, `sdd/24-e5-s4-back-end-model-tests.md`:
- B1: index returns 200 and a JSON array with every player and its five fields.
- B2: show returns 200 and the player. An unknown id raises `ActiveRecord::RecordNotFound`, which Rails maps to 404.
- B3: create returns 201, the player and a `Location` header.
- B4: create with a blank name returns 422 and the errors, and creates no player. A known name returns 422 (already covered by `player_results_spec.rb:155-164`).
- B5: update. Already covered by `players_update_spec.rb`.
- B6: destroy. Already covered by `players_destroy_spec.rb`.

No production code changes. The fix is tests only, plus one line in `CLAUDE.md`.

## Design decisions

### How the tests control the first mover

`Board` calls `Math.random()` once in the constructor and once in `resetBoard`. `xTurn` is `Math.random() < 0.5`. When `xTurn` is true the mark is "X" and the status names Player Two. When it is false the mark is "O" and the status names Player One. The tests use `jest.spyOn(Math, "random").mockReturnValue(0.1)` for X first and `0.9` for O first, and restore the spy after each test. The popup library does not call `Math.random`, so a constant return value is safe.

For F6 (re-randomise), a test mocks `0.1` before the render, plays one move and sees "X". It then changes the mock to `0.9`, clicks New Game and plays one move. The new mark is "O", so New Game called `Math.random` again.

### How the tests read the board

The tests already read the squares with `queryAllByTestId("board-square")`, the header with `.players` and the status with `.status`. The new tests reuse these helpers. `Game.test.js` gets a shared `status` and `marks` helper at the top of the file, so no describe block redefines them.

### How the unknown id test asserts a 404

`backend/config/environments/test.rb:26` sets `show_exceptions = false`, so a request spec sees `ActiveRecord::RecordNotFound` itself, not a 404 response. The spec asserts the exception with `raise_error`, and asserts that `ActionDispatch::ExceptionWrapper.rescue_responses` maps that exception to `:not_found`. Together they prove the 404 in the criterion.

### App test

`App.test.js` becomes a React Testing Library test with `jest.mock("axios", ...)`. It renders `App`, checks the `game` and `game-scoreboard` test ids, and checks that the mocked `GET` ran once. This removes the last real request in the suite, so the `CLAUDE.md` gotcha about the "Network Error" log changes to say that every component test mocks `axios`.

### Scoreboard test rewrite

The file keeps its `loadedPlayers`, the `beforeEach` mocks and the returning-player and new-player tests. It moves `flushPromises`, `rows` and a `renderLoaded` helper to the top of the file. The "should render" test drops `playerMocks` and checks the rows from the mocked `GET`. New tests cover the GET URL, the tab title and the failed fetch.

## Steps

1. Save this plan to `plans/e6-s8-expand-automated-test-coverage.md`. Done when the file exists.
2. Stay on branch `fix/e6-s8-expand-automated-test-coverage`.
3. Back-end tests, in `backend/`:
   - Add `spec/requests/players_read_spec.rb` (B1, B2).
   - Add `spec/requests/players_create_spec.rb` (B3, B4).
4. Front-end tests, in `frontend/`:
   - Edit `src/tests/Game.test.js`: add "Board before names" (F2), "Board turns" (F3), status and click-after-win tests in "Board win" (F4), "Board new game" (F6).
   - Rewrite `src/tests/Scoreboard.test.js` (F7, F8).
   - Rewrite `src/App.test.js` (F1).
5. Edit `CLAUDE.md`: replace the "Network Error" gotcha with the axios mock rule.
6. Run the tests. See "Commands".
7. TODO (CLAUDE.md step 6): check off the E6-S8 story and its three criteria in `sdd/TODO.md`. Add the gaps from the check that the TODO did not list, under new E1-S3, E2-S3, E2-S4, E2-S6, E3-S1, E4-S2, E4-S3, E5-S3 sections, and check them off.
8. Commit (CLAUDE.md step 7). See "Files to stage".

## Tests for each criterion

| Criterion | Test | File |
|---|---|---|
| F1 | "renders the game and the scoreboard with axios mocked": render `App`, assert both test ids, assert `axios.get` called once with `/api/v1/players.json`. | `src/App.test.js` |
| F2 | "Should ignore a click before the names are set": click square 0, assert no filled square, header "Set the names of both players.", status "". | `src/tests/Game.test.js` |
| F3 | "Should place X then O when X moves first": mock 0.1, set names, assert status "Alice's turn!", click 0 → "X", status "Bob's turn!", click 1 → "O", status "Alice's turn!". "Should place O then X when O moves first": mock 0.9, the mirror case. "Should ignore a click on a claimed square": click 0 twice, assert square 0 keeps its mark, only one filled square, status unchanged. | `src/tests/Game.test.js` |
| F4 | "Should show the winner status on an O win": status "Winner: Bob". "Should show the winner status on an X win": status "Winner: Alice". "Should ignore a click after a win": click square 8 after the win, assert it is empty and the status is unchanged. | `src/tests/Game.test.js` |
| F5 | Existing "Should show the draw status without an error". | `src/tests/Game.test.js` |
| F6 | "Should clear the squares and keep the names": play two moves, click New Game, assert no filled square, header "Bob Vs. Alice", status ends with "'s turn!". "Should re-randomise who moves first": mock 0.1, play one move → "X", mock 0.9, click New Game, play one move → "O". | `src/tests/Game.test.js` |
| F7 | "Should fetch the players on mount and render one row each": `axios.get` called with `/api/v1/players.json`, rows equal the three loaded players. "Should set the tab title": `document.title` is "Tic Tac Toe". "Should log a failed fetch and render an empty table": `axios.get` rejects, `console.log` called with the error, no rows. POST: existing "Should send the same request for a known player and a new player". | `src/tests/Scoreboard.test.js` |
| F8 | "should render" renders `<Scoreboard />` with no props and asserts the rows. The file has one `flushPromises`, one `rows` and one `renderLoaded`. | `src/tests/Scoreboard.test.js` |
| B1 | "returns 200 and every player as a JSON array": two players, assert status, array length 2, each item has the five keys and the right values. | `spec/requests/players_read_spec.rb` |
| B2 | "returns 200 and the player": assert status and body. "raises RecordNotFound for an unknown id, which Rails maps to 404": `raise_error(ActiveRecord::RecordNotFound)` and `rescue_responses` check. | `spec/requests/players_read_spec.rb` |
| B3 | "returns 201, the player and a Location header": assert status, body includes name and counters, `response.headers['Location']` equals `api_v1_player_url(Player.last)`, count grew by 1. | `spec/requests/players_create_spec.rb` |
| B4 | "returns 422 and the errors for a blank name, and creates no player": assert status, `json['name']` includes "can't be blank", count unchanged. Known name: existing test in `player_results_spec.rb:155-164`. | `spec/requests/players_create_spec.rb` |
| B5 | Existing. | `spec/requests/players_update_spec.rb` |
| B6 | Existing. | `spec/requests/players_destroy_spec.rb` |

## Existing tests that must change

- `src/tests/Scoreboard.test.js` "should render": drop the `players` prop.
- `src/App.test.js`: rewrite with React Testing Library and the axios mock.
- No other test changes. No production code changes, so every existing test keeps passing.

## Commands

Back end, in `backend/`:

```sh
rbenv exec bundle exec rspec
```

Front end, in `frontend/`:

```sh
CI=true npm test
```

## Files to stage

- `sdd/23-e5-s3-front-end-unit-tests.md`
- `sdd/24-e5-s4-back-end-model-tests.md`
- `sdd/33-e6-s8-expand-automated-test-coverage.md`
- `sdd/TODO.md`
- `backend/spec/requests/players_read_spec.rb`
- `backend/spec/requests/players_create_spec.rb`
- `frontend/src/tests/Game.test.js`
- `frontend/src/tests/Scoreboard.test.js`
- `frontend/src/App.test.js`
- `CLAUDE.md`
- `plans/e6-s8-expand-automated-test-coverage-check.md`
- `plans/e6-s8-expand-automated-test-coverage.md`

Do not stage `backend/db/*.sqlite3`, `backend/log/`, `.idea/`, `backend/.idea/`, `frontend/.idea/` or `TicTacToe-ProductRequirements.pdf`.

## Out of scope

- E6-S9 (docs and tooling versions).
- Moving the existing "known name returns 422" and "ignores params that are not permitted" create tests into the new create spec. They pass where they are.
- Any change to `Game.js`, `Scoreboard.js` or the back-end app code.

## Verification

- `rbenv exec bundle exec rspec` passes in `backend/`.
- `CI=true npm test` passes in `frontend/` with no "Network Error" line.
- Each criterion F1 to F8 and B1 to B6 has a test in the table above.
