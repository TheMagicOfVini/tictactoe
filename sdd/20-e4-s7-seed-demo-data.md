# E4-S7 Seed demo data

**Epic:** E4: Player Stats REST API (Back End)

**Epic goal:** a small JSON API stores players and their results.

As a developer, I want sample players loaded on setup, so that the scoreboard isn't empty in development.

**Acceptance criteria**

- `rake db:setup` runs `db/seeds.rb`, creating five sample players with preset records.
