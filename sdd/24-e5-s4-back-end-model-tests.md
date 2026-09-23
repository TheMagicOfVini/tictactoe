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
- Request specs cover every endpoint. Each one has `type: :request` and reads the response with the `json` helper of `RequestSpecHelper`:
  - Index: `GET /api/v1/players` returns 200 and a JSON array with every player and the fields `id`, `name`, `wins`, `losses` and `draws` (E4-S2).
  - Show: `GET /api/v1/players/:id` returns 200 and the player as JSON. An unknown id raises `ActiveRecord::RecordNotFound`, which Rails maps to 404 (E4-S2).
  - Create, valid: `POST /api/v1/players` returns 201, the created player as JSON and a `Location` header with the URL of the player (E4-S3).
  - Create, invalid: a blank `name` returns 422 and the errors as JSON, and creates no player. A known `name` returns 422 (E4-S3).
  - Update: the valid, invalid and unauthorised cases of E4-S4.
  - Destroy: the valid and unauthorised cases of E4-S5.
