# Align docs and tooling versions (E6-S9)

## Context

The step 2 check (`plans/e6-s9-align-docs-and-tooling-versions-check.md`) confirmed all three E6-S9 gaps. The README says Ruby 2.5.3 while the app pins 2.6.1. The README clones the upstream fork. Git tracks two SQLite databases, the development log and a vim swap file.

Step 3 put the target behavior in `sdd/21-e5-s1-run-locally-without-docker.md`. This plan numbers its new criteria.

- D1: the README Ruby version (requirements line, `rvm install`, `rvm use`) equals `backend/.ruby-version`, the Gemfile `ruby` line and the Dockerfile `FROM ruby:` tag. That version is 2.6.1.
- D2: the README `git clone` URL is the `origin` remote URL.
- D3: git does not track `backend/db/development.sqlite3`, `backend/db/test.sqlite3`, `backend/log/development.log` or `backend/db/.seeds.rb.swp`, and `.gitignore` ignores them.
- D4: a back-end spec checks D1 to D3.

No app code changes. The fix is docs, git index, `.gitignore` and one spec file.

## Design decisions

### Where the spec lives

`backend/spec/repo/setup_docs_spec.rb`. It requires `spec_helper` only, so it does not boot Rails. It finds the repo root as two directories above `backend/spec`. `rails_helper` sets `infer_spec_type_from_file_location!`, which gives `spec/repo` no type, so nothing else changes.

### How the spec reads the versions

It reads `backend/.ruby-version`, matches `ruby '<v>'` in `backend/Gemfile` and `FROM ruby:<v>` in `Dockerfile`, and asserts that the three agree. It then collects every version from the README: the "Ruby <v>" requirements line, `rvm install <v>` and `rvm use ruby-<v>`. Each one must equal the `.ruby-version` value.

### How the spec checks the clone URL

It runs `git config --get remote.origin.url` in the repo root. It normalises both URLs to `host/owner/repo` (drop the scheme or the `git@host:` prefix and a trailing `.git`), so an SSH remote still matches. If the remote is not set, the example is pending with a message, not failing, because a bare checkout has no remote to compare against.

### How the spec checks the git index

`git ls-files -- <four paths>` must print nothing. `git check-ignore -q <path>` must exit 0 for each path. If `git` is not on the path, the examples are pending.

### What happens to the local files

`git rm --cached` removes the four files from the index only. The local databases and log stay, so `rails server` and `rspec` keep working without a `rake db:setup`. The swap file also stays on disk; git ignores it from now on.

## Steps

1. Save this plan to `plans/e6-s9-align-docs-and-tooling-versions.md`. Done when the file exists.
2. Stay on branch `fix/e6-s9-align-docs-and-tooling-versions`.
3. Edit `README.md`: 2.5.3 becomes 2.6.1 in three places; the clone URL becomes `https://github.com/jleveck/tictactoe.git`.
4. Edit `.gitignore`: add `backend/db/*.sqlite3`, `backend/db/*.sqlite3-journal` and `*.swp`.
5. Run `git rm --cached` on the four tracked files.
6. Add `backend/spec/repo/setup_docs_spec.rb` (D1 to D4).
7. Run the tests. See "Commands".
8. TODO (CLAUDE.md step 6): check off the E6-S9 story and its three criteria in `sdd/TODO.md`. Add an E5-S1 section with the three gaps and check them off.
9. Commit (CLAUDE.md step 7). See "Files to stage".

## Tests for each criterion

| Criterion | Test | File |
|---|---|---|
| D1 | "pins the same Ruby version in .ruby-version, the Gemfile and the Dockerfile"; "names that Ruby version in every place in the README". | `backend/spec/repo/setup_docs_spec.rb` |
| D2 | "clones the origin remote". | `backend/spec/repo/setup_docs_spec.rb` |
| D3 | "does not track the databases, the log or the swap file"; "ignores the databases, the log and the swap file". | `backend/spec/repo/setup_docs_spec.rb` |
| D4 | The spec file itself, run by `rspec`. | `backend/spec/repo/setup_docs_spec.rb` |

## Existing tests that must change

None. No app code changes, so every existing test keeps passing.

## Commands

Back end, in `backend/`:

```sh
rbenv exec bundle exec rspec
```

Front end, in `frontend/` (no change, run to confirm):

```sh
CI=true npm test
```

## Files to stage

- `sdd/21-e5-s1-run-locally-without-docker.md`
- `sdd/34-e6-s9-align-docs-and-tooling-versions.md`
- `sdd/TODO.md`
- `README.md`
- `.gitignore`
- `backend/spec/repo/setup_docs_spec.rb`
- The four `git rm --cached` deletions.
- `plans/e6-s9-align-docs-and-tooling-versions-check.md`
- `plans/e6-s9-align-docs-and-tooling-versions.md`

Do not stage `.idea/`, `backend/.idea/`, `frontend/.idea/` or `TicTacToe-ProductRequirements.pdf`.

## Out of scope

- Ignoring `.idea/`. E6-S9 does not name it.
- The Heroku URL and the screenshots in the README.
- A `backend/.gitignore`. The root file already holds the backend rules.

## Verification

- `rbenv exec bundle exec rspec` passes in `backend/`.
- `CI=true npm test` passes in `frontend/`.
- `git status` no longer lists the databases or the log as modified.
- Each criterion D1 to D4 has a test in the table above.
