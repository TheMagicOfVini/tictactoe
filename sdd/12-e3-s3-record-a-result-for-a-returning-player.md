# E3-S3 Record a result for a returning player

**Epic:** E3: Scoreboard (Front End)

**Epic goal:** players can see an all-time record of results that survives page reloads.

As a returning player, I want my existing record updated, so that my stats accumulate across sessions.

**Acceptance criteria**

- For a returning player, `updatePlayer` sends the same request as for a new player: `POST /api/v1/players/results` with the body `{ name, result }`. The client does not read the counters of the player and does not send them. The client sends no PUT.
- The server finds the player by name. It adds 1 to the matching counter with one atomic SQL update, and it does not change the other counters. If the client sends two results for the player before the first response returns, both results count.
- The server returns 200 and the saved player as JSON. The Scoreboard replaces the row with the same `id`. The other rows and the number of rows do not change.
- The above holds when the ids have gaps (for example after a delete) or when the list is not sorted by id.
