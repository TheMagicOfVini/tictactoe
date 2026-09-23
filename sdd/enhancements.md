# Enhancements

This file lists suggested improvements. These are not yet planned as fixes.

## 1. Protect or remove the PUT and DELETE player endpoints

**Related stories:** [E6-S7 Restrict CORS and protect write endpoints](32-e6-s7-restrict-cors-and-protect-write-endpoints.md), [E4-S4 Update a player's stats](17-e4-s4-update-a-player-s-stats.md), [E4-S5 Delete a player](18-e4-s5-delete-a-player.md).

Today, any caller can send `PUT /api/v1/players/:id` or `DELETE /api/v1/players/:id`. No credential check guards either route. E6-S7 fixed the CORS gap, but it did not fix this gap. This suggestion covers that remaining work.

### The facts

- The front end never calls these endpoints. `frontend/src/components/Scoreboard.js` calls only `axios.get("/api/v1/players.json")` and `axios.post("/api/v1/players/results", ...)`. No file under `frontend/src/` calls `axios.put` or `axios.delete` outside test mocks.
- The app has no auth mechanism. No gem (Devise, JWT, Doorkeeper, or similar) is in the Gemfile. No controller has a `before_action` that checks a credential.

### Two options

1. **Add an admin token.** Read a token from an env var. Check it against a header on each `PUT` and `DELETE` request. Use a secure compare (for example `ActiveSupport::SecurityUtils.secure_compare`), so the check does not leak timing information. Fail closed: if the env var is not set, or the header does not match, the app returns 401 and makes no change.
2. **Remove the routes.** Drop `PUT`, `PATCH` and `DELETE` for `/api/v1/players/:id` from `config/routes.rb`, and remove or gate the matching controller actions. This is a smaller code change, since the front end does not use these routes.

### Effect on existing tests

`backend/spec/requests/players_update_spec.rb` has 6 examples that call `PUT`. Option 1 needs new tests: a `PUT` with the correct token still passes, and a `PUT` with a missing or wrong token returns 401. Option 2 needs the file's `PUT` examples removed or rewritten to expect no route, similar to the existing "PUT /api/v1/players without an id has no route" example.
