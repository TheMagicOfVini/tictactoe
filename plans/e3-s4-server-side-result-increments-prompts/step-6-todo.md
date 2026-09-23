You work in /Users/tmov/repos/cryoport/tictactoe on branch `fix/e3-s4-server-side-result-increments`. Read /Users/tmov/repos/cryoport/tictactoe/CLAUDE.md first. It defines a 7-step "Fix a TODO item" process. You do ONLY step 6 (TODO). Edit only `sdd/TODO.md`. Do not commit or change branches.

Earlier steps are done. Read these files first:
- `plans/e3-s4-server-side-result-increments-check.md` (step 1 findings: the gaps not in the TODO, and the "Follow-up specs" section).
- `sdd/13-e3-s4-link-game-outcome-to-scoreboard.md` (criteria C1 to C13).
- `plans/e3-s4-server-side-result-increments.md` (the plan).
- `git log -p master..HEAD -- backend frontend` (the fix).
- `git log -p -- sdd/TODO.md` (how earlier fixes edited the TODO; match that style).

Do step 6:
- Check off the E3-S4 item about two results for a known player (E6-S5).
- Check off E6-S5 and its three criteria. Make sure the criteria text matches what the fix did (for example, the endpoint is `POST /api/v1/players/results` with the name in the body). Correct it if not.
- Correct the story references where they are wrong.
- Under E3-S4, add the gaps from the check file that the TODO did not list and that this fix closes, each checked off and linked to E6-S5.
- Add each spec in the "Follow-up specs" section of the check file as an unchecked item, under a heading that fits the TODO structure, so the stale specs are tracked.

Completion criterion: each item that this fix closes is checked, and each follow-up spec is an unchecked item. Write in ASD-STE100 style: short sentences, active voice, simple words. Never use emdashes. Return the diff summary.
