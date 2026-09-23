# E3-S4 Link game outcome to scoreboard

**Epic:** E3: Scoreboard (Front End)

**Epic goal:** players can see an all-time record of results that survives page reloads.

As a player, I want the winner credited with a win and the loser with a loss, so that the scoreboard reflects the match.

**Acceptance criteria**

- On an O win: Player One +1 win, Player Two +1 loss. On an X win: the reverse.
- On a draw: both players +1 draw.
- The board sends the results once, from the move handler, at the move that ends the game. `render()` sends no request.
- After the game ends, more renders send no request. Examples: a submit of the same names, a submit of names that are not valid, a click on a square.
- If a second result for a new player arrives before the POST for that player returns, the Scoreboard waits for that POST. It then PUTs the second result to the new id. The table has one row for the player.
