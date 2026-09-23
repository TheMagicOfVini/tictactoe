# E3-S3 Record a result for a returning player

**Epic:** E3: Scoreboard (Front End)

**Epic goal:** players can see an all-time record of results that survives page reloads.

As a returning player, I want my existing record updated, so that my stats accumulate across sessions.

**Acceptance criteria**

- `playerIndex` returns the `id` of the loaded player object whose name matches, or `null` when no player matches. It does not use the position in the list.
- If the name exists, `updatePlayer` takes the current counters from that player object, increments the counter that matches the result, and PUTs `/api/v1/players/:id` with that player's `id`.
- On success only the row of that player updates, in place. The other rows and the number of rows do not change.
- The above holds when the ids have gaps (for example after a delete) or when the list is not sorted by id.
