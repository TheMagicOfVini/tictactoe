# Protect PUT and DELETE with an admin token (E6-S7)

The CORS part of E6-S7 is in `plans/e6-s7-restrict-cors-and-protect-write-endpoints.md`. This plan covers the second criterion only.

## Context

The check (`plans/e6-s7-restrict-cors-and-protect-write-endpoints-check.md`) confirmed the gap:
- `backend/config/routes.rb:8` (`resources :players`) exposes `PUT/PATCH` and `DELETE /api/v1/players/:id`.
- `backend/app/controllers/api/v1/players_controller.rb` has no credential check. `update` and `destroy` run for any caller.
- No request spec covers `DELETE`.

The user chose the admin token option (keep both routes, add a credential).

## Criteria

From `sdd/32-e6-s7-...md`, `sdd/17-e4-s4-...md` and `sdd/18-e4-s5-...md`:

- A1: `PUT/PATCH` and `DELETE` need the `X-Admin-Token` header, equal to `ENV['ADMIN_TOKEN']`, compared in constant time and read on each request.
- A2: a missing or wrong header returns 401 and `{"error": "admin token required"}`. The player does not change (PUT) or stays (DELETE).
- A3: an unset or blank `ADMIN_TOKEN` makes every `PUT`, `PATCH` and `DELETE` return 401, even with a header.
- A4: the check runs before the player lookup. An unknown id without the credential returns 401, not 404.
- A5: with a valid credential, `PUT/PATCH` keeps its E4-S4 behavior and `DELETE` returns 204 and deletes the row.
- A6: `GET` index and show, `POST /api/v1/players` and `POST /api/v1/players/results` need no credential.

## Changes

1. `backend/app/controllers/api/v1/players_controller.rb`
   - Add `before_action :require_admin_token, only: %i[update destroy]` above `before_action :set_player`. Rails runs callbacks in declaration order, so A4 holds.
   - Add a private `require_admin_token`. It reads `ENV['ADMIN_TOKEN']` and `request.headers['X-Admin-Token']`. It renders 401 unless the expected token is present and `ActiveSupport::SecurityUtils.secure_compare` matches. `secure_compare` in Rails 5.2 hashes both sides first, so different lengths do not leak.
2. `backend/spec/requests/players_update_spec.rb`: set `ADMIN_TOKEN` in an `around` block and send the header on each PUT. Add examples for A2, A3 and A4 on PUT.
3. New `backend/spec/requests/players_destroy_spec.rb`: A2, A3, A4, A5 for DELETE.
4. New `backend/spec/requests/players_public_spec.rb`: A6, with no `ADMIN_TOKEN` set.
5. `README.md`: document `ADMIN_TOKEN` and the `X-Admin-Token` header under "Environment Variables".

The frontend does not call PUT or DELETE, so no frontend change. `rack-cors` allows `headers: :any`, so a browser preflight accepts `X-Admin-Token`.

## Verify

- `rbenv exec bundle exec rspec` in `backend/`.
- `CI=true npm test` in `frontend/` (no change expected).
