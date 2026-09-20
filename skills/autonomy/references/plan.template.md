---
plan_version: 1
generated: <YYYY-MM-DD>
plugin: ladder-adoption <plugin version from plugin.json>
profile: <date of .ladder/profile.md> · step <n> · next gate <n->n+1>
scope: <date of .ladder/scope.md | none>
run: <attended | headless>
phases: "<0:planned|done|skipped 1:… 2:… 3:… 4:… 5:… 6:…>"
covers_phases: <0-6 | 0-2 (no scope) | 0-4 (no event source or channel in scope)>
blocked_on_human: <count>
---
# Plan — <repo name>

From `.ladder/profile.md` (step <n>, gate <n>→<n+1>, failing: <ids>) and
`.ladder/scope.md` (<one line: the goal in the user's own terms>).

This file is a proposal. Nothing in it has been applied.

## Why this order
<two or three lines: which ordering rules from phases.md bind here, and why. Name the one
fact about this project that most shapes the order — usually what a push to the default
branch does.>

## Phases

### Phase <n> — <name>   ·   <planned | done | skipped>
- **Closes:** <rubric ids, from the profile's failing list>
- **Touches production:** <no | read-only | yes — and why that is acceptable>
- **Changes:** <files, one per line>
- **Yours, not the agent's:** <secrets, billing, app installs, branch protection, merges; or "none">
- **Exit proof:** <a check that can come back negative, with the number or artifact that settles it>
- **Stop if:** <what would make this phase the wrong thing to do>

<repeat per phase>

## Stops at phase <n>
<why the plan goes no further: a missing scope answer, no event source, no channel. Name
what would extend it.>

## Residual gaps
<things no phase closes, stated plainly. Example: a permission rule is a fuse, not a lock;
on this tier there is no branch protection, so a push shaped in a way the pattern does not
match reaches the default branch.>

## Checks that do not block this goal
<from the profile: failing checks that the scope makes irrelevant, with the reason. They
stay failing in the profile; they simply are not in the path to what the user asked for.>

## Cost
<what phase 2 and phase 4 spend per run, and out of which budget, when known; "unknown,
measure on the first run" when not.>

## Open decisions
<one line each, the human's to make>
