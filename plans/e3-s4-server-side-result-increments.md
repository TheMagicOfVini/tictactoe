# Server-side result increments (E3-S4, E6-S5)

## Context
The step 1 check (`plans/e3-s4-server-side-result-increments-check.md`) confirmed the TODO gap at `sdd/TODO.md:26`. Two results for a known player before the first PUT returns send the same counters, so one result is lost:
- `frontend/src/components/Scoreboard.js:70-75` reads the counters from the local list.
- `Scoreboard.js:86-93` PUTs absolute counters.
- `Scoreboard.js:94-99` writes the new counters to state only when the PUT returns.

The check also found gaps that E6-S5 covers but the TODO does not list:
- No results endpoint. `backend/config/routes.rb:6-8` has only `resources :players` and a duplicate `POST /players` line.
- The server does not increment. `backend/app/controllers/api/v1/players_controller.rb:31` saves absolute values.
- The client POSTs absolute counters (`Scoreboard.js:32-45`) and finds or creates the player itself from its local list (`Scoreboard.js:60-68`, `106-110`). A stale list makes a duplicate row.
- No unique index on `name` (`backend/db/schema.rb:15-22`). No uniqueness validation (`backend/app/models/player.rb:4`).
- The dev database has 6 duplicate names. `backend/db/seeds.rb:1-5` uses `Player.create`, so a second `db:seed` makes duplicates.
- Nothing handles two first results for a new name at the same time.
- No invalid-result check on the server.

The new criteria are in `sdd/13-e3-s4-link-game-outcome-to-scoreboard.md`. This plan numbers them C1 to C13 in the order of the file:
- C1: O win and X win results.
- C2: draw results.
- C3: results once, from the move handler.
- C4: no request after the game ends.
- C5: one `POST /api/v1/players/results` with `{ name, result }` for each player; no POST or PUT to `/api/v1/players`.
- C6: name in the body; create or increment; names with spaces, `/` or `.` work.
- C7: one atomic SQL update; two quick results both count.
- C8: two requests for the same new name at the same time make one row; rescue `ActiveRecord::RecordNotUnique`.
- C9: 200 and the saved player; the Scoreboard replaces or appends the row; one row for each name.
- C10: 422 and errors for a bad `result` or a blank `name`; no change.
- C11: unique index and uniqueness validation on `name`.
- C12: the migration merges duplicates; a second `db:seed` makes no duplicate.
- C13: case-sensitive exact match; no change of case.

## Design decisions
- Route: `POST /api/v1/players/results`. The name goes in the JSON body, not in the path. This avoids the URL encoding and the `.format` problem of a name in the path.
- Body: top-level `{ "name": "...", "result": "win" }`. The `wrap_parameters` initializer (`backend/config/initializers/wrap_parameters.rb`) also copies `name` into `params[:player]`. The action reads `params[:name]` and `params[:result]` at the top level.
- Increment: `Player.update_counters(player.id, column => 1, touch: true)`. Rails 5.2 makes `UPDATE "players" SET "wins" = COALESCE("wins", 0) + 1, "updated_at" = ...`.
- Find or create: `Player.find_or_create_by!(name: name)`. On `ActiveRecord::RecordNotUnique` or `ActiveRecord::RecordInvalid` (the other request saved the row between the find and the insert), the action calls `Player.find_by!(name: name)`. The blank-name check runs first, so `RecordInvalid` here can only come from the uniqueness rule.
- Uniqueness is case-sensitive. The SQLite index uses the `BINARY` collation. The validation uses `case_sensitive: true`. The server does not trim or change the name. The client already trims the names (`Game.js` `handleSubmit`).
- The old `POST /api/v1/players` and `PUT /api/v1/players/:id` stay. E6-S7 covers them. With the unique rule, a POST with a known name now returns 422.
- `Game.js` does not change. `recordResult` (`Game.js:86-103`) already calls `updatePlayer(name, result)` once for each player, from `handleClick` (`Game.js:84`).

