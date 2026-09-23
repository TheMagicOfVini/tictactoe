You work in /Users/tmov/repos/cryoport/tictactoe. Read /Users/tmov/repos/cryoport/tictactoe/CLAUDE.md first. It defines a 7-step "Fix a TODO item" process. You do ONLY step 1 (Branch). Do not edit any file. Do not commit.

Do step 1: find the first unchecked item in `sdd/TODO.md`. Take the story id from it and the slug from the title of its E6 story. Create `fix/<story-id>-<slug>` from `master` and switch to it. The working tree has unrelated changes (`backend/db/*.sqlite3`, `backend/log/`, `.idea/`, `TicTacToe-ProductRequirements.pdf`) and an untracked prompt folder in `plans/`. Leave them as they are; they carry over to the new branch.

Note: every story section above the "E6" heading in the TODO is checked. The first unchecked item is the E6 story entry itself. In that case, the story id is the E6 story id, in lower case (for example `e6-s7`). Look at `git branch` to match the naming of earlier fix branches.

Completion criterion: the new branch exists, it points at the `master` commit, and it is the current branch. Never use emdashes. Return the branch name, the TODO item you used, and the output of `git status --short --branch`.
