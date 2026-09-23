# Look up players by real id (E3-S3, E6-S3)

## Context
The check of TODO item E3-S3 found that `playerIndex` in `frontend/src/components/Scoreboard.js:94-98` returns the list position plus 1, not the player's database id. `updatePlayer` sends the PUT to that fake id (`Scoreboard.js:75`) and reads and writes the row at `players[id - 1]` (`Scoreboard.js:60`, `Scoreboard.js:83`). The backend `index` (`players_controller.rb:7`) does not order the players, so the position can be wrong even when the ids have no gaps. With gaps, the wrong player gets the result, and the row write can land in the wrong slot or append a stray row. No test covers a result for a returning player.

## Steps
1. Save this plan as `plans/e3-s3-look-up-players-by-real-id.md`.
2. Spec: edit `sdd/12-e3-s3-record-a-result-for-a-returning-player.md`. Keep the title, the epic lines and the user story. Replace the acceptance criteria with:

   ```
   **Acceptance criteria**

   - `playerIndex` returns the `id` of the loaded player object whose name matches, or `null` when no player matches. It does not use the position in the list.
   - If the name exists, `updatePlayer` takes the current counters from that player object, increments the counter that matches the result, and PUTs `/api/v1/players/:id` with that player's `id`.
   - On success only the row of that player updates, in place. The other rows and the number of rows do not change.
   - The above holds when the ids have gaps (for example after a delete) or when the list is not sorted by id.
   ```

3. Branch: create `fix/e3-s3-look-up-players-by-real-id` from `master`.
4. Fix in `Scoreboard.js`:
   - `playerIndex(name)`: find the matching player and return its `id`, or `null`.
   - `updatePlayer(name, result)`: find the row index with `findIndex(p => p.id === id)`. Read the counters from that row. After the PUT succeeds, replace the row at that index.
5. Tests in `frontend/src/tests/Scoreboard.test.js`:
   - Mock `axios`. `get` resolves to players with ids 7, 3 and 12, in that order. `put` resolves.
   - Render `<Scoreboard ref={ref} />` and wait until the rows show.
   - Test `playerIndex`: it returns 3 for the second player and `null` for an unknown name.
   - Test the PUT: `updatePlayer("Steve", "win")` PUTs `/api/v1/players/3` with that player's counters plus one win.
   - Test the row: after the PUT, only the Steve row shows the new wins, the other rows keep their values, and the table still has 3 rows.
   - Keep the existing render test. E6-S8 owns the rewrite of that test.
   - Run `CI=true npm test` in `frontend/`.
6. TODO: in `sdd/TODO.md`, check off the E3-S3 item and link it to the E6-S3 file. Add and check off the unlisted gaps: the `players[id - 1]` row access, and the missing test. Check off E6-S3 and its two criteria.
7. Commit: stage only the spec, `sdd/TODO.md`, `Scoreboard.js`, `Scoreboard.test.js` and this plan.

## Out of scope
- The PUT response is `null` (E6-S4). The client does not read it.
- Case-sensitive lookup and non-unique names (E6-S5).
- Results recorded more than once (E6-S2).
- A full rewrite of the Scoreboard test (E6-S8).

## Verification
- `CI=true npm test` passes in `frontend/`.
- The new tests fail on the `master` code and pass after the fix.
- Each criterion in the new spec has a test.
