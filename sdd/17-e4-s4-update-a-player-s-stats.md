# E4-S4 Update a player's stats

**Epic:** E4: Player Stats REST API (Back End)

**Epic goal:** a small JSON API stores players and their results.

As an API client, I want `PUT/PATCH /api/v1/players/:id`, so that result counters can be incremented.

**Acceptance criteria**

- `PUT/PATCH /api/v1/players/:id` accepts `name`, `wins`, `losses` and `draws`, and persists them.
- On success it returns 200 and the saved player as JSON.
- On a validation failure (for example a blank `name`) it returns 422 and the player's errors as JSON. The player does not change.
- Other params (for example `result` or `slug`) are not permitted. They do not change the player and do not cause an error. The same holds for `POST /api/v1/players`.
- `PUT /api/v1/players` without an id has no route. The app has no top-level `PlayersController`.
