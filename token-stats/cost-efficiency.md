# Cost Efficiency of the Claude Code Sessions

Date: 2026-09-23. Source: `token-stats/sessions.csv` joined with the git log by time. All costs are estimates from list prices; see `report.html` for the method.

## Summary

Seven sessions each closed one or two E6 stories through the same 7-step process in `CLAUDE.md`, so they are the fair comparison.

- Interactive Opus was the cheapest per story.
- Fable one-shot was the cheapest per unit of human attention and the fastest.
- Subagents were the worst on both axes.

The sample is tiny. Treat this as a signal, not a verdict.

## The TODO sessions

| Method | Session start | Stories | Prompts | Cost | Wall | Lines | $/story | Prompts/story |
|---|---|---|---|---|---|---|---|---|
| Opus, confirm each step | 04:11 PM | E6-S1, E6-S3 | 17 | $1.54 | 14 min | 154 | $0.77 | 8.5 |
| Opus, confirm each step | 04:25 PM | E6-S2, E6-S4 | 18 | $1.98 | 16 min | 109 | $0.99 | 9 |
| Opus main + Opus subagents | 04:42 PM | E6-S5 | 8 | $5.73 | 20 min | 272 | $5.73 | 8 |
| Opus main + Sonnet subagents | 05:03 PM | E6-S7 | 14 | $4.81 | 22 min | 466 | $4.81 | 14 |
| Opus, direct ask, no process | 05:25 PM | PUT/DELETE auth | 3 | $0.97 | 4 min | 41 | $0.97 | 3 |
| Fable, one prompt, autonomous | 05:29 PM | E6-S8 | 1 | $4.78 | 8 min | 566 | $4.78 | 1 |
| Fable, one prompt, autonomous | 05:38 PM | E6-S9 | 2 | $2.51 | 4 min | 264 | $2.51 | 2 |

Times are local. "Lines" is lines added as logged by Claude Code.

## Cost efficiency insights

### Cache writes are half the bill

Every token that enters context is written once at the cache-write rate ($8/M on Opus, $20/M on Fable) and then re-read at $0.20 to $0.25/M on each later call. A 10k-token test log costs $0.08 on Opus the first time and almost nothing after. The lever is less verbose tool output, not smaller files.

### Subagents multiplied the cache writes by eight

The interactive sessions wrote about 60k to 77k tokens to cache. The subagent sessions wrote 466k to 486k, because each of the seven agents re-read the specs and the code from zero. The process is strictly sequential, so there was nothing to parallelize and the isolation bought nothing. The main thread still peaked at 114k and 133k context, the highest of any session, because every handback lands in the main thread.

### Sonnet workers were cheaper than Opus workers

$4.81 against $5.73, while producing more lines. That supports cheap models for delegated steps, but it is one run each.

### Fable's per-call cost is 3.5x Opus

$0.16 against $0.05 per call. Fable also generates 60% more output per call. Yet the Fable one-shots are cheapest per line of code ($0.008 to $0.010 per line) because they finish in 18 to 22 calls instead of 42 to 144.

### Interactive confirmation is cheap in dollars and expensive in attention

Each "ask before every step" story took 8 to 9 human prompts, and the model often waited with a 90k context loaded.

### Effort is a confound

All Opus calls ran at medium effort. All Fable calls ran at high. Part of the Fable cost is the effort setting, not the model.

## Which method is best?

It depends on which resource you optimize.

| Goal | Best method | Figure |
|---|---|---|
| Dollars per story | Opus interactive | About $0.90 per story. Roughly 4x cheaper than Fable one-shot and 6x cheaper than subagents. |
| Human time per story | Fable one-shot | 1 to 2 prompts and 4 to 8 minutes wall time, for about $3.65 per story. |
| Subagents | Not worth it here | Only pays off if steps can run in parallel or the main context would overflow. |

### Caveats

- Story sizes differ by 5x in lines changed.
- Each method has one or two runs.
- Quality was not scored. A cheaper run that needed rework later is not visible here.

## How to test further approaches

The TODO list is fully checked, so new runs need tasks. The cleanest design is to replay the finished stories. Each E6 fix has a parent commit, so a `git worktree` at that commit gives every method the identical task, which removes the story-size confound.

### 1. Fix the protocol

- One story per session.
- Always a fresh session.
- The same opening prompt except for the method.
- Prefix the prompt with a tag such as `[exp:fable-auto]` so the extractor can group runs. An `experiment` column in `extract.py` can read that tag.

### 2. Vary one factor per arm

Arms worth running first:

- **Opus one-shot autonomous** (no confirmations). Isolates "autonomy" from "model". Fable one-shot was never compared with an Opus one-shot.
- **Fable at medium effort.** Tests whether the 3.5x per-call gap is the model or the effort setting.
- **Opus main with a Sonnet or Haiku subagent for the Check step only.** That step is read-heavy and its output is small, which is the one place delegation should help.
- **Trimmed tool output** (pipe test and log output through `tail`). Directly attacks the cache-write share.

### 3. Score every run the same way

- Estimated cost
- Number of human prompts
- Wall time
- Lines changed
- `CI=true npm test` result
- Defect count from a fixed `/code-review` pass

The headline metric is cost per accepted story. Prompts per story is the second axis.

### 4. Repeat each arm three times

Use three different stories per arm. With n=1 the noise is bigger than the differences you are looking for.

## Replay commits

Parent commits to check out for a replay, from the git log:

| Story | Fix commit | Parent to replay from |
|---|---|---|
| E6-S1 | `cf2ba2c` | `1bcba8b` |
| E6-S3 | `57b8830` | `bcfc934` |
| E6-S2 | `f9b89f5` | `57b8830` |
| E6-S4 | `7d8317a` | `f9b89f5` |
| E6-S5 | `249172b` to `58e9f55` (one commit per step) | `bab366d` |
| E6-S7 | `873b616` to `95491f9` (one commit per step) | `1c35291` |
| E6-S8 | `33df35b` | `b7b6294` |
| E6-S9 | `2e7ddfe` | `33df35b` |
