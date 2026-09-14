# ladder-adoption

**Find your rung on the Steps of AI Adoption, and the next one up.**

A Claude Code plugin with two skills:

| skill | what it does |
|---|---|
| `/ladder` | Blank-sheet discovery of this machine and repo, scored against Boris Cherny's *Steps of AI Adoption* (Jul 2026). Tells you which step you are on, which gate checks fail, and the single smallest next action. Writes `.claude/ladder-profile.md`. Never changes settings itself. |
| `/incident-response` | A supervised loop for one production incident: retrieve context, diagnose with a confidence level, optionally prepare a fix in a worktree, run the repo's verification contract, report to a human. Never deploys or merges. It is one concrete way to earn the 2→3 gate. |

## The one principle

The plugin knows nothing about you, your machine, or your project. It ships only
**where to look** (`skills/ladder/references/discovery.md`, `scripts/probe.sh`) and
**the rubric** (`skills/ladder/references/rubric/`). Everything else is discovered at run
time and tagged `verified`, `assumed`, or `unknown`. Findings live in a committed profile
file in the repo, not in agent memory, so a headless run on another machine starts from the
same state.

## Install

```text
/plugin marketplace add kkuklewski/ladder-adoption
/plugin install ladder-adoption@ladder-adoption
```

Or clone and load locally:

```bash
claude --plugin-dir ./ladder-adoption
```

## Use

```text
/ladder                 score the current repo, write the profile, propose the next action
/ladder scan            print the raw probe JSON only
/ladder next            print only the smallest next action
/ladder --json ../repo  machine-readable output for fleet tooling
/incident-response --init
/incident-response INC-123
```

The probe is a plain bash script you can run without Claude:

```bash
bash skills/ladder/scripts/probe.sh /path/to/repo | jq .
```

It is read-only and prints names and counts, never secret values.

## How scoring works

Cherny's table has an explicit row for every transition: *how to get from step N to N+1*.
Each row becomes a gate file with checks. A check is `probe` (decided from the script
output), `inspect` (Claude reads a file and judges), or `self-report` (not observable on
disk; asked once, otherwise `unknown`). A gate group passes only when every required check
is `verified`; `unknown` never passes. Guardrails are a separate axis and never move the
step number, but always appear in the report.

The step is a summary. The deliverable is the list of failing check ids and one next action.

## Honesty by design

A repo at Step 1 with a Step 3 mechanism bolted on (an event that starts Claude) is still
Step 1. The source names that trap: scaling agent count before the loop has earned trust.
The report says which 1→2 groups are missing instead.

## Acceptance test

Clone any open-source repo onto a machine with a fresh `~/.claude`, run `/ladder`, and get a
clean Step 0 or 1 report with zero errors and zero mention of the plugin author. See
`evals/`.

## Source

Boris Cherny, *Steps of AI Adoption*, 16 Jul 2026. The rubric transcribes the table's
"how to get from step N to N+1" rows and its Guardrails column; where the exported source
was cut off, the rubric says `[truncated in source]` instead of guessing.

## Layout

```text
.claude-plugin/plugin.json          manifest
.claude-plugin/marketplace.json     lets `/plugin marketplace add` point at this repo
skills/ladder/SKILL.md              the scorer
skills/ladder/scripts/probe.sh      read-only discovery, JSON out
skills/ladder/references/           discovery.md, rubric/, profile + report templates
skills/incident-response/           the loop, uses the same probe for --init
evals/                              smoke test for the probe and the blank-sheet acceptance test
```

MIT.
