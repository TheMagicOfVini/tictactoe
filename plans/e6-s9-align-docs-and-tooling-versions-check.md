# E6-S9 Align docs and tooling versions: Check

Story: `sdd/34-e6-s9-align-docs-and-tooling-versions.md`.

## TODO gaps

The TODO item lists three criteria. Each one is a full gap.

- **README Ruby version matches the Gemfile/Dockerfile (2.6.1, not 2.5.3).** Confirmed.
  - `README.md:16` says "Ruby 2.5.3, Rails 5.2.1". `README.md:20-21` run `rvm install 2.5.3` and `rvm use ruby-2.5.3`.
  - `backend/Gemfile:4` pins `ruby '2.6.1'`. `backend/.ruby-version:1` is `2.6.1`. `backend/Gemfile.lock` records `ruby 2.6.1p33`. `Dockerfile:1` is `FROM ruby:2.6.1-slim`.
  - `backend/Gemfile:7` pins `rails '~> 5.2.1'`, so the Rails version in the README is correct.
  - `sdd/22-e5-s2-run-in-docker.md` already says 2.6.1. `sdd/21-e5-s1-run-locally-without-docker.md` names no version.
- **README clone URL points at this repository.** Confirmed.
  - `README.md:62` clones `https://github.com/MiloTodt/tictactoe.git`. The origin remote is `https://github.com/jleveck/tictactoe.git` (`git remote -v`). The first commits are by the author of the old URL, so the README kept the URL of the upstream fork.
- **Committed SQLite databases, `development.log` and the `.seeds.rb.swp` swap file are removed and git-ignored.** Confirmed.
  - `git ls-files` tracks `backend/db/development.sqlite3`, `backend/db/test.sqlite3`, `backend/log/development.log` and `backend/db/.seeds.rb.swp`.
  - `.gitignore:2` already has `backend/log/*`, but the log was committed before that rule, so git still tracks it. No rule covers `*.sqlite3` or `*.swp`. `backend/` has no `.gitignore` of its own.
  - The two databases and the log change on every test run, so `git status` always shows them as modified (the "unrelated changes" that `CLAUDE.md` step 7 tells each fix to leave out).
  - `backend/config/database.yml:13-23` builds the databases at `db/development.sqlite3` and `db/test.sqlite3`, so `rake db:setup` (README, E5-S1) recreates them. The repo does not need them.

## Gaps not in TODO

- The E6-S9 story lists nothing beyond the three TODO criteria. No extra gap.
- Observed but out of scope: `.idea/`, `backend/.idea/` and `frontend/.idea/` are untracked and not ignored. E6-S9 does not name them. This fix leaves them alone.

## Story references

- The E6-S9 item in `sdd/TODO.md:152-155` has no gap under any E1-E5 story section. No section names E6-S9. No item has only an epic reference.
- The setup docs spec is `sdd/21-e5-s1-run-locally-without-docker.md`. Its one criterion names the steps but not the Ruby version, the clone URL or the files that the repo must not carry.

## Specs to rewrite

1. `sdd/21-e5-s1-run-locally-without-docker.md`: add the Ruby version criterion, the clone URL criterion and the "no generated files in git" criterion.
2. `sdd/34-e6-s9-align-docs-and-tooling-versions.md`: state the exact files, the ignore rules and the tests, as E6-S7 and E6-S8 did.

## Test environment

- Backend: `rbenv exec bundle exec rspec` in `backend/`. Result: 83 examples, 0 failures.
- The new criteria are about files in the repo, not app behaviour. A back-end spec under `backend/spec/repo/` reads the README, the version files and the git index, so the suite fails when they drift again.