## Steps
1. Save this plan as `plans/e3-s4-server-side-result-increments.md`.
2. Branch: the branch `fix/e3-s4-server-side-result-increments` exists. Stay on it.
3. Backend fix. Do these changes in `backend/`:
   - `config/routes.rb:8`: change `resources :players` to a block with `collection { post :results }`. Keep line 6 (out of scope).
   - `app/controllers/api/v1/players_controller.rb`:
     - Add `RESULT_COLUMNS = { 'win' => :wins, 'loss' => :losses, 'draw' => :draws }.freeze`.
     - Add the public action `results` (after `update`, line 36). It does these steps:
       1. It finds the column from `params[:result]`. If there is no column, it adds `result: ['must be win, loss or draw']` to an errors hash.
       2. If `params[:name]` is blank, it adds `name: ["can't be blank"]`.
       3. If the hash has errors, it renders them with status 422 and stops.
       4. It calls `find_or_create_player(params[:name])`.
       5. It calls `Player.update_counters(player.id, column => 1, touch: true)`.
       6. It renders `player.reload` with status 200.
     - Add the private method `find_or_create_player(name)`. It calls `Player.find_or_create_by!(name: name)`. It rescues `ActiveRecord::RecordNotUnique` and `ActiveRecord::RecordInvalid` and returns `Player.find_by!(name: name)`.
     - `before_action :set_player` (line 4) does not include `results`. Do not change it.
   - `app/models/player.rb:4`: replace `validates_presence_of :name` with `validates :name, presence: true, uniqueness: { case_sensitive: true }`.
   - New migration `db/migrate/20260923000000_add_unique_index_to_players_name.rb` (`ActiveRecord::Migration[5.2]`):
     - Define a local model `class MigrationPlayer < ActiveRecord::Base; self.table_name = 'players'; end`. Do not use the app `Player` model.
     - `up`: find the names that are not `NULL` and have more than one row (`group(:name).having('COUNT(*) > 1')`). For each name, keep the row with the lowest `id`. Set its `wins`, `losses` and `draws` to the sums of all rows with `update_columns`. Delete the other rows. Then `add_index :players, :name, unique: true`.
     - `down`: `remove_index :players, :name`. The merge cannot be undone. Say so in a comment.
   - `db/schema.rb`: the migration regenerates it. It gets the new version and `t.index ["name"], name: "index_players_on_name", unique: true`.
   - `db/seeds.rb:1-5`: use `Player.find_or_create_by!(name: ...) { |player| player.assign_attributes(wins: ..., losses: ..., draws: ...) }` for each demo player.
   - `spec/factories/players.rb:5`: change the name to `sequence(:name) { |n| "Player #{n}" }`. `Faker::Name.first_name` can repeat and break the unique rule.
4. Frontend fix in `frontend/src/components/Scoreboard.js`:
   - Remove `creating` (line 9), `createPlayer` (lines 30-52) and `playerIndex` (lines 106-110).
   - Replace `updatePlayer` (lines 54-104) with one request: `axios.post("/api/v1/players/results", { name, result })`. On success, call `savePlayer(response.data)`. On failure, log the error. Return the promise.
   - Add `savePlayer(player)`. It calls `setState` with an updater function, so that it reads the current list. If a row has the same `id`, it replaces that row. If not, it appends the player.
   - Remove the client `alert` for a bad result. The server returns 422 for it (C10).
5. Tests. See the table below. Add the new tests, and change the existing tests in the next section.
6. Run the migration and the tests. See "Commands".
7. TODO (CLAUDE.md step 6): check off the E3-S4 item at `sdd/TODO.md:26` and E6-S5 with its three criteria (`sdd/TODO.md:53-56`). Add and check off the gaps from step 1 that the TODO does not list. Add unchecked follow-up items for the specs that are now out of date (E3-S2, E3-S3, E4-S1, E4-S3, E4-S4, E4-S7, E5-S4), as listed in the check file.
8. Commit (CLAUDE.md step 7). See "Files to stage".

## Tests for each criterion

Backend files:
- `backend/spec/requests/player_results_spec.rb` (new, `type: :request`, uses `json` and a JSON `CONTENT_TYPE` header, as in `players_update_spec.rb`).
- `backend/spec/models/players_spec.rb` (change).
- `backend/spec/migrations/add_unique_index_to_players_name_spec.rb` (new).
- `backend/spec/seeds_spec.rb` (new).

Frontend files:
- `frontend/src/tests/Game.test.js` (change).
- `frontend/src/tests/Scoreboard.test.js` (change).

