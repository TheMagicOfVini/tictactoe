# Fix the crash on a draw (E2-S5, E6-S1)

## Context
The check of TODO item E2-S5 found that the draw branch in `frontend/src/components/Game.js:157-158` calls `this.child.scoreboard.updatePlayer(...)`. `this.child` is not defined, so a full board with no winner throws a TypeError. The win branches (`Game.js:147-152`) use the ref `this.scoreboard.current`. No test covers a draw. The E2-S5 spec covers only the status text, so it does not require that a draw is recorded.

## Steps
1. Save this plan as `plans/e2-s5-fix-crash-on-draw.md`.
2. Spec: edit `sdd/08-e2-s5-detect-a-draw.md`. Keep the title, the epic lines and the user story. Replace the acceptance criteria with:

   ```
   **Acceptance criteria**

   - When no square is null and there is no winner, the status reads "The game is a draw!".
   - When the game ends in a draw, each player receives exactly one +1 draw on the scoreboard, through the same scoreboard ref that the win branches use (`this.scoreboard.current.updatePlayer(name, "draw")`).
   - A draw does not throw an error.
   ```

3. Branch: create `fix/e2-s5-fix-crash-on-draw` from `master`.
4. Fix: in `Game.js`, change the two draw calls to `this.scoreboard.current.updatePlayer(...)`.
5. Tests: in `frontend/src/tests/Game.test.js`:
   - Mock `axios`. `get` resolves to `{ data: [] }` and `post` resolves to the posted player.
   - Add a helper that plays the squares in the order 0, 1, 2, 4, 3, 5, 7, 6, 8. The first mover gets {0, 2, 3, 7, 8} and the second mover gets {1, 4, 5, 6}. Neither set has a line, so the game ends in a draw no matter who moves first.
   - Test 1: the full board does not throw, and the status reads "The game is a draw!".
   - Test 2: `axios.post` runs exactly once for each player, with `wins: 0, losses: 0, draws: 1`.
   - Run `CI=true npm test` in `frontend/`.
6. TODO: in `sdd/TODO.md`, check off the E2-S5 item and add a link to the E6-S1 file. Check off E6-S1 and its two criteria. Add and check off the missing draw test gap under E2-S5.
7. Commit: stage only the spec, `sdd/TODO.md`, `Game.js`, `Game.test.js` and this plan.

## Out of scope
- Moving the score updates out of `render()` (E6-S2).
- The lookup by list position in `playerIndex` (E6-S3).
- A shared axios mock for all test files (E6-S8).

## Verification
- `CI=true npm test` passes in `frontend/`.
- The new tests fail on `master` code and pass after the fix.
- Each criterion in the new spec has a test.
