# E6-S7 Restrict CORS and protect write endpoints: Check

Story: `sdd/32-e6-s7-restrict-cors-and-protect-write-endpoints.md`.

## TODO gaps

The TODO item lists two criteria. Both are confirmed as current gaps.

- **CORS origins come from configuration instead of `*`.** Confirmed.
  `backend/config/initializers/cors.rb:3` sets `origins '*'`. The value is a literal string. No environment variable or config setting feeds it. `backend/config/environments/development.rb`, `test.rb` and `production.rb` do not set any CORS-related value.
- **DELETE (and ideally direct PUT) require an admin credential or are removed from the public API.** Confirmed.
  `backend/config/routes.rb:8` uses `resources :players`, so it exposes `DELETE /api/v1/players/:id` and `PUT/PATCH /api/v1/players/:id`. `backend/app/controllers/api/v1/players_controller.rb:6` sets a `before_action :set_player` for `show`, `update` and `destroy`, but no `before_action` checks a credential. The `destroy` action (`players_controller.rb:58-60`) and the `update` action (`players_controller.rb:32-38`) run for any caller. No gem or code in the app performs authentication. `grep` for "admin", "api_key", "token" and "secret" across `backend/config` and `backend/app` found no match beyond the CORS header name `access-token` (a header the app never checks) and Rails' own `secret_key_base`.

## Gaps not in TODO

- The E4-S6 spec itself states the insecure target as the intended behavior: `sdd/19-e4-s6-allow-cross-origin-requests.md` says "`rack-cors` allows all origins and GET/POST/PUT/PATCH/DELETE/OPTIONS/HEAD." This spec, not just the code, describes the `*` origin as correct. Step 3 must rewrite this spec, or the code fix would violate it.
- The E4-S4 spec (`sdd/17-e4-s4-update-a-player-s-stats.md`) already has a forward reference: "PUT still accepts absolute counters; [E6-S7]... covers the protection of this endpoint." This confirms E4-S4 is the spec that should gain the write-protection criterion for PUT.
- The E4-S5 spec (`sdd/18-e4-s5-delete-a-player.md`) has only one criterion, "Deletes the record and returns 204 No Content," with no mention of who may call it. This is the spec that should gain the write-protection criterion for DELETE.
- No request spec exercises `DELETE /api/v1/players/:id` at all. `backend/spec/requests/` has only `player_results_spec.rb` and `players_update_spec.rb`. A DELETE spec is missing regardless of the auth question, and E6-S8 (test coverage) already flags "destroy" as a gap in test coverage, so this overlaps E6-S8.
- The frontend never calls PUT or DELETE. `frontend/src/components/Scoreboard.js` only calls `axios.get("/api/v1/players.json")` and `axios.post("/api/v1/players/results", ...)`. No file under `frontend/src/` calls `axios.put` or `axios.delete` outside test mocks. This is a design fact, not itself a spec violation, but it bears directly on the "or are removed from the public API" option in the E6-S7 criterion.

## Story references

