# Record each result exactly once (E3-S4, E6-S2)

## Context
The check of TODO item E3-S4 found that `Board.render()` sends the score updates (`frontend/src/components/Game.js:145-158`). Each render of a finished board sends the results again. For example, a names submit after the game ends calls `setState` (`Game.js:94`, `Game.js:100`), and the board sends both results a second time.

The check also found two gaps that E6-S2 covers but the TODO does not list:
- `createPlayer` adds the row only after the POST returns (`Scoreboard.js:43-50`). A second result for the same new player before that finds no id (`Scoreboard.js:54-57`), sends a second POST and makes a duplicate row.
- No test checks that a render after the game ends sends no request, and no test checks the win results. The only result test is for a draw (`Game.test.js:190-221`).

The TODO item says only "(see E6-S2)" and does not link to the story file.

## Steps
1. Save this plan as `plans/e3-s4-record-each-result-exactly-once.md`.
2. Spec: edit `sdd/13-e3-s4-link-game-outcome-to-scoreboard.md`. Keep the title, the epic lines and the user story. Replace the acceptance criteria with:

   ```
   **Acceptance criteria**

   - On an O win: Player One +1 win, Player Two +1 loss. On an X win: the reverse.
   - On a draw: both players +1 draw.
   - The board sends the results once, from the move handler, at the move that ends the game. `render()` sends no request.
   - After the game ends, more renders send no request. Examples: a submit of the same names, a submit of names that are not valid, a click on a square.
   - If a second result for a new player arrives before the POST for that player returns, the Scoreboard waits for that POST. It then PUTs the second result to the new id. The table has one row for the player.
   ```

3. Branch: create `fix/e3-s4-record-each-result-exactly-once` from `master`.
4. Fix in `Game.js`:
   - Add `recordResult(squares)` to `Board`. It finds the winner or a full board and calls `this.scoreboard.current.updatePlayer(...)` for both players, as the code in `render()` does now.
   - `handleClick` calls `recordResult` with the new squares after the move.
   - `render()` only sets the status text. Remove the `updatePlayer` calls from it.
5. Fix in `Scoreboard.js`:
   - Keep a map of the POSTs in flight, by name.
   - `createPlayer` returns the POST promise. `updatePlayer` stores it in the map and removes it when the POST settles, after the new row is in state.
   - If `updatePlayer` finds a POST in flight for the name, it waits for that POST and then calls itself again. The second call finds the new id and sends a PUT.
6. Tests:
   - `Game.test.js`: mock `Math.random` so that O moves first, then X moves first. Play a win for the first mover. Check that the winner gets +1 win and the loser +1 loss, for an O win and for an X win.
   - `Game.test.js`: after a win, submit the same names, submit names that are not valid, and click an empty square. Check that the number of POST and PUT calls does not change.
   - `Scoreboard.test.js`: `get` resolves to no players. `post` returns a promise that the test resolves later. Call `updatePlayer("Ann", "win")` two times. Check one POST. Resolve the POST with id 5. Check one PUT to `/api/v1/players/5` with 2 wins, and one row for Ann.
   - Run `CI=true npm test` in `frontend/`.
7. TODO: in `sdd/TODO.md`, check off the E3-S4 item and link it to the E6-S2 file. Add and check off the unlisted gaps: the duplicate row for a new player, and the missing tests. Add an unchecked item for the lost update of a known player (two PUTs from the same counters), linked to E6-S5. Check off E6-S2 and its three criteria.
8. Commit: stage only the spec, `sdd/TODO.md`, `Game.js`, `Scoreboard.js`, `Game.test.js`, `Scoreboard.test.js` and this plan.

## Out of scope
- Lost update for a known player: two results before the first PUT returns send the same counters (`Scoreboard.js:59-64`). E6-S5 fixes it with server-side increments.
- Unique names in the database (E6-S5).
- The PUT response is `null` (E6-S4).
- A full rewrite of the Scoreboard test (E6-S8).

## Verification
- `CI=true npm test` passes in `frontend/`.
- The new tests fail on the `master` code and pass after the fix.
- Each criterion in the new spec has a test.
