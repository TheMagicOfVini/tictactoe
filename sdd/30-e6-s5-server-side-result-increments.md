# E6-S5 Server-side result increments

**Epic:** E6: Hardening & Defect Fixes

**Epic goal:** close the gaps found while mapping the code. Each story is a proposed change, not existing behaviour.

As a product owner, I want the server to increment counters, so that concurrent sessions can't overwrite each other's totals.

**Acceptance criteria**

- New endpoint (e.g. `POST /api/v1/players/:name/results` with `result: win|loss|draw`) finds-or-creates the player and increments atomically.
- Client stops sending absolute counter values.
- Player names are unique (DB index + model validation).
