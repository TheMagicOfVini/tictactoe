# E6-S9 Align docs and tooling versions

**Epic:** E6: Hardening & Defect Fixes

**Epic goal:** close the gaps found while mapping the code. Each story is a proposed change, not existing behaviour.

As a new contributor, I want consistent setup instructions, so that I can get running first time.

**Acceptance criteria**

- README Ruby version matches the Gemfile/Dockerfile (2.6.1, not 2.5.3).
- README clone URL points at this repository.
- Committed SQLite databases, `development.log` and the `.seeds.rb.swp` swap file are removed and git-ignored.
