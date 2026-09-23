# E3-S2 Record a result for a new player

**Epic:** E3: Scoreboard (Front End)

**Epic goal:** players can see an all-time record of results that survives page reloads.

As a first-time player, I want my result saved automatically when a match ends, so that I appear on the scoreboard without signing up.

**Acceptance criteria**

- If the player's name is not in the loaded list, `createPlayer` POSTs `/api/v1/players` with the name and a count of 1 in the matching column (win, loss or draw).
- The new player row is appended to the table from the API response.
- An unrecognised result value shows an alert and nothing is saved.
