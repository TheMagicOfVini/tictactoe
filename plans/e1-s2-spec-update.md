# Update the E1-S2 spec to include the E6-S6 fixes

## Context
The check of TODO item E1-S2 found that the code meets the E1-S2 spec as written. The spec is too loose. It does not require names to be trimmed, it does not define case handling, and it does not say what happens when names are bad or when they change. E6-S6 lists these fixes. The user wants the E1-S2 spec to state this behavior, so that the TODO items become gaps between the spec and the code.

## Steps
1. Create the directory `plans/` at the repo root. Save this plan there as `plans/e1-s2-spec-update.md`.
2. Edit the spec as described below.

## Change
Edit one file: `sdd/02-e1-s2-validate-player-names.md`. Keep the title, the epic lines and the user story. Replace the acceptance criteria with:

```
**Acceptance criteria**

- Leading and trailing whitespace is removed from both names before validation and storage.
- Players are considered "set" only when both trimmed names are non-empty and different from each other, ignoring case (`playersSet`).
- If a submitted pair is not valid, the pair is rejected: the current names stay unchanged and the form shows an error message that states the problem (a blank name, or two names that are the same).
- When a valid pair changes the names, the board resets in the same way as New Game (E2-S6).
- Until players are set, the header reads "Set the names of both players." and no status line is shown.
- Once set, the header shows "`<Player One>` Vs. `<Player Two>`".
```

Decision in this draft: a bad submit keeps the old names. It does not clear them. Today the code overwrites the names with the bad values.

Out of scope: the code, E6-S6 and `sdd/TODO.md`. The TODO items still describe real gaps against the new spec.

## Verification
- Confirm that `plans/e1-s2-spec-update.md` exists.
- Read the edited file. Confirm each TODO E1-S2 item matches one new criterion.
- Confirm that the file has no emdashes.
