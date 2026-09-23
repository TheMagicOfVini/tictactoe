# E6-S7 Restrict CORS and protect write endpoints

**Epic:** E6: Hardening & Defect Fixes

**Epic goal:** close the gaps found while mapping the code. Each story is a proposed change, not existing behaviour.

As a site operator, I want only the app's own origin to modify data, so that anyone on the internet can't edit or delete scoreboard entries.

**Acceptance criteria**

- CORS origins come from configuration instead of `*`.
- DELETE (and ideally direct PUT) require an admin credential or are removed from the public API.
