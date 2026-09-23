# E3-S4 Link game outcome to scoreboard

**Epic:** E3: Scoreboard (Front End)

**Epic goal:** players can see an all-time record of results that survives page reloads.

As a player, I want the winner credited with a win and the loser with a loss, so that the scoreboard reflects the match.

**Acceptance criteria**

- On an O win: Player One +1 win, Player Two +1 loss. On an X win: the reverse.
- On a draw: both players +1 draw.
- The board sends the results once, from the move handler, at the move that ends the game. `render()` sends no request.
- After the game ends, more renders send no request. Examples: a submit of the same names, a submit of names that are not valid, a click on a square.
- For each player, the client sends one request: `POST /api/v1/players/results` with the body `{ name, result }`. `result` is `win`, `loss` or `draw`. The client sends the same request for a new player and for a known player. The body has no `id`, `wins`, `losses` or `draws`. The client sends no POST or PUT to `/api/v1/players`.
- `POST /api/v1/players/results` takes the name from the JSON body, not from the path. For a new name, it creates the player with 1 in the matching counter and 0 in the other counters. For a known name, it adds 1 to the matching counter and does not change the other counters. A name with spaces, `/` or `.` (for example `Dr. J / 2`) works.
- The server adds 1 with one atomic SQL update (`SET wins = wins + 1`). It does not read the counter, add 1 in Ruby and save the total. If the client sends two results for the same player before the first response returns, both results count. Example: two wins for a known player with 3 wins give 5 wins.
- If two requests for the same new name arrive at the same time, the server makes one row, and both results count. The server rescues `ActiveRecord::RecordNotUnique` and finds the player again.
- On success, the endpoint returns 200 and the saved player as JSON. The Scoreboard puts this player in the table. It replaces the row with the same `id`, or it appends a row. The table has one row for each name.
- If `result` is not `win`, `loss` or `draw`, or if `name` is blank, the endpoint returns 422 and the errors as JSON. It creates no player and changes no counter.
- Player names are unique. The `players` table has a unique index on `name`. The `Player` model validates the uniqueness of `name`, so a second player with the same name is not valid.
- The migration that adds the unique index first merges the players that have the same name. It keeps one row for each name, with the sum of `wins`, `losses` and `draws`. A second `db:seed` makes no duplicate player.
- The server matches names exactly as it gets them. The match is case-sensitive: `Alice` and `alice` are two players. The server does not change the case of a name. The form check of E6-S6 is a separate rule.
