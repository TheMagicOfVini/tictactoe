# Restrict CORS to configured origins (E6-S7)

## Context

The step 2 check (`plans/e6-s7-restrict-cors-and-protect-write-endpoints-check.md`) confirmed the CORS gap:
- `backend/config/initializers/cors.rb:3` sets `origins '*'`. No environment variable feeds it.

The step 3 spec rewrite put the target behavior in `sdd/19-e4-s6-allow-cross-origin-requests.md`. This plan numbers its criteria C1 to C7, in the order of the file:
- C1: the app reads `ENV['CORS_ORIGINS']`, a comma-separated list. It trims spaces and drops empty entries.
- C2: in development and in test, the app uses `http://localhost:3000` when `CORS_ORIGINS` is not set.
- C3: in production, `CORS_ORIGINS` is required. The app fails to boot and shows a clear error when it is not set or is blank.
- C4: the app never uses `*` as a default origin.
- C5: `rack-cors` allows GET, POST, PUT, PATCH, DELETE, OPTIONS and HEAD for each allowed origin.
- C6: a request from an allowed origin gets `Access-Control-Allow-Origin`. A request from another origin does not.
- C7: the React dev server proxies API calls to `http://0.0.0.0:3001`.

The story spec `sdd/32-e6-s7-restrict-cors-and-protect-write-endpoints.md` now says this fix covers only CORS. The `PUT` and `DELETE` protection moves to `sdd/enhancements.md`, item 1. This plan does not touch `PUT`, `DELETE`, `sdd/17-e4-s4-update-a-player-s-stats.md` or `sdd/18-e4-s5-delete-a-player.md`.

## Design decisions

### Where the origin list is parsed

Add a new class, `CorsOrigins`, in `backend/app/lib/cors_origins.rb`. `app/lib` is a direct child of `app`, so Rails autoloads it like `app/models` or `app/controllers`. No autoload path config change is needed.

`CorsOrigins` takes its inputs as plain arguments, not from `ENV` or `Rails.env` directly:

```ruby
# frozen_string_literal: true

# Parses the CORS_ORIGINS environment variable into a list of allowed origins.
class CorsOrigins
  # Raised when CORS_ORIGINS is missing or blank in production.
  class MissingOriginsError < StandardError; end

  DEFAULT_ORIGIN = 'http://localhost:3000'

  # env: a hash with a "CORS_ORIGINS" key, such as ENV.
  # rails_env: a string, such as "development", "test" or "production".
  def self.list(env, rails_env)
    origins = parse(env['CORS_ORIGINS'])

    if rails_env == 'production'
      raise_missing_origins if origins.empty?
      return origins
    end

    origins.empty? ? [DEFAULT_ORIGIN] : origins
  end

  # Splits a comma-separated string. Trims each entry. Drops empty entries.
  def self.parse(raw)
    return [] if raw.nil?

    raw.split(',').map(&:strip).reject(&:empty?)
  end

  def self.raise_missing_origins
    raise MissingOriginsError,
          'CORS_ORIGINS must be set in production. Set it to a comma-separated list of allowed origins.'
  end
  private_class_method :raise_missing_origins
end
```

A test can call `CorsOrigins.list(a_plain_hash, 'production')` or `CorsOrigins.parse(a_string)` on its own. It does not reboot Rails and does not read or write the real `ENV`. This is the same reason no test in this plan mutates `ENV`: each test builds its own hash, such as `{ 'CORS_ORIGINS' => 'http://a.com' }`, and passes it in. One test's input can never leak into another test, because no test changes shared state.

`backend/config/initializers/cors.rb` changes from:

```ruby
origins '*'
```

to:

```ruby
origins CorsOrigins.list(ENV, Rails.env)
```

`Rack::Cors#origins` flattens its argument (`rack-cors` 1.1.1, `lib/rack/cors.rb:292-304`), so passing an array works the same as passing each origin as its own argument. The `resource '*', methods: [...]` block does not change. It already lists GET, POST, PUT, PATCH, DELETE, OPTIONS and HEAD (C5), so this criterion needs a test but not a code change.

### How the production boot check fails

`CorsOrigins.list` raises `CorsOrigins::MissingOriginsError`, a `StandardError` subclass, when `rails_env` is `"production"` and the parsed origin list is empty (because `CORS_ORIGINS` is unset, or because it is blank, such as `""` or `" , "`, which parses to an empty list). The message is:

> CORS_ORIGINS must be set in production. Set it to a comma-separated list of allowed origins.

