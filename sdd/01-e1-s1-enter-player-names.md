# E1-S1 Enter player names

**Epic:** E1: Player Setup

**Epic goal:** two named players must be registered before a match can be played, so results can be attributed to them.

As a player, I want to open a "Set Names" dialog and enter names for Player One and Player Two, so that the game knows who is playing.

**Acceptance criteria**

- A "Set Names" button opens a modal (`reactjs-popup`) containing two text inputs (`player_one`, `player_two`) and a Submit button.
- Submitting stores both names in board state without reloading the page (`event.preventDefault()`).
- Player One plays O and Player Two plays X.
