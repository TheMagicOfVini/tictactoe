You work in /Users/tmov/repos/cryoport/tictactoe on branch `fix/e3-s4-server-side-result-increments`. Read /Users/tmov/repos/cryoport/tictactoe/CLAUDE.md first. It defines a 7-step "Fix a TODO item" process. You do ONLY step 5 (Fix). Do not edit `sdd/TODO.md` or the story spec. Do not commit or change branches.

Earlier steps are done. Read these files first:
- `plans/e3-s4-server-side-result-increments.md` (the plan; follow it).
- `sdd/13-e3-s4-link-game-outcome-to-scoreboard.md` (acceptance criteria C1 to C13).
- `plans/e3-s4-server-side-result-increments-check.md` (test environment notes).

Do step 5: change the code to meet criteria C1 to C13, as the plan describes. Add one test or more for each criterion. If the plan is wrong in a detail, fix the detail and note the change in your report. Do not widen the scope beyond the plan.

Rules:
- Before you run any migration, copy `backend/db/development.sqlite3` to `/private/tmp/claude-501/-Users-tmov-repos-cryoport-tictactoe/1725aed1-16bb-454e-a69c-62b046caafff/scratchpad/development.sqlite3.bak`.
- Backend commands run with rbenv: `rbenv exec bundle exec rails db:migrate`, `rbenv exec bundle exec rails db:migrate RAILS_ENV=test`, `rbenv exec bundle exec rspec` in `backend/`.
- Frontend: `CI=true npm test` in `frontend/`. Read the "Front-end test gotchas" in CLAUDE.md.
- Never use emdashes in code comments or text.

Completion criterion: every criterion C1 to C13 has a test, `rbenv exec bundle exec rspec` in `backend/` passes, and `CI=true npm test` in `frontend/` passes. Report: the files you changed, a table of criterion to test name and file, the final output lines of both test runs, and any deviation from the plan.
