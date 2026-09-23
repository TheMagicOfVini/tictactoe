# E6-S3 Look up players by real id

**Epic:** E6: Hardening & Defect Fixes

**Epic goal:** close the gaps found while mapping the code. Each story is a proposed change, not existing behaviour.

As a developer, I want the scoreboard to use each player's actual database id, so that updates hit the right record.

**Acceptance criteria**

- `playerIndex` returns the id from the matching player object, not the list position.
- Works when ids have gaps (e.g. after a delete).
