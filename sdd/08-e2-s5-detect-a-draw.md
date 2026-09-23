# E2-S5 Detect a draw

**Epic:** E2: Core Gameplay

**Epic goal:** two people can play a standard game of tic-tac-toe on one device.

As a player, I want the game to declare a draw when the board fills with no winner, so that the match has a clear outcome.

**Acceptance criteria**

- When no square is null and there is no winner, the status reads "The game is a draw!".
- When the game ends in a draw, each player receives exactly one +1 draw on the scoreboard, through the same scoreboard ref that the win branches use (`this.scoreboard.current.updatePlayer(name, "draw")`).
- A draw does not throw an error.