- The E6-S7 item in `sdd/TODO.md` has no linked gap in any E1-E5 story section (unlike E6-S1 through E6-S6, each of which the TODO traces to a specific gap under an earlier epic's story). The E4-S4 entry references E6-S7 only in passing ("[E6-S7] covers the protection of this endpoint"), and no E4-S5 (Delete a player) entry exists in the TODO at all.
- This matches the task framing: no story section above the E6 heading lists a gap for E6-S7 with a `file:line`. The gap for E6-S7 lives in the E4-S6 spec text itself (which states `*` as intended behavior) and in the E4-S4/E4-S5 specs (which are silent on protection), not in a "gap found while mapping the code" bullet.

## Specs to rewrite

Recommend step 3 rewrite three specs:

1. **`sdd/19-e4-s6-allow-cross-origin-requests.md`** (required). Its current criterion, "`rack-cors` allows all origins," is the literal target that E6-S7 must undo. Step 3 must replace "allows all origins" with a criterion that origins come from configuration.
2. **`sdd/17-e4-s4-update-a-player-s-stats.md`** (required). It already carries the forward reference to E6-S7 for PUT protection. Step 3 should turn that reference into a real acceptance criterion (for example, a credential requirement or removal from the public API).
3. **`sdd/18-e4-s5-delete-a-player.md`** (required). It has no protection criterion at all. Step 3 should add one, matching whatever the PUT criterion says, since the E6-S7 story groups DELETE and PUT together.

The E6-S7 story spec (`sdd/32-e6-s7-restrict-cors-and-protect-write-endpoints.md`) also gets rewritten per the standard process (step 3 always rewrites the target story's acceptance criteria first), but the target behavior these criteria state belongs in the E4 specs above, per the CLAUDE.md instruction.

## Design choices

Before step 3, the user must decide:

1. **PUT and DELETE: remove them from the public API, or protect them with a credential?**
   The E6-S7 acceptance criteria say "require an admin credential or are removed from the public API," so both are valid readings. Facts that bear on this:
   - The frontend never calls PUT or DELETE (confirmed above), so removing them breaks no current client behavior.
   - `backend/spec/requests/players_update_spec.rb` has 6 examples that test PUT behavior (valid update, blank name, duplicate name, unpermitted params, no-id route). Removing PUT from the public API would delete or repurpose this test file. Protecting PUT with a credential would need new tests (with and without the credential) instead.
   - No DELETE request spec exists yet, so either choice starts from zero tests for DELETE.
   - Adding a credential means adding an authentication mechanism where none exists today: no gem (Devise, JWT, Doorkeeper, or similar) is in the Gemfile, and no `before_action` for auth exists in any controller. A credential check would likely be the simplest new code: a `before_action` that compares a header or param against an env var, returning 401 on mismatch.
   - Removing PUT and DELETE from the public API is the smaller change (edit `routes.rb` and remove or gate the controller actions) but is a larger behavior change relative to the existing E4-S4 and E4-S5 specs, which currently describe PUT and DELETE as ordinary public endpoints.

2. **If a credential is chosen: what is the env var name, and what happens with no credential set?**
   No existing convention exists in this codebase to follow (no `.env` file, no `.env.example`, no credential-reading code anywhere). The user must pick a name (for example `ADMIN_TOKEN`) and decide the header or param that carries it (for example `X-Admin-Token`), and decide whether a missing/blank env var in an environment (such as test or development) disables the check, denies all requests, or requires a fixed default. Rails' own `config/master.key` / `Rails.application.credentials` mechanism is present in `backend/config/storage.yml` comments only; it is unused elsewhere, so the user must decide whether to use Rails credentials or a plain `ENV[...]` read.

3. **CORS origins: what env var name, and what default per environment?**
   Facts:
   - No env var exists today for this. `cors.rb:3` hardcodes `'*'`.
   - Local dev without Docker: backend runs on port 3001, frontend dev server on port 3000 (`sdd/21-e5-s1-run-locally-without-docker.md`), and `frontend/package.json` sets `"proxy": "http://0.0.0.0:3001"`. The CRA dev-server proxy means the browser talks to `localhost:3000`, and CRA proxies API calls server-side to port 3001, so cross-origin CORS may not even be exercised by the proxy path in dev; CORS matters if anything calls the API directly cross-origin (for example RSpec request specs, which bypass CORS since they call the Rack app directly, or a browser hitting `:3001` directly).
   - Docker: same ports (3000, 3001) are exposed per `docker-compose.yml:11-13` and `sdd/22-e5-s2-run-in-docker.md`.
   - Production (Heroku): `sdd/25-e5-s5-hosted-deployment.md` says "the React build served alongside the API," meaning same origin in production. If that stays true, production CORS could be locked down to no cross-origin allowance, or to the Heroku URL itself as a defensive same-origin allowance. The user must confirm whether production still serves both from one origin or whether a separate frontend host is planned.
   - The user must pick: an env var name (for example `CORS_ORIGINS`, comma-separated), a default for development and test (likely `http://localhost:3000`), and a default or required value for production (the Heroku URL, or none if same-origin).

4. **Test environment implication.** `backend/spec/requests/players_update_spec.rb` currently issues PUT requests directly through Rack (no browser, so no CORS enforcement applies there; CORS is a browser-enforced check on cross-origin fetch/XHR, not on server-to-server or RSpec requests). If PUT gets an admin-credential requirement, these specs must add the credential to keep passing; if PUT is removed, these specs must be deleted or rewritten to expect no route (similar to the existing "PUT /api/v1/players without an id has no route" pattern at `players_update_spec.rb:80-90`).

## Test environment

- Backend tests: `rbenv exec bundle exec rspec` run from `backend/`. Result: **42 examples, 0 failures**. Only warnings are Faker deprecation notices and an RSpec `should` syntax deprecation notice (from `players_spec.rb:18`); neither is a failure.
- Frontend tests run with `CI=true npm test` in `frontend/`. Not run in this check step (step 2 is read-only; no code or tests changed).
