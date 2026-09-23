You work in /Users/tmov/repos/cryoport/tictactoe on branch `fix/e3-s4-server-side-result-increments`. Read /Users/tmov/repos/cryoport/tictactoe/CLAUDE.md first. This is a follow-up to the 7-step "Fix a TODO item" process for E3-S4 / E6-S5, which is already done and committed. Edit only files in `sdd/`. Do not change code or tests. Do not commit or change branches.

Goal: bring the specs in `sdd/` in line with the code that this branch committed. The code is the truth. Read it first: `git diff master...HEAD -- backend frontend`, plus `plans/e3-s4-server-side-result-increments.md` and the new E3-S4 criteria in `sdd/13-e3-s4-link-game-outcome-to-scoreboard.md`.

Update these specs. For each one, change only the acceptance criteria (and the descriptive text, if it states the old behavior). Keep the title, the epic lines and the user story. Match the style of the earlier spec rewrites (`git log -p -- sdd/` shows them).
- `sdd/11-e3-s2-record-a-result-for-a-new-player.md`: the client sends `POST /api/v1/players/results` with `{ name, result }`; the server creates the player with 1 in the matching counter.
- `sdd/12-e3-s3-record-a-result-for-a-returning-player.md`: the server adds 1 atomically; the client sends the same request; no PUT.
- `sdd/14-e4-s1-player-data-model.md`: unique index on `name`, model uniqueness validation, case-sensitive match.
- `sdd/16-e4-s3-create-a-player.md`: a POST with a known name returns 422.
- `sdd/17-e4-s4-update-a-player-s-stats.md`: a PUT that sets the name of another player returns 422. PUT still accepts absolute counters; E6-S7 covers the protection of this endpoint. Do not claim more.
- `sdd/20-e4-s7-seed-demo-data.md`: a second `db:seed` makes no duplicate player.
- `sdd/24-e5-s4-back-end-model-tests.md`: a test covers the uniqueness of `name`.
- `sdd/30-e6-s5-server-side-result-increments.md`: replace the example endpoint `POST /api/v1/players/:name/results` with `POST /api/v1/players/results` and the body `{ name, result }`.
- `sdd/00-overview.md`: if its code map lists endpoints, routes, the migration or the model rules, add the new endpoint and migration. If not, leave it.

Verify each new criterion against the code with a `file:line` (for example, check that the E4-S3 422 actually happens: the model validation makes `create` fail). If the code does not meet a criterion you planned to write, do not write it; report it.

Then in `sdd/TODO.md`, check off the 7 follow-up spec items that this closes (they point to E6-S5). Do not change other items.

Write in ASD-STE100 style: short sentences, active voice, simple words. Never use emdashes. Return: for each file, the changed criteria and the `file:line` evidence, and any criterion you could not write because the code does not support it.
