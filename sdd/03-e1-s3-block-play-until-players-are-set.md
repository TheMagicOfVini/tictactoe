# E1-S3 Block play until players are set

**Epic:** E1: Player Setup

**Epic goal:** two named players must be registered before a match can be played, so results can be attributed to them.

As a player, I want board clicks to be ignored until both players are named, so that every recorded game has two known participants.

**Acceptance criteria**

- Clicking a square while `playersSet` is false leaves the board unchanged.
