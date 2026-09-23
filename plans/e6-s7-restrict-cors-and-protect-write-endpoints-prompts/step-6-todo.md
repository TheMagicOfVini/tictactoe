You work in /Users/tmov/repos/cryoport/tictactoe on branch `fix/e6-s7-restrict-cors-and-protect-write-endpoints`. Read /Users/tmov/repos/cryoport/tictactoe/CLAUDE.md first. It defines a 7-step "Fix a TODO item" process. You do ONLY step 6 (TODO). Edit only `sdd/TODO.md`. Do not commit or change branches.

Earlier steps are done. Read these files first:
- `plans/e6-s7-restrict-cors-and-protect-write-endpoints-check.md` (step 2 findings, including the gaps not in the TODO).
- `sdd/19-e4-s6-allow-cross-origin-requests.md` (the new criteria).
- `sdd/32-e6-s7-restrict-cors-and-protect-write-endpoints.md` and `sdd/enhancements.md` (the PUT and DELETE protection is deferred).
- `git log -p master..HEAD -- backend README.md docker-compose.yml` (the fix).
- `git log -p -- sdd/TODO.md` (how earlier fixes edited the TODO; match that style).

The user decided that this fix covers only CORS. The PUT and DELETE protection moves to `sdd/enhancements.md`. So E6-S7 is only partly done.

Do step 6:
- Under the E6 heading, check off the E6-S7 criterion "CORS origins come from configuration instead of `*`". Correct its text if it does not match what the fix did (origins come from `CORS_ORIGINS`; production fails at boot without it).
- Leave the E6-S7 parent item and the PUT/DELETE criterion unchecked. Add a short note to the PUT/DELETE criterion that says it is deferred, with a link to `enhancements.md`.
- Add a story section for `E4-S6 Allow cross-origin requests (19-e4-s6-allow-cross-origin-requests.md)` in the correct order among the other story sections. Under it, add each gap from the check file that this fix closes (for example: `cors.rb` allowed all origins; the spec stated all origins as the target; no env var fed the origins; no test covered CORS), each checked off and linked to E6-S7.
- Correct any story reference that is wrong. Leave the E4-S4 item that mentions E6-S7 as it is, unless its link is broken.

Completion criterion: each item that this fix closes is checked, and the deferred PUT/DELETE criterion stays unchecked with a link to `enhancements.md`. Write in ASD-STE100 style: short sentences, active voice, simple words. Never use emdashes. Return the diff of `sdd/TODO.md`.
