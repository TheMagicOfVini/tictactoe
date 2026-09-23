# E5-S4 Back-end model tests

**Epic:** E5: Developer Environment, Testing & Delivery

**Epic goal:** a developer can run, test and ship the app with minimal setup.

As a developer, I want RSpec model specs with FactoryBot/Faker data, so that model rules are verified.

**Acceptance criteria**

- `Player` responds to name/wins/losses/draws, is valid with factory data, and is invalid without a name.
- The factory gives each player a unique name, so factory players do not break the unique name rule.
- A test shows that a second player with the name of another player is not valid, and that the error is on `name`.
- A test shows that the `players` table has a unique index on `name`, and that the database rejects a duplicate name with `ActiveRecord::RecordNotUnique`.
- A test shows that names that differ only in case (`Alice` and `alice`) are two valid players.
