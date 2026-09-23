# E4-S5 Delete a player

**Epic:** E4: Player Stats REST API (Back End)

**Epic goal:** a small JSON API stores players and their results.

As an administrator, I want `DELETE /api/v1/players/:id`, so that unwanted entries can be removed.

**Acceptance criteria**

- With a valid admin credential, `DELETE /api/v1/players/:id` deletes the record and returns 204 No Content.
- The request must send the admin credential in the `X-Admin-Token` header. The header must match `ENV['ADMIN_TOKEN']`. A missing or wrong header, or an unset or blank `ADMIN_TOKEN`, returns 401 and `{"error": "admin token required"}`. The record stays in the database ([E6-S7](32-e6-s7-restrict-cors-and-protect-write-endpoints.md)).
- The check runs before the player lookup, so an unknown id without the credential returns 401, not 404.
