# E2-S4 Detect a win

**Epic:** E2: Core Gameplay

**Epic goal:** two people can play a standard game of tic-tac-toe on one device.

As a player, I want the game to recognise three in a row, so that the winner is declared automatically.

**Acceptance criteria**

- `calculateWinner` checks all 8 lines (3 rows, 3 columns, 2 diagonals) and returns the mark that fills any of them, otherwise `null`.
- When a winner exists the status reads "Winner: `<name>`" and further clicks are ignored.
