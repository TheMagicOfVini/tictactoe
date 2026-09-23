You work in /Users/tmov/repos/cryoport/tictactoe on branch `fix/e6-s7-restrict-cors-and-protect-write-endpoints`. Read /Users/tmov/repos/cryoport/tictactoe/CLAUDE.md first. It defines a 7-step "Fix a TODO item" process. You do ONLY step 3 (Spec). Do not edit code, tests or `sdd/TODO.md`. Do not commit or change branches.

Step 2 is done. Read `plans/e6-s7-restrict-cors-and-protect-write-endpoints-check.md` first. The TODO item is the E6-S7 entry in `sdd/TODO.md`. The E6 story is `sdd/32-e6-s7-restrict-cors-and-protect-write-endpoints.md`.

The user made these decisions. Follow them exactly:
- Scope: this fix covers only CORS. PUT and DELETE stay as they are for now. Do not change `sdd/17-e4-s4-update-a-player-s-stats.md` or `sdd/18-e4-s5-delete-a-player.md`.
- CORS origins come from `ENV['CORS_ORIGINS']`, a comma-separated list of origins. Trim spaces around each origin and ignore empty entries.
- In development and test, the default is `http://localhost:3000` when the variable is not set.
- In production, the variable is required. The app fails at boot with a clear error message if it is not set or is blank.
- A request from an allowed origin gets the CORS headers. A request from another origin gets no `Access-Control-Allow-Origin` header. `*` is never used as a default.

Do step 3:
1. Rewrite the acceptance criteria of `sdd/19-e4-s6-allow-cross-origin-requests.md` so they state this target behavior. Keep the title, the epic lines and the user story. Also fix any descriptive text that says "allows all origins". Look at `git log -p -- sdd/` to match the style of earlier spec rewrites (numbered criteria such as C1, C2).
2. In the E6-S7 story `sdd/32-e6-s7-restrict-cors-and-protect-write-endpoints.md`, state that the PUT and DELETE protection is deferred, and link to `enhancements.md`. Do not delete the original text of that criterion.
3. Create `sdd/enhancements.md`. Give it a short intro: it lists suggested improvements that are not yet planned as fixes. Add the first suggestion: protect `PUT /api/v1/players/:id` and `DELETE /api/v1/players/:id`, or remove them from the public API. Include the facts from the "Design choices" section of the check file (the frontend calls neither endpoint; no auth mechanism exists; the options: an admin token from an env var in a header with a secure compare that fails closed, or removal of the routes; the effect on `backend/spec/requests/players_update_spec.rb`). Link back to E6-S7, E4-S4 and E4-S5.
4. If `sdd/00-overview.md` has a list of spec files, add `enhancements.md` to it. If not, leave it.

Completion criterion: each CORS gap in the check file is a violation of exactly one criterion in the E4-S6 spec, and `sdd/enhancements.md` exists with the PUT/DELETE suggestion as its first item. Write in ASD-STE100 style: short sentences, active voice, simple words. Never use emdashes. Return the new E4-S6 criteria and a one-line summary of each other file you changed.
