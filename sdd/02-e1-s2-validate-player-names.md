# E1-S2 Validate player names

**Epic:** E1: Player Setup

**Epic goal:** two named players must be registered before a match can be played, so results can be attributed to them.

As a player, I want the game to reject an incomplete or duplicate pairing, so that results are never credited to a blank or ambiguous player.

**Acceptance criteria**

- Players are considered "set" only when both names are non-empty and different from each other (`playersSet`).
- Until players are set, the header reads "Set the names of both players." and no status line is shown.
- Once set, the header shows "`<Player One>` Vs. `<Player Two>`".
