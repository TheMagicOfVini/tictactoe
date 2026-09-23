# E2-S3 Take turns placing marks

**Epic:** E2: Core Gameplay

**Epic goal:** two people can play a standard game of tic-tac-toe on one device.

As a player, I want to click an empty square to place my mark and hand the turn to my opponent, so that play alternates correctly.

**Acceptance criteria**

- Clicking an empty square places "X" or "O" according to whose turn it is, then toggles the turn.
- Clicking an already-claimed square does nothing.
- The status line reads "`<name>`'s turn!" for the player due to move.
