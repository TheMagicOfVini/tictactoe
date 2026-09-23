# E6-S4 Return the updated player from PUT

**Epic:** E6: Hardening & Defect Fixes

**Epic goal:** close the gaps found while mapping the code. Each story is a proposed change, not existing behaviour.

As an API client, I want the update endpoint to return the saved player, so that clients can trust the response.

**Acceptance criteria**

- `update` renders `@player` / `@player.errors`.
- The stray `PUT /api/v1/players` route (no id, pointing at the non-namespaced controller) and the unused top-level `PlayersController` are removed.
- Unused `:result` / `:slug` params are removed from the permit lists.
