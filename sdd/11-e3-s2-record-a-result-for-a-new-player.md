# E3-S2 Record a result for a new player

**Epic:** E3: Scoreboard (Front End)

**Epic goal:** players can see an all-time record of results that survives page reloads.

As a first-time player, I want my result saved automatically when a match ends, so that I appear on the scoreboard without signing up.

**Acceptance criteria**

- For a new player, `updatePlayer` sends one request: `POST /api/v1/players/results` with the body `{ name, result }`. `result` is `win`, `loss` or `draw`. The body has no `id`, `wins`, `losses` or `draws`. The client does not look for the name in the loaded list. It sends the same request for a new player and for a known player.
- The server does not find the name, so it creates the player with 1 in the matching counter and 0 in the other counters.
- The server returns 200 and the saved player as JSON. The Scoreboard appends this player to the table. If a second result for the same new player returns later, the Scoreboard replaces that row by `id`. The table has one row for the player.
- If `result` is not `win`, `loss` or `draw`, the server returns 422 and saves nothing. The client logs the error and does not change the table. The client shows no alert.
