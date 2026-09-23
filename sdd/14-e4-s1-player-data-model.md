# E4-S1 Player data model

**Epic:** E4: Player Stats REST API (Back End)

**Epic goal:** a small JSON API stores players and their results.

As a developer, I want a Player record with name and result counters, so that stats can be persisted.

**Acceptance criteria**

- `players` table: `name` (string), `wins`, `losses`, `draws` (integers, default 0), timestamps.
- `name` is required (`validates_presence_of :name`).
