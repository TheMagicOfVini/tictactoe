# E3-S3 Record a result for a returning player

**Epic:** E3: Scoreboard (Front End)

**Epic goal:** players can see an all-time record of results that survives page reloads.

As a returning player, I want my existing record updated, so that my stats accumulate across sessions.

**Acceptance criteria**

- If the name exists, `updatePlayer` increments the correct counter and PUTs `/api/v1/players/:id`.
- On success the row updates in place.
