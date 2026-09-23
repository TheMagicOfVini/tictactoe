# E5-S3 Front-end unit tests

**Epic:** E5: Developer Environment, Testing & Delivery

**Epic goal:** a developer can run, test and ship the app with minimal setup.

As a developer, I want automated tests for game logic and components, so that regressions are caught.

**Acceptance criteria**

- `calculateWinner` is tested for empty board, incomplete lines, and horizontal, vertical and diagonal wins.
- `Square` is tested for empty, "X" and "O" rendering, with a snapshot.
- `Board` is tested to render 9 squares; `Scoreboard` and `App` render without crashing.