`config/initializers/cors.rb` calls `CorsOrigins.list(ENV, Rails.env)` with no rescue, so the exception is not caught. It propagates out of `Rails.application.initialize!` (`backend/config/environment.rb:5`) and stops the boot. `rails server`, `rails runner` and `rails console` all print the error and exit before the app can serve a request.

### How a request spec proves the allowed-origin behavior (C6)

`backend/config/environments/test.rb` has no `CORS_ORIGINS` setting, so `CorsOrigins.list` returns the default, `http://localhost:3000`, when the test suite boots. A request spec cannot change this after boot, because the `Rack::Cors` middleware reads the origin list once, when `config/initializers/cors.rb` runs. So the spec does not try to reconfigure CORS. It sends two requests to an existing route and reads the `Origin` header each one carries:

- `Origin: http://localhost:3000` (the test default) must return a response with `Access-Control-Allow-Origin: http://localhost:3000`.
- `Origin: http://evil.example` (not in the list) must return a response with no `Access-Control-Allow-Origin` header.

This proves both halves of C6 with the app's real, booted middleware, and it needs no reboot.

### Docs and config that must name `CORS_ORIGINS`

- `README.md` has no environment-variable section today. Add one, so a developer knows the variable exists before they hit the production boot check or a blocked browser request.
- `docker-compose.yml:9-13` already passes `PASSWORD` from the host shell into the container with a bare `- PASSWORD` line. Add `- CORS_ORIGINS` the same way, so a developer can override the default from outside the container.
- `sdd/25-e5-s5-hosted-deployment.md` is a spec file. Step 3 did not add `CORS_ORIGINS` to its acceptance criteria, so this plan does not edit it. The production value belongs in README instead, next to the existing live-demo link (`README.md:6`), because there is no separate deployment-notes file in this repo.
- No other file names an origin or a port that CORS depends on, besides `frontend/package.json:5` (`"proxy": "http://0.0.0.0:3001"`), which is C7 and does not change.

## Steps

1. Save this plan to `plans/e6-s7-restrict-cors-and-protect-write-endpoints.md`. Done when the file exists.
2. Stay on branch `fix/e6-s7-restrict-cors-and-protect-write-endpoints`.
3. Backend fix, in `backend/`:
   - Add `app/lib/cors_origins.rb` with the class from "Design decisions" above.
   - Edit `config/initializers/cors.rb:3`: replace `origins '*'` with `origins CorsOrigins.list(ENV, Rails.env)`.
4. Backend tests, in `backend/`:
   - Add `spec/lib/cors_origins_spec.rb` (new; plain `RSpec.describe CorsOrigins`, no Rails request or model context).
   - Add `spec/requests/cors_spec.rb` (new; `type: :request`).
