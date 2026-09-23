# E6-S8 Expand automated test coverage

**Epic:** E6: Hardening & Defect Fixes

**Epic goal:** close the gaps found while mapping the code. Each story is a proposed change, not existing behaviour.

As a developer, I want request specs and interaction tests, so that API and gameplay behaviour are verified end to end.

**Acceptance criteria**

- RSpec request specs cover index, show, create (valid/invalid), update and destroy, using the existing `RequestSpecHelper`.
- React Testing Library tests cover: clicks ignored before names are set, alternating turns, win and draw status messages, New Game reset, and scoreboard API calls (with axios mocked).
- The Scoreboard test is rewritten; it currently passes a `players` prop the component ignores.
