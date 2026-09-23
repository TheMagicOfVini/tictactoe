# E6-S1 Fix crash on draw

**Epic:** E6: Hardening & Defect Fixes

**Epic goal:** close the gaps found while mapping the code. Each story is a proposed change, not existing behaviour.

As a player, I want a drawn game to record correctly, so that the app doesn't break when the board fills up.

**Acceptance criteria**

- The draw branch calls `this.scoreboard.current.updatePlayer(...)` (matching the win branches).
- A test covers a full-board draw and asserts both players receive +1 draw.