5. Docs and config:
   - `README.md`: add an "## Environment Variables" section after "## Requirements" and before "## Running With Docker". State the variable name, the comma-separated format, the development/test default, and the production requirement. Note the value to set for the live Heroku demo (the app's own URL, since E5-S5 serves the API and the React build from one origin).
   - `docker-compose.yml`: in the `web` service's `environment:` list (currently `- PASSWORD` and `- BUNDLE_PATH=...`), add `- CORS_ORIGINS`.
6. Run the tests. See "Commands".
7. TODO (CLAUDE.md step 6, done in the Fix step, not in this plan): check off the two E6-S7 items in `sdd/TODO.md` and the E6-S7 story heading. No other TODO item closes, because the PUT/DELETE gap moved to `sdd/enhancements.md` in step 3, and step 3 did not list any further gap under E6-S7.
8. Commit (CLAUDE.md step 7). See "Files to stage".

## Tests for each criterion

| Criterion | Test | File |
|---|---|---|
| C1 | "trims spaces and drops empty entries": `CorsOrigins.parse(" http://a.com , ,http://b.com ")` returns `['http://a.com', 'http://b.com']`. "returns the origins from CORS_ORIGINS" for `rails_env` `"development"`, `"test"` and `"production"`. | `spec/lib/cors_origins_spec.rb` |
| C2 | "returns the default origin for development when CORS_ORIGINS is not set" and the same for `"test"`. Call `CorsOrigins.list({}, 'development')` and `CorsOrigins.list({}, 'test')`; each returns `['http://localhost:3000']`. | `spec/lib/cors_origins_spec.rb` |
| C3 | "raises for production when CORS_ORIGINS is not set": `CorsOrigins.list({}, 'production')` raises `CorsOrigins::MissingOriginsError` with the exact message. "raises for production when CORS_ORIGINS is blank": same, with `{ 'CORS_ORIGINS' => '  , ,' }`. "returns the origins for production when CORS_ORIGINS is set": no raise, returns the parsed list. | `spec/lib/cors_origins_spec.rb` |
| C4 | "the default origin is not `*`": `CorsOrigins::DEFAULT_ORIGIN` does not equal `'*'`. "a blank CORS_ORIGINS in development never returns `*`": `CorsOrigins.list({}, 'development')` does not include `'*'`. | `spec/lib/cors_origins_spec.rb` |
| C5 | "preflights DELETE, PUT and PATCH for the test default origin": send `process :options, '/api/v1/players/1', headers: { 'Origin' => 'http://localhost:3000', 'Access-Control-Request-Method' => 'DELETE' }`; assert `response.headers['Access-Control-Allow-Methods']` includes `DELETE`, `PUT`, `PATCH`, `GET`, `POST`, `HEAD`. | `spec/requests/cors_spec.rb` |
| C6 | "allows the test default origin": `get '/api/v1/players', headers: { 'Origin' => 'http://localhost:3000' }`; assert `response.headers['Access-Control-Allow-Origin']` equals `'http://localhost:3000'`. "does not allow another origin": same request with `Origin: http://evil.example`; assert `response.headers['Access-Control-Allow-Origin']` is `nil`. | `spec/requests/cors_spec.rb` |
| C7 | No automated test. `frontend/package.json:5` already has `"proxy": "http://0.0.0.0:3001"`, and this fix does not touch the file. Manual check: confirm the line is still there after this fix (`grep proxy frontend/package.json`). | Manual check only |

Manual check for the production boot failure (C3), in addition to the unit test, since a full production boot is slow and this repo runs no such check in CI:

```sh
cd backend
RAILS_ENV=production SECRET_KEY_BASE=dummy rbenv exec bundle exec rails runner "puts 'unexpected: booted without CORS_ORIGINS'"
```

Expect the process to exit with `CorsOrigins::MissingOriginsError` and the message above, not the `puts` line. If it fails for an unrelated reason (for example a missing master key), that failure is a pre-existing gap in this repo's production boot, not part of this fix; the unit test in `spec/lib/cors_origins_spec.rb` is the test of record for C3.

## Existing tests that must change

None. No existing spec sends a request with an `Origin` header or reads a CORS header. `backend/spec/requests/players_update_spec.rb` and `backend/spec/requests/player_results_spec.rb` keep passing unchanged, because CORS headers are additive; they do not block a same-process RSpec request.

## Commands

Backend, in `backend/`:

```sh
rbenv exec bundle exec rspec
```

Frontend, in `frontend/`:

```sh
CI=true npm test
```

No frontend code changes are planned, so this command should already pass. Run it to confirm. The "Network Error" log from the Scoreboard mount on mount is noise (CLAUDE.md, "Front-end test gotchas"). It does not fail a test.

## Files to stage

Stage these files for the Fix step commit:
- `sdd/TODO.md`
- `backend/app/lib/cors_origins.rb`
- `backend/config/initializers/cors.rb`
- `backend/spec/lib/cors_origins_spec.rb`
- `backend/spec/requests/cors_spec.rb`
- `README.md`
- `docker-compose.yml`
- `plans/e6-s7-restrict-cors-and-protect-write-endpoints.md`

Do not stage `backend/db/development.sqlite3`, `backend/db/test.sqlite3`, `backend/log/`, `.idea/`, `backend/.idea/`, `frontend/.idea/` or `TicTacToe-ProductRequirements.pdf`.

## Out of scope

- Protection of `PUT` and `DELETE` on `/api/v1/players/:id`. `sdd/32-e6-s7-restrict-cors-and-protect-write-endpoints.md` defers this to `sdd/enhancements.md`, item 1.
- `sdd/17-e4-s4-update-a-player-s-stats.md` and `sdd/18-e4-s5-delete-a-player.md`. Step 3 did not rewrite either spec.
- `frontend/package.json:5` (the dev-server proxy). C7 already holds; this fix does not change it.
- The actual Heroku config var. Setting `CORS_ORIGINS` on the live app is an operator action outside this repo. README documents the value to use; it does not set it.

## Verification

- `rbenv exec bundle exec rspec` passes in `backend/`.
- `CI=true npm test` passes in `frontend/`.
- The new tests in `spec/lib/cors_origins_spec.rb` and `spec/requests/cors_spec.rb` fail on the current code (`origins '*'`, no `CorsOrigins` class) and pass after the fix.
- Each criterion C1 to C7 has a test or a stated manual check in the table above.
