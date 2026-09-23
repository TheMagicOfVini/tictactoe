# E4-S2 List and fetch players

**Epic:** E4: Player Stats REST API (Back End)

**Epic goal:** a small JSON API stores players and their results.

As an API client, I want `GET /api/v1/players` and `GET /api/v1/players/:id`, so that I can display the scoreboard.

**Acceptance criteria**

- Index returns all players as a JSON array; show returns a single player.
- Unknown id returns 404 (`ActiveRecord::RecordNotFound`).
