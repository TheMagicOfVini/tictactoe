# E4-S4 Update a player's stats

**Epic:** E4: Player Stats REST API (Back End)

**Epic goal:** a small JSON API stores players and their results.

As an API client, I want `PUT/PATCH /api/v1/players/:id`, so that result counters can be incremented.

**Acceptance criteria**

- Accepts permitted fields and persists them.
- Returns the updated player, or 422 on validation failure.
