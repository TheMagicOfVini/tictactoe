You work in /Users/tmov/repos/cryoport/tictactoe on branch `fix/e6-s7-restrict-cors-and-protect-write-endpoints`. Read /Users/tmov/repos/cryoport/tictactoe/CLAUDE.md first. It defines a 7-step "Fix a TODO item" process. You do ONLY step 5 (Fix). Do not edit `sdd/TODO.md` or any spec in `sdd/`. Do not commit or change branches.

Earlier steps are done. Read these files first:
- `plans/e6-s7-restrict-cors-and-protect-write-endpoints.md` (the plan; follow it).
- `sdd/19-e4-s6-allow-cross-origin-requests.md` (the acceptance criteria).
- `plans/e6-s7-restrict-cors-and-protect-write-endpoints-check.md` (test environment notes).

Do step 5: change the code to meet the E4-S6 criteria, as the plan describes. Add one test or more for each criterion. If the plan is wrong in a detail, fix the detail and note the change in your report. Do not widen the scope beyond the plan. The PUT and DELETE protection is out of scope.

One point to check: the app runs Rails 5.2.6 with the classic autoloader. The plan puts `CorsOrigins` in `backend/app/lib/` and calls it from an initializer. An initializer that uses an autoloaded constant can break on code reload in development, and Rails warns against it. Prefer a file in `backend/lib/` that the initializer loads with an explicit `require`, unless you find a reason in this codebase not to. Make sure the spec can load the class too.

Rules:
- Backend commands run with rbenv: `rbenv exec bundle exec rspec` in `backend/`.
- To prove the production boot check, also run one manual boot, for example `RAILS_ENV=production SECRET_KEY_BASE=x rbenv exec bundle exec rails runner 'puts 1'` in `backend/` without `CORS_ORIGINS` (it must fail with the message from the plan), and again with `CORS_ORIGINS=https://example.com` (it must not fail on CORS). If the second boot fails for a reason that is not CORS (for example a missing production database), report the reason and do not fix it.
- Frontend: `CI=true npm test` in `frontend/`. Read the "Front-end test gotchas" in CLAUDE.md.
- Never use emdashes in code comments or text.

Completion criterion: every E4-S6 criterion has a test (or the manual check that the plan names), `rbenv exec bundle exec rspec` in `backend/` passes, and `CI=true npm test` in `frontend/` passes. Report: the files you changed, a table of criterion to test name and file, the final output lines of both test runs, the output of the manual boot checks, and any deviation from the plan.
