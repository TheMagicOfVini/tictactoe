# Tic Tac Toe

The specs live in `sdd/`. `sdd/00-overview.md` maps each epic to its code. `sdd/TODO.md` lists the gaps between the specs and the code. Each gap names the E6 story that fixes it.

## Fix a TODO item

Do the steps in order. Each step ends on its completion criterion.

1. **Check.** Read the first unchecked item in `sdd/TODO.md`, its story spec, its E6 story and the code. Done when every listed gap is confirmed or refuted with a `file:line`, and every gap that the E6 story covers but the TODO does not list is noted. Also note an item with no E6 story reference, or with only an epic reference such as "(see E6)".
2. **Plan.** Save the plan to `plans/<story-id>-<slug>.md`, for example `plans/e1-s2-spec-update.md`. Done when the file exists.
3. **Spec.** Rewrite the acceptance criteria of the story spec so they state the target behavior from the E6 story. Keep the title, the epic lines and the user story. Done when each TODO gap is a violation of one criterion.
4. **Branch.** Create `fix/<story-id>-<slug>` from `master`.
5. **Fix.** Change the code to meet the new criteria. Add one test or more for each new criterion. Done when every criterion has a test and `CI=true npm test` in `frontend/` passes.
6. **TODO.** Check off the story's items and the E6 story with its criteria. Correct the story references. Add the gaps from step 1 that the TODO did not list, and check them off. Done when each item that this fix closes is checked.
7. **Commit.** Stage only the files of this fix: the spec, `sdd/TODO.md`, the code, the tests and the plan. The working tree has unrelated changes (`backend/db/*.sqlite3`, `backend/log/`, `.idea/`); leave them out.

## Front-end test gotchas

- The jsdom version in the tests does not support named access to form fields (`form.player_one`). Use `form.elements.namedItem("player_one")` in code and in tests.
- The "Set Names" popup stays open after a submit. A second click on its trigger closes it. Open it only if no `form` is in the document.
- The Scoreboard sends an axios request when it mounts. In the tests the request fails and logs "Network Error". This noise does not fail a test. E6-S8 adds the axios mock.
