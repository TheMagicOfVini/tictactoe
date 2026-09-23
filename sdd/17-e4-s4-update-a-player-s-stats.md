# E4-S4 Update a player's stats

**Epic:** E4: Player Stats REST API (Back End)

**Epic goal:** a small JSON API stores players and their results.

As an API client, I want `PUT/PATCH /api/v1/players/:id`, so that result counters can be incremented.

**Acceptance criteria**

- With a valid admin credential, `PUT/PATCH /api/v1/players/:id` accepts `name`, `wins`, `losses` and `draws`, and persists them. It sets the counters to the values that it gets. It does not add to them.
- On success it returns 200 and the saved player as JSON.
- On a validation failure (for example a blank `name`) it returns 422 and the player's errors as JSON. The player does not change.
- If the request sets `name` to the name of another player, it returns 422 and the error `name: ["has already been taken"]`. The player does not change.
- Other params (for example `result` or `slug`) are not permitted. They do not change the player and do not cause an error. The same holds for `POST /api/v1/players`.
- `PUT /api/v1/players` without an id has no route. The app has no top-level `PlayersController`.
- The request must send the admin credential in the `X-Admin-Token` header. The header must match `ENV['ADMIN_TOKEN']`. A missing or wrong header, or an unset or blank `ADMIN_TOKEN`, returns 401 and `{"error": "admin token required"}`. The player does not change. The check runs before the player lookup, so an unknown id also returns 401 ([E6-S7](32-e6-s7-restrict-cors-and-protect-write-endpoints.md)).
- The client does not use this endpoint to record a result. It uses `POST /api/v1/players/results` (E3-S4).
