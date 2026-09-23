You work in /Users/tmov/repos/cryoport/tictactoe on branch `fix/e3-s4-server-side-result-increments`. Read /Users/tmov/repos/cryoport/tictactoe/CLAUDE.md first, including the "Front-end test gotchas". This is a follow-up to the E3-S4 / E6-S5 fix, which is already committed. Add tests only. Do not change application code, specs or `sdd/TODO.md`. Do not commit or change branches.

Two spec criteria have no test. Add one test for each:

1. `sdd/17-e4-s4-update-a-player-s-stats.md`: a PUT to `/api/v1/players/:id` that sets the name of another player returns 422 with `name: ["has already been taken"]`, and the player does not change. Add it to `backend/spec/requests/players_update_spec.rb`. Match the style of that file and use `RequestSpecHelper#json`.
2. `sdd/11-e3-s2-record-a-result-for-a-new-player.md`: when `POST /api/v1/players/results` fails (for example a 422), the client logs the error, does not change the table and shows no alert. Add it to `frontend/src/tests/Scoreboard.test.js`. Reuse the existing axios mock and the `flushPromises` helper. Make the `post` mock reject once, then assert the rows did not change and `window.alert` was not called (spy on it). Spy on `console.error` or `console.log` (whichever `Scoreboard.js` uses in its `catch`) so the test also checks the log and keeps the output clean.

For each test, prove it can fail: break the behavior on purpose for one run (for example remove the model validation, or call `savePlayer` in the `catch`), confirm the test fails, then restore the file exactly (`git diff` must show only the test files).

Completion criterion: both tests exist, `rbenv exec bundle exec rspec` in `backend/` passes, `CI=true npm test` in `frontend/` passes, and `git status` shows changes only in the two test files (ignore `backend/db/*.sqlite3`, `backend/log/`, `.idea/` and the PDF). Never use emdashes. Return the test names, the proof that each one failed when broken, and the final result lines of both suites.
