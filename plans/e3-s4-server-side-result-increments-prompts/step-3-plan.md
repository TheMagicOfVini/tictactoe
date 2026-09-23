You work in /Users/tmov/repos/cryoport/tictactoe on branch `fix/e3-s4-server-side-result-increments`. Read /Users/tmov/repos/cryoport/tictactoe/CLAUDE.md first. It defines a 7-step "Fix a TODO item" process. You do ONLY step 3 (Plan). Do not edit code, tests, specs or `sdd/TODO.md`. Do not commit or change branches.

Steps 1 and 2 are done. Read these files first:
- `plans/e3-s4-server-side-result-increments-check.md` (step 1 findings, test environment notes, follow-up specs).
- `sdd/13-e3-s4-link-game-outcome-to-scoreboard.md` (the new acceptance criteria C1 to C13 from step 2).
- `sdd/30-e6-s5-server-side-result-increments.md` (the E6 story).
- An earlier plan for format and depth, for example `plans/e3-s4-record-each-result-exactly-once.md` and `plans/e4-s4-return-the-updated-player-from-put.md`.

Do step 3: base the plan on criteria C1 to C13. Read the code you plan to change (backend controller, model, routes, schema, migrations, seeds, factories, request specs; frontend `Scoreboard.js`, `Game.js` and their tests) so the plan names real files and lines. For each change, name the file and what changes. For each criterion, name the test (RSpec request or model spec, or React test) that proves it, and the file it goes in. List the existing tests that assert absolute counter bodies and must change. Include the exact commands to run the tests (backend: `rbenv exec bundle exec rspec` in `backend/`, after the migration runs for the development and test databases; frontend: `CI=true npm test` in `frontend/`). Note that `backend/db/*.sqlite3` must not be staged, but `backend/db/schema.rb` and the new migration must be.

Save the plan to `plans/e3-s4-server-side-result-increments.md`. Completion criterion: the file exists and every criterion C1 to C13 maps to at least one test. Write in ASD-STE100 style: short sentences, active voice, simple words. Never use emdashes. Return a brief summary of the plan.
