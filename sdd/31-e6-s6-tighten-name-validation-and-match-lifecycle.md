# E6-S6 Tighten name validation and match lifecycle

**Epic:** E6: Hardening & Defect Fixes

**Epic goal:** close the gaps found while mapping the code. Each story is a proposed change, not existing behaviour.

As a player, I want clean name handling, so that stats aren't split across near-duplicate names.

**Acceptance criteria**

- Names are trimmed; blank-after-trim is rejected; duplicate check is case-insensitive.
- The form shows an error message instead of silently doing nothing.
- Changing names resets the board.
