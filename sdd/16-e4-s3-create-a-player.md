# E4-S3 Create a player

**Epic:** E4: Player Stats REST API (Back End)

**Epic goal:** a small JSON API stores players and their results.

As an API client, I want `POST /api/v1/players`, so that new players can be added with an initial result.

**Acceptance criteria**

- Accepts `{ player: { name, wins, losses, draws } }`.
- Returns 201 with the created player and a Location header, or 422 with validation errors.
- If a player with the same name exists, it returns 422 and the error `name: ["has already been taken"]`. It creates no second player.
