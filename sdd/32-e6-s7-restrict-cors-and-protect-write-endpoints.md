# E6-S7 Restrict CORS and protect write endpoints

**Epic:** E6: Hardening & Defect Fixes

**Epic goal:** close the gaps found while mapping the code. Each story is a proposed change, not existing behaviour.

As a site operator, I want only the app's own origin to modify data, so that anyone on the internet can't edit or delete scoreboard entries.

**Acceptance criteria**

- CORS origins come from configuration instead of `*` (E4-S6).
- `PUT/PATCH /api/v1/players/:id` (E4-S4) and `DELETE /api/v1/players/:id` (E4-S5) require an admin credential:
  - The client sends the credential in the `X-Admin-Token` request header.
  - The app compares the header with `ENV['ADMIN_TOKEN']` in constant time. It reads the variable on each request.
  - A request with a missing or wrong header returns 401 and `{"error": "admin token required"}`. The player does not change.
  - When `ADMIN_TOKEN` is not set or is blank, every `PUT`, `PATCH` and `DELETE` request returns 401. The check fails closed in each environment.
  - The app checks the credential before it looks up the player, so a request without the credential gets 401 for an unknown id too, not 404.
- `GET /api/v1/players`, `GET /api/v1/players/:id`, `POST /api/v1/players` and `POST /api/v1/players/results` need no credential.
