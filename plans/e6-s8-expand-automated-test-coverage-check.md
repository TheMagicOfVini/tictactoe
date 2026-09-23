# E6-S8 Expand automated test coverage: Check

Story: `sdd/33-e6-s8-expand-automated-test-coverage.md`.

## TODO gaps

The TODO item lists three criteria. Each one is a partial gap.

- **RSpec request specs cover index, show, create (valid/invalid), update and destroy, using the existing `RequestSpecHelper`.** Partly confirmed.
  - `RequestSpecHelper` exists (`backend/spec/support/request_spec_helper.rb:1-6`) and `backend/spec/rails_helper.rb:32` includes it for `type: :request`. Every request spec uses its `json` helper.
  - Update is covered: `backend/spec/requests/players_update_spec.rb:57-112` (valid, blank name, duplicate name, unpermitted params, no-id route).
  - Destroy is covered: `backend/spec/requests/players_destroy_spec.rb:11-18` (204 and the row is gone), `players_destroy_spec.rb:20-52` (401 cases).
  - Index is a gap. `backend/spec/requests/players_public_spec.rb:12-16` checks only the status. No spec checks that the body is a JSON array with every player and the four fields (E4-S2, criterion 1).
  - Show is a gap. `players_public_spec.rb:18-22` checks only the status. No spec checks the body. No spec covers an unknown id (E4-S2, criterion 2).
  - Create (valid) is a partial gap. `players_public_spec.rb:24-28` checks the status. `players_update_spec.rb:114-122` checks the body. No spec checks the `Location` header (E4-S3, criterion 2).
  - Create (invalid) is a partial gap. `backend/spec/requests/player_results_spec.rb:155-164` covers a duplicate name. No spec covers a blank name and the 422 body (E4-S3, criterion 2).
- **React Testing Library tests cover: clicks ignored before names are set, alternating turns, win and draw status messages, New Game reset, and scoreboard API calls (with axios mocked).** Partly confirmed.
  - Clicks before names: no test. No test in `frontend/src/tests/Game.test.js` clicks a square before it submits names (E1-S3).
  - Alternating turns: no test. No test checks the mark of each click or the "`<name>`'s turn!" status. No test clicks a claimed square (E2-S3).
  - Win status: no test. `Game.test.js:245-310` checks only the posted results. No test reads "Winner: `<name>`" or clicks after a win (E2-S4).
  - Draw status: covered. `Game.test.js:209-215`.
  - New Game reset: no test. No test clicks the "New Game" button (E2-S6).
  - Scoreboard API calls with axios mocked: partly covered. `Game.test.js:7` and `frontend/src/tests/Scoreboard.test.js:7` mock axios. The POST calls are covered (`Scoreboard.test.js:62-73`, `Game.test.js:216-242`). The GET on mount is only checked through the rows (`Scoreboard.test.js:74-85`). No test asserts the GET URL, the tab title or the empty table after a failed fetch (E3-S1).
  - `frontend/src/App.test.js:1-9` does not mock axios and uses `ReactDOM.render`, not React Testing Library. The "Network Error" log that `CLAUDE.md` describes did not appear in this run, but the test still sends a real request.
- **The Scoreboard test is rewritten; it currently passes a `players` prop the component ignores.** Confirmed.
  - `Scoreboard.test.js:31-44` builds `playerMocks` and renders `<Scoreboard {...playerMocks} />`. `frontend/src/components/Scoreboard.js` never reads `this.props`. The rest of the file was already rewritten by E6-S3 and E6-S5. The "should render" test is the part that still holds.
  - `Scoreboard.test.js:50` and `:119` define `flushPromises` twice, and `:57` and `:120` define `rows` twice.

## Gaps not in TODO

- E2-S3 says a click on a claimed square does nothing. No test covers it.
- E2-S4 says clicks after a win are ignored. No test covers it.
- E2-S6 says New Game keeps the names and re-randomises the first mover. No test covers either.
- E3-S1 says the tab title is "Tic Tac Toe" and a failed fetch logs the error and renders an empty table. No test covers either.
- E5-S3 says `App` renders without crashing. The test does this with `ReactDOM.render` and real axios.
- E4-S2 says an unknown id returns 404 through `ActiveRecord::RecordNotFound`. `backend/config/environments/test.rb:26` sets `show_exceptions = false`, so a request spec sees the exception, not a 404 response. A spec must assert the exception and the Rails mapping of that exception to `:not_found`.

## Story references

- The E6-S8 item in `sdd/TODO.md:115-118` has no gap under any E1-E5 story section. No section names E6-S8. No item has only an epic reference.
- The test specs are `sdd/23-e5-s3-front-end-unit-tests.md` and `sdd/24-e5-s4-back-end-model-tests.md`. Neither one lists the tests that E6-S8 asks for.

## Specs to rewrite

1. `sdd/23-e5-s3-front-end-unit-tests.md`: add the React Testing Library criteria and the Scoreboard test criterion.
2. `sdd/24-e5-s4-back-end-model-tests.md`: add the request spec criteria. The title stays; the E5 epic covers `spec/` as a whole (`sdd/00-overview.md`).
3. `sdd/33-e6-s8-expand-automated-test-coverage.md`: expand the three criteria to the same detail, as E6-S7 did.

## Test environment

- Backend: `rbenv exec bundle exec rspec` in `backend/`. Result: 75 examples, 0 failures.
- Frontend: `CI=true npm test` in `frontend/`. Result: 3 suites, 35 tests, 1 snapshot, all pass. No "Network Error" line in the output.
- The jsdom in the front-end tests has no `MutationObserver`, so `findBy*` and `waitFor` fail (`Scoreboard.test.js:48-49`). The tests flush promises with `setImmediate` instead.
