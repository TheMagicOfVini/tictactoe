# Enhancements

Proposed changes found while running the app. Each item is a proposed change, not existing behaviour. Move an item to a numbered story spec when it is scheduled.

## EN-1 Record two results at the same time without a database lock error

Scheduled as [E6-S10 Record concurrent results without a lock error](35-e6-s10-record-concurrent-results-without-a-lock-error.md). The story has the observed behaviour, the corrected root cause and the acceptance criteria.

The fix differs from the first proposal. The server writes one result at a time, and the `Player` model keeps its uniqueness validation. Removing the validation did not fix the error, because the SQLite busy wait blocks every Ruby thread in the process.
