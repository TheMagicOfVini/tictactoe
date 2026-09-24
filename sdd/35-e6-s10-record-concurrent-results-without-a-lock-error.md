# E6-S10 Record concurrent results without a lock error

**Epic:** E6: Hardening & Defect Fixes

**Epic goal:** close the gaps found while mapping the code. Each story is a proposed change, not existing behaviour.

As a player, I want both results of a finished game saved, so that the winner and the loser both appear on the scoreboard.

**Acceptance criteria**

- Two `POST /api/v1/players/results` requests for two new names, sent at the same time, both return 200. Both players exist after the requests. Each has 1 in the matching counter.
- Two requests for the same new name, sent at the same time, both return 200. One player exists after the requests. The counters add up to 2 results.
- One request for a new name and one for a known name, sent at the same time, both return 200. The known player gets 1 more in the matching counter.
- No request waits for the busy timeout in these cases. Each request completes in less than 1 second.
- The server writes one result at a time in each process. The `results` action holds a lock (`RESULTS_LOCK`) around the find-or-create and the counter increment.
- The client does not change. `Board` still sends the two results of a game at the same time.
- The `Player` model keeps `validates :name, presence: true, uniqueness: { case_sensitive: true }`, and the `players` table keeps the unique index on `name` (E4-S1).
- A request spec sends two results concurrently from two threads and asserts the criteria above.

**Background**

Found while running the app on 2026-09-23 (was EN-1 in `enhancements.md`). Two concurrent `curl` requests for two new names both returned 500 after about 5.3 s. One request on its own returned 200 in less than 10 ms. The Rails log showed `SQLite3::BusyException: database is locked`. One request failed on the `INSERT`, the other on `commit transaction`.

**Root cause**

1. `Player.find_or_create_by!` opens a transaction. The uniqueness validation runs a `SELECT` in it, so each connection holds a SHARED lock. Then each `INSERT` needs the RESERVED lock.
2. SQLite does not wait on a lock upgrade that can deadlock. The second `INSERT` fails at once with `SQLITE_BUSY`.
3. The first request then needs the EXCLUSIVE lock to commit. It waits on the busy handler (`timeout: 5000`). In Rails 5.2 with `sqlite3` 1.4, this wait runs in C and holds the Ruby global VM lock. The failed request cannot run its `ROLLBACK`, so it keeps its SHARED lock, and the commit waits the full 5 seconds. Both requests then fail.
4. The `rescue` in `find_or_create_player` catches `RecordNotUnique` and `RecordInvalid`, not `StatementInvalid`.

Removing the uniqueness validation does not fix this. The waiting `INSERT` still holds the global VM lock, so the transaction that holds RESERVED cannot commit. The request spec confirmed this.

**Limits**

The lock is per process. `config/puma.rb` runs one process with threads, so the lock covers every request. Puma workers (more than one process) would need a database-level lock.
