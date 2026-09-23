# E6-S9 Align docs and tooling versions

**Epic:** E6: Hardening & Defect Fixes

**Epic goal:** close the gaps found while mapping the code. Each story is a proposed change, not existing behaviour.

As a new contributor, I want consistent setup instructions, so that I can get running first time.

**Acceptance criteria**

- README Ruby version matches the Gemfile/Dockerfile (2.6.1, not 2.5.3) (E5-S1):
  - The requirements line, `rvm install` and `rvm use` all say 2.6.1.
  - The source of truth is `backend/.ruby-version`, the `ruby` line of `backend/Gemfile` and the `FROM ruby:` tag of `Dockerfile`. All three agree.
- README clone URL points at this repository (E5-S1):
  - The `git clone` line uses the URL of the `origin` remote, `https://github.com/jleveck/tictactoe.git`, not the upstream fork.
- Committed SQLite databases, `development.log` and the `.seeds.rb.swp` swap file are removed and git-ignored (E5-S1):
  - `git rm --cached` removes `backend/db/development.sqlite3`, `backend/db/test.sqlite3`, `backend/log/development.log` and `backend/db/.seeds.rb.swp` from the index. The local working copies stay, so a checked-out app keeps running.
  - `.gitignore` adds `backend/db/*.sqlite3`, `backend/db/*.sqlite3-journal` and `*.swp`. `backend/log/*` is already there.
- A back-end spec under `backend/spec/repo/` reads the README, the version files, the `origin` URL and the git index, and fails when any rule above breaks.
