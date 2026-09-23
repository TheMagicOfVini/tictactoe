# E4-S1 Player data model

**Epic:** E4: Player Stats REST API (Back End)

**Epic goal:** a small JSON API stores players and their results.

As a developer, I want a Player record with name and result counters, so that stats can be persisted.

**Acceptance criteria**

- `players` table: `name` (string), `wins`, `losses`, `draws` (integers, default 0), timestamps.
- The `players` table has a unique index on `name` (`index_players_on_name`). The database rejects a second row with the same name.
- `name` is required and unique: `validates :name, presence: true, uniqueness: { case_sensitive: true }`. A second player with the same name is not valid.
- The name match is case-sensitive. `Alice` and `alice` are two players, and both are valid.
