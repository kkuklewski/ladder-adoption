---
name: ladder
description: >-
  Find which rung of the Steps of AI Adoption (Cherny, 2026) this machine and repo stand on,
  and what the next rung costs. Blank-sheet discovery: runs a read-only probe of the machine
  (Claude Code version, global settings, skills, MCP servers, plugins, CLIs) and the repo
  (CLAUDE.md, .claude/, verification scripts, CI, deploy files), scores it against the
  "how to get from step N to N+1" gates and the guardrails axis, writes
  .claude/ladder-profile.md, and proposes the single smallest next action. Use when asked
  "where are we on AI adoption", "what step are we at", "what's blocking step 2/3",
  "assess this repo for agent readiness", or to refresh the profile. Never applies changes
  itself.
argument-hint: "[scan | score | next | --json] [repo-path]"
allowed-tools: Bash(bash *probe.sh*) Read Grep Glob
---

# ladder — where you stand, and the next rung up

Two rules that make this work for anyone, on any machine:

1. **Nothing about the user or the project is baked in.** The skill ships only
   `references/discovery.md` (where to look) and `references/rubric/` (Cherny's table as
   checks). Everything else is found at runtime and tagged `verified` / `assumed` / `unknown`.
2. **Score, propose, stop.** The output is a report and a profile file. Applying the next
   action (editing `settings.json`, adding CI, enabling a hook) is a human's call, every time.

## Arguments

`$ARGUMENTS` — optional mode and path. Default mode is `score`, default path is the current
repo root. `scan` prints the probe only. `next` prints only the smallest next action.
`--json` emits the probe JSON plus `{step, next_gate, score, next_action}` for fleet tooling.

## Procedure

1. **Probe.** Follow `references/discovery.md` §1: run `scripts/probe.sh <path>` from this
   skill's directory. If `scan` was asked, print the JSON and stop.
2. **Load prior state.** If `repo.dot_claude.ladder_profile` is true, read
   `.claude/ladder-profile.md`; keep its self-reported answers and note its `current_step`
   so the report can say "changed since <date>".
3. **Inspect what the probe cannot judge** (`discovery.md` §2, right column). Read every
   CLAUDE.md the probe listed. Read `.claude/settings*.json` deny lists. Do not read `.env*`.
4. **Place the repo.** Walk the gates in order using `references/rubric/gate-*.md`:
   - gate 0→1: if 1.1–1.3 fail → **Step 0**.
   - gate 1→2: score groups A–D. All pass → continue; otherwise **Step 1**, this is the
     next gate.
   - gate 2→3: same → else **Step 2**.
   - gate 3→4: same → else **Step 3**; all pass → **Step 4**.
   A group passes only when every `required` check is `verified`. `unknown` never passes.
   Gates beyond the next one are reported as `locked` with their item list, not scored.
5. **Guardrails.** Score `references/rubric/guardrails.md` for the current step only.
   Report them as a separate line; a guardrail failure never raises or lowers the step but
   is always named in the report.
6. **Self-reports.** Gather the `self-report` ids from the next gate and current-step
   guardrails; ask them as one grouped question, once. On the first run (no profile, or
   profile without `knowledge_base`) add the knowledge-base question from
   `discovery.md` §5 and verify a local path with `ls`. In a non-interactive run
   (`claude -p`, routine) skip the question and leave them `unknown`.
7. **Smallest next action.** Pick the single failing `required` check that is cheapest to
   fix and unlocks the most: prefer things a file edit fixes (a deny rule, a `typecheck`
   script, a CI workflow) over things that need a team decision. State the exact change and
   who applies it.
8. **Write and report.** Fill `references/profile.template.md` → `.claude/ladder-profile.md`
   (if one existed, show a short diff first and ask before overwriting in interactive
   mode). Print `references/report.template.md` to the user. For `--json`, print the JSON
   block after the report.

## Honesty rules

- A repo at Step 1 with a Step 3 mechanism bolted on (a trigger that starts Claude) is still
  Step 1. Cherny's trap is scaling agent count before the loop has earned trust; the report
  says which gate-1→2 groups are missing, in plain words.
- The step number is a summary; the deliverable is the failing-check list and the next
  action. Never print a percentage without the ids behind it.
- If `machine.claude_version` is newer than `probe_written_for_claude`, add the version note
  from `report.template.md` and tag probe-derived `false` values as `assumed`.
- Names only, never values. See `discovery.md` §4.

## What this skill does not do

- It does not enable auto mode, edit settings, add hooks, or create CI. It proposes.
- It does not measure how you work (parallel sessions, review habits); those are
  `self-report` and stay `unknown` until you answer.
- It does not rank people or teams. One repo, one report.
