You work in /Users/tmov/repos/cryoport/tictactoe on branch `fix/e3-s4-server-side-result-increments`. Read /Users/tmov/repos/cryoport/tictactoe/CLAUDE.md first. It defines a 7-step "Fix a TODO item" process. You do ONLY step 2 (Spec). Do not edit code, tests, or `sdd/TODO.md`. Do not commit or change branches.

Step 1 is done. Its findings are in `plans/e3-s4-server-side-result-increments-check.md`. Read that file first. The TODO item is the unchecked one under E3-S4 in `sdd/TODO.md`: "two results for a known player before the first PUT returns send the same counters, so one result is lost". Its E6 story is `sdd/30-e6-s5-server-side-result-increments.md`.

Do step 2: rewrite the acceptance criteria of `sdd/13-e3-s4-link-game-outcome-to-scoreboard.md` so they state the target behavior from E6-S5. Keep the title, the epic lines and the user story. Keep the existing criteria that still hold (for example, each result is recorded exactly once, a re-render sends no request), and replace the ones that describe the old POST-then-PUT flow. Look at git history (`git log -p -- sdd/13-e3-s4-link-game-outcome-to-scoreboard.md`) to match the style of earlier spec rewrites.

Settle the design points that the check file lists, and state them as testable criteria. Use these decisions:
- One endpoint records a result: `POST /api/v1/players/results` with body `{ name, result }`, where `result` is `win`, `loss` or `draw`. Put the name in the body, not in the path, so names with spaces, `/` or `.` work.
- The server finds or creates the player by name and increments the matching counter with one atomic SQL update. It returns the saved player.
- An invalid `result` or a blank name returns 422.
- The client sends only the name and the result. It never sends counter values. It never chooses between POST and PUT.
- Player names are unique: a DB unique index and a model uniqueness validation. Two concurrent requests for a new name make one row (rescue `RecordNotUnique` and retry the lookup).
- Name matching stays case-sensitive on the server (the E6-S6 form check is a separate concern). State this explicitly.
- Two results for the same player sent before the first response returns both count.

Completion criterion: each TODO gap and each gap from the check file that this fix closes is a violation of exactly one criterion. Other specs that E6-S5 makes stale (E3-S2, E3-S3, E4-S1, E4-S3, E4-S4, E5-S4) are out of scope for this step; list them at the end of the check file under a new "Follow-up specs" heading with one line each.

Write the criteria in ASD-STE100 style: short sentences, active voice, simple words. Never use emdashes. Return the new criteria list.
