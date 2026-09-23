# E3-S1 View the scoreboard

**Epic:** E3: Scoreboard (Front End)

**Epic goal:** players can see an all-time record of results that survives page reloads.

As a visitor, I want to see a table of every player's wins, losses and draws, so that I can compare records.

**Acceptance criteria**

- On mount, the Scoreboard fetches `GET /api/v1/players.json` and renders one row per player with Name, Wins, Losses, Draws.
- The browser tab title is set to "Tic Tac Toe".
- Fetch errors are logged to the console; the table renders empty.
