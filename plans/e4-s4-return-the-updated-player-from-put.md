# Return the updated player from PUT (E4-S4, E6-S4)

## Context
The check of TODO item E4-S4 found that `update` in `backend/app/controllers/api/v1/players_controller.rb:30-36` renders `@list`, which nothing sets. A successful PUT returns `null`. A failed PUT calls `@list.errors` and returns a 500, not a 422. A PUT with a blank `name` fails the model validation (`app/models/player.rb:4`), so a client can reach this branch.

The check also found gaps that E6-S4 covers but the TODO does not list:
- `config/routes.rb:4` maps `PUT /api/v1/players` (no id) to the top-level `PlayersController`. Its `set_player` calls `Player.find(nil)`, so the route always returns 404.
- Only that route uses `app/controllers/players_controller.rb`.
- The API controller permits `:result` (`api/v1/players_controller.rb:54`), but the `players` table has no such column (`db/schema.rb:15-22`). A POST or PUT with `result` raises `UnknownAttributeError` and returns a 500. The top-level controller permits `:slug` (`players_controller.rb:49`), which is not a column either.
- No request spec covers `update`.

The TODO item says only "(see E6-S4)" and does not link to the story file.

## Steps
1. Save this plan as `plans/e4-s4-return-the-updated-player-from-put.md`.
2. Spec: edit `sdd/17-e4-s4-update-a-player-s-stats.md`. Keep the title, the epic lines and the user story. Replace the acceptance criteria with:

   ```
   **Acceptance criteria**

   - `PUT/PATCH /api/v1/players/:id` accepts `name`, `wins`, `losses` and `draws`, and persists them.
   - On success it returns 200 and the saved player as JSON.
   - On a validation failure (for example a blank `name`) it returns 422 and the player's errors as JSON. The player does not change.
   - Other params (for example `result` or `slug`) are not permitted. They do not change the player and do not cause an error. The same holds for `POST /api/v1/players`.
   - `PUT /api/v1/players` without an id has no route. The app has no top-level `PlayersController`.
   ```

3. Branch: create `fix/e4-s4-return-the-updated-player-from-put` from `master`.
4. Fix:
   - `api/v1/players_controller.rb`: `update` renders `@player` on success and `@player.errors` with 422 on failure. Fix the indent of the action.
   - `api/v1/players_controller.rb`: remove `:result` from `player_params`.
   - `config/routes.rb`: remove the `match '/api/v1/players' => 'players#update'` line.
   - Delete `app/controllers/players_controller.rb`.
5. Tests: add `backend/spec/requests/players_update_spec.rb` (type `:request`, with the `json` helper from `RequestSpecHelper`):
   - A valid PUT returns 200, the JSON has the new counters, and the database row has them.
   - A PUT with a blank `name` returns 422, the JSON has a `name` error, and the row does not change.
   - A PUT with `result` and `slug` returns 200 and ignores them.
   - A POST with `result` returns 201 and ignores it.
   - `PUT /api/v1/players` without an id raises `ActionController::RoutingError`, and `PlayersController` is not defined.
   - Run `rbenv exec bundle exec rspec` in `backend/` and `CI=true npm test` in `frontend/`.
6. TODO: in `sdd/TODO.md`, check off the E4-S4 item and link it to the E6-S4 file. Add and check off the unlisted gaps: the 500 on a failed update, the stray route and controller, the `:result` param that causes a 500, and the missing test. Check off E6-S4 and its three criteria.
7. Commit: stage only the spec, `sdd/TODO.md`, the controller, the deleted controller, `routes.rb`, the new spec and this plan.

## Out of scope
- The duplicate `POST /players` route at `routes.rb:7`. No E6 story names it.
- Request specs for index, show, create and destroy (E6-S8).
- Server-side increments and unique names (E6-S5).
- Protection of the write endpoints (E6-S7).

## Verification
- Both test suites pass.
- The new specs fail on the `master` code, except the tests that only add coverage, and pass after the fix.
- Each criterion in the new spec has a test.