| Criterion | Test | File |
|---|---|---|
| C1 | "Should give Player One a win and Player Two a loss on an O win" and "... on an X win". They assert the POST calls `["/api/v1/players/results", { name: "Bob", result: "win" }]` and `{ name: "Alice", result: "loss" }`, and the reverse. | `Game.test.js` (change lines 241-268) |
| C2 | "Should give each player exactly one draw". It asserts two calls with `result: "draw"` for Bob and Alice. | `Game.test.js` (change lines 207-221) |
| C3 | The C1 and C2 tests assert exactly 2 POST calls after the move that ends the game. "Should send no request when the board renders again" asserts that renders send no request. | `Game.test.js` |
| C4 | "Should send no request when the board renders again after the game ends". Keep it. Change the comment at line 274. Assert 2 POST calls and no PUT. | `Game.test.js` (lines 269-284) |
| C5 | New: "Should send one results request for each player, with only name and result". Play a draw. Assert that each POST URL is `/api/v1/players/results`, each body has exactly the keys `name` and `result`, and `axios.put` is not called. In `Scoreboard.test.js`: new "Should send the same request for a known player and a new player". Call `updatePlayer("Steve", "win")` (known) and `updatePlayer("Ann", "win")` (new). Assert two POSTs with the same shape and no PUT. | `Game.test.js`, `Scoreboard.test.js` |
| C6 | Request: "creates a new player with 1 in the matching counter" (for `win`, `loss` and `draw`). "adds 1 to the matching counter of a known player and does not change the others". "works for the name `Dr. J / 2`": two POSTs give one row with 2 wins, and the JSON name is `Dr. J / 2`. | `player_results_spec.rb` |
| C7 | Request: "counts two results for a known player": a player with 3 wins gets two `win` POSTs and has 5 wins. "uses one atomic SQL update": subscribe to `sql.active_record` during the POST and assert one query matches `/UPDATE "players" SET "wins" = COALESCE\("wins", 0\) \+ 1/`, and no query sets `wins` to a literal number. React: new "Should count two quick results for a known player". The `post` mock uses a manual resolver (as in `Scoreboard.test.js:97-104`). Call `updatePlayer("Steve", "win")` two times. Assert 2 POSTs before any response. Resolve them with Steve at 21 and then 22 wins. Assert the row shows 22 wins. | `player_results_spec.rb`, `Scoreboard.test.js` |
| C8 | Request: "makes one row when another request creates the same name first". Stub `Player.find_or_create_by!` with `and_wrap_original`: it creates `Zed` with 1 win (the other request) and raises `ActiveRecord::RecordNotUnique`. POST a `win` for `Zed`. Assert 200, one `Zed` row, and 2 wins. Add the same test with `ActiveRecord::RecordInvalid`. | `player_results_spec.rb` |
| C9 | Request: "returns 200 and the saved player" (`id`, `name`, `wins`, `losses`, `draws` match the row). React: "Should replace the row with the same id" (changed from "Should update only the row of the matching player", lines 74-85; the mock returns Steve with 11 draws, the other rows stay). New "Should append a new player once": get returns `[]`, two quick results for Ann resolve with id 5 and 1 win, then id 5 and 2 wins. Assert one row `["Ann", "2", "0", "0"]` (replaces lines 95-123). | `player_results_spec.rb`, `Scoreboard.test.js` |
| C10 | Request: for `result: 'tie'`, a missing `result`, `name: ''`, `name: '   '` and a missing `name`: assert 422, the matching key in the JSON errors, no change of `Player.count`, and no change of the counters of a known player. | `player_results_spec.rb` |
| C11 | Model: "is not valid with the name of another player" (create `Ann`, build `Ann`, assert not valid and a `name` error). "has a unique index on name": `ActiveRecord::Base.connection.indexes(:players)` has a unique index on `["name"]`. "the database rejects a duplicate name": `save(validate: false)` of a second `Ann` raises `ActiveRecord::RecordNotUnique`. Request: `POST /api/v1/players` with a known name returns 422. | `players_spec.rb`, `player_results_spec.rb` |
| C12 | Migration: require the migration file. In the example, call `down` (drops the index; SQLite runs DDL in the test transaction). Save `Ann` 1/2/3 and `Ann` 4/5/6 with `validate: false`, and `Bob` 1/0/0. Call `up`. Assert one `Ann` row with 5/7/9, the lowest id kept, `Bob` unchanged, and the unique index back. Wrap calls in `ActiveRecord::Migration.suppress_messages`. Seeds: load `db/seeds.rb` two times. Assert `Player.count` is 5 and the names are unique. | `add_unique_index_to_players_name_spec.rb`, `seeds_spec.rb` |
| C13 | Model: "treats names that differ in case as two players": `Alice` and `alice` both save. Request: with `Alice` (3 wins) in the table, POST a `win` for `alice`. Assert a new row `alice` with 1 win, and `Alice` still has 3 wins. POST a `win` for `Alice` and assert the JSON name is `Alice` (case kept). | `players_spec.rb`, `player_results_spec.rb` |

