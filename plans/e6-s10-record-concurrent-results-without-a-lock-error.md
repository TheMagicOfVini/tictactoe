# Record concurrent results without a lock error (E6-S10)

## Context

EN-1 in `sdd/enhancements.md` reported that two results sent at the same time both fail with `SQLite3::BusyException` after 5 seconds. This story moves EN-1 into `sdd/35-e6-s10-record-concurrent-results-without-a-lock-error.md`. Step 3 put the target behavior in `sdd/13-e3-s4-link-game-outcome-to-scoreboard.md`, the story where the gaps are listed. This plan numbers its criteria.

- R1: two new names at the same time: both 200, both players saved, 1 in each matching counter.
- R2: the same new name twice at the same time: both 200, one player, 2 results.
- R3: a new name and a known name at the same time: both 200.
- R4: each request completes in less than 1 second.
- R5: the server writes one result at a time in each process.
- R6: the client does not change.
- R7: the model keeps the uniqueness validation and the table keeps the unique index.
- R8: a request spec sends the results from two threads.

## Design decisions

### Serialize on the server, keep the validation

EN-1 recommended removing the uniqueness validation. The product owner rejected this because it goes against E4-S1. A test also showed that it does not work: the busy wait holds the Ruby global VM lock, so the other transaction cannot commit.

The fix puts a class-level `Mutex` (`RESULTS_LOCK`) around the find-or-create and the counter increment in `Api::V1::PlayersController#results`. Only one result write runs at a time, so no two transactions hold SQLite locks at once. The busy handler never runs. The mutex covers two tabs and two browsers, because Puma runs one process.

### No client change

The product owner chose a fix on the server only. `Board.recordResult` still sends both requests at once.

### How the spec makes the threads interleave

Ruby switches threads only on IO or every 100 ms. A request takes a few ms, so without help one request ends before the other starts. The spec subscribes to `sql.active_record` and sleeps 20 ms after each statement. The other thread then runs between the statements of a transaction, as a Puma thread does when it waits on a socket.

The spec also:

- turns off transactional tests, because each thread needs its own connection, and deletes the players after each example;
- eager-loads the app, because two threads that autoload the same controller fail;
- sends each request through `Rack::MockRequest`, because the integration session is not thread-safe;
- repeats each case 5 times.

## Steps

1. Write `backend/spec/requests/player_results_concurrency_spec.rb` for R1 to R4 and R8. Done when it fails on the current code with `BusyException`.
2. Add `RESULTS_LOCK` to the `results` action (R5). Done when the new spec and `player_results_spec.rb` pass.
3. Keep `app/models/player.rb` and the client code unchanged (R6, R7). The model specs for the validation and the index cover R7. Done when `rspec` and `CI=true npm test` pass.
4. Update `sdd/TODO.md`, `sdd/00-overview.md` and `sdd/enhancements.md`. Done when E6-S10 is checked off and EN-1 points to it.
