# E3-S4 / E6-S5 Check (step 1)

Target item: the first unchecked item in `sdd/TODO.md` (line 26), under E3-S4. "two results for a known player before the first PUT returns send the same counters, so one result is lost (see E6-S5)".

## TODO gaps

1. **Confirmed.** Two results for a known player before the first PUT returns send the same counters.
   - `frontend/src/components/Scoreboard.js:70-75` reads `wins`, `losses` and `draws` from `this.state.players`.
   - `Scoreboard.js:86-93` PUTs absolute counters.
   - `Scoreboard.js:94-99` writes the new counters to state only when the PUT returns.
   - So a second `updatePlayer` call before that point reads the old counters and PUTs the same values. The server stores the same totals twice. One result is lost.
   - The same loss happens across sessions: two browsers with stale lists overwrite each other (the E6-S5 user story).
   - The in-flight guard (`creating`, `Scoreboard.js:9`, `55-59`) covers only POSTs. Nothing covers PUTs.
   - No test covers two quick results for a known player. `frontend/src/tests/Scoreboard.test.js:62-73` covers one PUT only.

## Gaps not in TODO

These gaps are in E6-S5 but the TODO does not list them.

1. **No endpoint for server-side increments.** `backend/config/routes.rb:6-8` has only `resources :players` and a duplicate `POST /players` match. `backend/app/controllers/api/v1/players_controller.rb` has no results action. Nothing finds-or-creates a player by name.
2. **The server does not increment.** `players_controller.rb:31` calls `@player.update(player_params)` with absolute values. `players_controller.rb:54` permits `wins`, `losses` and `draws` on POST and PUT.
3. **The client sends absolute counters on POST.** `Scoreboard.js:32-45` builds `{ name, wins, losses, draws }` and POSTs it.
4. **The client sends absolute counters on PUT.** `Scoreboard.js:73-93`.
5. **The client finds or creates the player itself.** `Scoreboard.js:60-68` decides POST or PUT from its local list. A stale list (a player created in another session) makes a second POST and a duplicate row.
6. **No unique index on `name`.** `backend/db/schema.rb:15-22` and `backend/db/migrate/20181119085056_create_players.rb` have no index.
7. **No uniqueness validation.** `backend/app/models/player.rb:4` has only `validates_presence_of :name`.
8. **Name lookup is case-sensitive and does not trim.** `Scoreboard.js:107` uses `player.name === name`. E6-S6 made the name check case-insensitive in the form (`Game.js:39-47`), but the scoreboard lookup is not. The plan must decide whether uniqueness is case-sensitive. This is not explicit in E6-S5.
9. **Duplicates already exist in the dev database.** `backend/db/development.sqlite3` has 6 names that appear twice (for example "Jeff Bezos", "a"). `backend/db/seeds.rb` creates the demo players with `Player.create`, so a second `db:seed` duplicates them. A unique-index migration fails on this data unless it removes or merges duplicates first. The test database is empty.
10. **Concurrent find-or-create race.** Two first results for a new name at the same time can both miss and both insert. The unique index plus a rescue of `ActiveRecord::RecordNotUnique` (and a retry) closes this. Atomic increment needs SQL `UPDATE ... SET wins = wins + 1` (for example `Player.update_counters` or `increment_counter`), not `increment!`.
11. **Name in the URL path.** The E6-S5 example route `POST /api/v1/players/:name/results` puts the name in the path. Names with spaces, `/` or `.` need encoding, and Rails reads a trailing `.xxx` as a format. A body param (for example `POST /api/v1/results` with `{ name, result }`) avoids this. The plan must choose.
12. **Response shape.** The new endpoint should return the saved player, so the client can update or append its row from the response. The client does not do this today for PUT (`Scoreboard.js:95` builds the row from local values).
13. **Invalid result.** Neither side validates `result` on the server. The client alerts (`Scoreboard.js:41`, `83`). The endpoint should return 422 for a value that is not `win`, `loss` or `draw`.

## Story references

- The TODO item has a proper E6 story reference: `sdd/TODO.md:26` links `30-e6-s5-server-side-result-increments.md`.
- E6-S5 is unchecked with its three criteria at `sdd/TODO.md:53-56`.
- Other specs that E6-S5 affects:
  - `sdd/13-e3-s4-link-game-outcome-to-scoreboard.md`: the last criterion (wait for the POST, then PUT to the new id) describes the old client flow. It changes if the client sends one result request per player.
  - `sdd/11-e3-s2-record-a-result-for-a-new-player.md`: says `createPlayer` POSTs a count of 1. This changes.
  - `sdd/12-e3-s3-record-a-result-for-a-returning-player.md`: says `updatePlayer` increments the counter and PUTs `/api/v1/players/:id`. This changes.
  - `sdd/14-e4-s1-player-data-model.md`: needs the unique name rule.
  - `sdd/16-e4-s3-create-a-player.md` and `sdd/17-e4-s4-update-a-player-s-stats.md`: these endpoints still accept absolute counters. E6-S5 does not say to remove them. E6-S7 covers protecting direct PUT. POST with a duplicate name now returns 422.
  - `sdd/24-e5-s4-back-end-model-tests.md`: may gain a uniqueness criterion.
  - The CLAUDE.md step 2 edits only the E3-S4 spec. The E3-S2, E3-S3 and E4 specs become out of date. Record this as a follow-up or update them in the same fix.

## Test environment

- **Backend:** RSpec, Rails 5.2, Ruby 2.6.1 through rbenv (`backend/.ruby-version`).
  - Run `rbenv exec bundle exec rspec` in `backend/`. Result now: 16 examples, 0 failures, about 2 s. One deprecation warning.
  - Plain `bundle exec rspec` fails. It uses the system Ruby 2.6.10 and asks for bundler 2.1.2.
  - `macOS` has no `timeout` command.
  - Helpers: `spec/support/request_spec_helper.rb` gives `json`. `spec/rails_helper.rb:32` includes it for `type: :request`. Transactional fixtures are on (`rails_helper.rb:37`).
  - Factory: `spec/factories/players.rb` uses `Faker::Name.first_name`. With a uniqueness validation, two factory players can collide. Use explicit names or a sequence.
  - Existing request spec: `spec/requests/players_update_spec.rb`. It uses `Player.create!` and a JSON `CONTENT_TYPE` header. Add a new file, for example `spec/requests/player_results_spec.rb`.
  - A new migration needs `rbenv exec bundle exec rails db:migrate` (and for test, `RAILS_ENV=test` or `db:test:prepare`). It updates `db/schema.rb`. The committed `*.sqlite3` files are unrelated changes; do not stage them.
- **Frontend:** Jest through react-scripts 2.1.1. Run `CI=true npm test` in `frontend/`. Result now: 3 suites, 33 tests pass.
  - Both test files mock axios with `jest.mock("axios", () => ({ get, post, put }))`. The mock has no other methods. `beforeEach` resets them.
  - `Game.test.js:14-16` makes `post` return `{ id: <call count>, ...body.player }`. `Game.test.js:212-220` and `247-267` assert POST bodies with absolute counters (`{ name, wins, losses, draws }`). These tests must change with the new endpoint.
  - `Scoreboard.test.js:62-123` asserts PUT and POST bodies with absolute counters. These tests must change too.
  - jsdom has no `MutationObserver`, so `waitFor` and `findBy*` fail. Use `flushPromises` (`setImmediate`), as in `Scoreboard.test.js:43`.
  - Tests control request timing with a manual resolver (`Scoreboard.test.js:97-104`). Reuse this for "two results before the first request returns".