## Existing tests that must change
These tests assert absolute counter bodies, the old POST or PUT flow, or removed methods.
- `frontend/src/tests/Game.test.js:14-16`: the `post` mock spreads `body.player`. Change it to return `{ id, name: body.name, wins, losses, draws }` from `body.result`.
- `Game.test.js:212-220`: the draw test asserts `{ name, wins: 0, losses: 0, draws: 1 }` POST bodies.
- `Game.test.js:231`: the `posted()` helper reads `call[1].player`. Change it to read `call[1]` and to check the URL.
- `Game.test.js:247-253` and `261-267`: the win tests assert absolute counter bodies.
- `Game.test.js:274`: the comment says that a second result would be a PUT. Change the comment.
- `frontend/src/tests/Scoreboard.test.js:21`: the `put` mock. Replace it with a `post` mock that returns the saved player.
- `Scoreboard.test.js:55-61`: tests `playerIndex`. Remove it, because the method is removed.
- `Scoreboard.test.js:62-73`: asserts a PUT of `{ wins: 21, losses: 5, draws: 10 }` to `/api/v1/players/3`. Replace it with the C5 and C7 tests.
- `Scoreboard.test.js:74-85`: relies on the PUT mock and on local counting. Change it to the C9 replace test.
- `Scoreboard.test.js:95-123`: asserts one POST and then a PUT with `{ wins: 2, ... }`. Replace it with the C9 append test.
- `backend/spec/models/players_spec.rb:7`: builds a factory player. It still passes with the new factory sequence. No change is needed, but run it.
- `backend/spec/requests/players_update_spec.rb:57-65`: POSTs `Ann` with absolute counters to `/api/v1/players`. It still passes, because the table is empty. No change.

## Commands
Backend, in `backend/`:

```sh
cp db/development.sqlite3 "$TMPDIR/development.sqlite3.bak"   # optional backup: the merge changes the dev data
rbenv exec bundle exec rails db:migrate
rbenv exec bundle exec rails db:migrate RAILS_ENV=test
rbenv exec bundle exec rails runner 'p Player.group(:name).having("COUNT(*) > 1").count'   # expect {}
rbenv exec bundle exec rspec
```

Plain `bundle exec rspec` does not work. It uses the system Ruby. `rails_helper.rb:27` (`maintain_test_schema!`) also loads the new schema into the test database, but run the test migration explicitly.

Frontend, in `frontend/`:

```sh
CI=true npm test
```

The "Network Error" log from the Scoreboard mount is noise. It does not fail a test.

## Files to stage
Stage these files:
- `sdd/13-e3-s4-link-game-outcome-to-scoreboard.md` (already committed in step 2; stage again only if it changes)
- `sdd/TODO.md`
- `backend/config/routes.rb`
- `backend/app/controllers/api/v1/players_controller.rb`
- `backend/app/models/player.rb`
- `backend/db/migrate/20260923000000_add_unique_index_to_players_name.rb`
- `backend/db/schema.rb`
- `backend/db/seeds.rb`
- `backend/spec/factories/players.rb`
- `backend/spec/models/players_spec.rb`
- `backend/spec/requests/player_results_spec.rb`
- `backend/spec/migrations/add_unique_index_to_players_name_spec.rb`
- `backend/spec/seeds_spec.rb`
- `frontend/src/components/Scoreboard.js`
- `frontend/src/tests/Game.test.js`
- `frontend/src/tests/Scoreboard.test.js`
- `plans/e3-s4-server-side-result-increments.md`

Do not stage `backend/db/development.sqlite3`, `backend/db/test.sqlite3`, `backend/log/`, `.idea/`, `backend/.idea/`, `frontend/.idea/` or `TicTacToe-ProductRequirements.pdf`. The migration changes the `.sqlite3` files, but they are not part of this fix.

## Out of scope
- The duplicate `POST /players` route at `routes.rb:6`. No E6 story names it.
- Protection of the old POST and PUT endpoints that accept absolute counters (E6-S7).
- Responses that return out of order for the same player. The row can show an older total until the next reload. The criteria do not cover it.
- The spec updates for E3-S2, E3-S3, E4-S1, E4-S3, E4-S4, E4-S7 and E5-S4. Step 6 records them as follow-up TODO items.
- The axios mock of E6-S8.

## Verification
- `rbenv exec bundle exec rspec` passes in `backend/`.
- `CI=true npm test` passes in `frontend/`.
- The new tests fail on the current code and pass after the fix. The C11 index and migration tests fail before the migration exists.
- Each criterion C1 to C13 has at least one test in the table above.
- The dev database has no duplicate names after the migration.
