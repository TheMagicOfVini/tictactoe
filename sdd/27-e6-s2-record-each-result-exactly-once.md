# E6-S2 Record each result exactly once

**Epic:** E6: Hardening & Defect Fixes

**Epic goal:** close the gaps found while mapping the code. Each story is a proposed change, not existing behaviour.

As a player, I want a finished game counted once, so that stats aren't inflated or duplicated.

**Acceptance criteria**

- Score updates move out of `render()` into the move handler (or `componentDidUpdate` guarded by a "result recorded" flag).
- Re-renders after a game ends make no further API calls.
- Two quick results for a brand-new player don't create duplicate rows.
