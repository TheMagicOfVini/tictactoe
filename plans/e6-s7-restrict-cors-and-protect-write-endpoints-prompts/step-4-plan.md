You work in /Users/tmov/repos/cryoport/tictactoe on branch `fix/e6-s7-restrict-cors-and-protect-write-endpoints`. Read /Users/tmov/repos/cryoport/tictactoe/CLAUDE.md first. It defines a 7-step "Fix a TODO item" process. You do ONLY step 4 (Plan). Do not edit code, tests, specs or `sdd/TODO.md`. Do not commit or change branches.

Steps 1 to 3 are done. Read these files first:
- `plans/e6-s7-restrict-cors-and-protect-write-endpoints-check.md` (step 2 findings and test environment notes).
- `sdd/19-e4-s6-allow-cross-origin-requests.md` (the new acceptance criteria from step 3).
- `sdd/32-e6-s7-restrict-cors-and-protect-write-endpoints.md` (the E6 story; the PUT and DELETE part is deferred to `sdd/enhancements.md` and is out of scope).
- An earlier plan for format and depth, for example `plans/e3-s4-server-side-result-increments.md`.

Do step 4: base the plan on the new E4-S6 criteria. Read the code you plan to change (`backend/config/initializers/cors.rb`, `backend/config/environments/`, `backend/config/application.rb`, `backend/spec/`, the Docker and compose files, `README.md`, and any deployment config) so the plan names real files and lines. Settle these points in the plan:
- Where the origin list is parsed, so that tests can call the parsing and the production check without a reboot of the app (for example a small module or class method that takes the env hash and the Rails env).
- How the production boot check fails (the exception class and the message).
- How a request spec proves that an allowed origin gets `Access-Control-Allow-Origin` and another origin does not. Check that the test environment uses the default origin, and that an env value set in one test does not leak into others.
- Which docs and config files must name `CORS_ORIGINS` (for example the README, `docker-compose.yml`, the deployment notes), so that a developer or a deploy does not break.

For each change, name the file and what changes. For each criterion, name the test that proves it and the file it goes in. Include the exact commands to run the tests: backend `rbenv exec bundle exec rspec` in `backend/`; frontend `CI=true npm test` in `frontend/`. Note that `backend/db/*.sqlite3` and `backend/log/` must not be staged.

Save the plan to `plans/e6-s7-restrict-cors-and-protect-write-endpoints.md`. Completion criterion: the file exists and every E4-S6 criterion maps to at least one test (or, for a criterion that no test can cover, a stated reason and a manual check). Write in ASD-STE100 style: short sentences, active voice, simple words. Never use emdashes. Return a brief summary of the plan.
