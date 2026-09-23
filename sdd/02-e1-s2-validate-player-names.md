# E1-S2 Validate player names

**Epic:** E1: Player Setup

**Epic goal:** two named players must be registered before a match can be played, so results can be attributed to them.

As a player, I want the game to reject an incomplete or duplicate pairing, so that results are never credited to a blank or ambiguous player.

**Acceptance criteria**

- Leading and trailing whitespace is removed from both names before validation and storage.
- Players are considered "set" only when both trimmed names are non-empty and different from each other, ignoring case (`playersSet`).
- If a submitted pair is not valid, the pair is rejected: the current names stay unchanged and the form shows an error message that states the problem (a blank name, or two names that are the same).
- When a valid pair changes the names, the board resets in the same way as New Game (E2-S6).
- Until players are set, the header reads "Set the names of both players." and no status line is shown.
- Once set, the header shows "`<Player One>` Vs. `<Player Two>`".
