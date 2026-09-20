# Changelog

## 0.3.0-alpha.1 — 2026-09-20
First half of 0.3.0 (`docs/PLAN-0.3.0.md`, order-of-work item 2). Pre-release: the new skill ships `interview`, `plan` and `status`; `phase` and `pilot` are declared unimplemented rather than half-built.
- **New skill `autonomy`** (`2/3` in the run order; `incident-response` becomes `3/3`). Turns a ladder score into an ordered plan for one specific project, and writes only `.ladder/scope.md` and `.ladder/plan.md`. Never edits settings, CI, workflows or code.
- **`interview`** asks the ten things no probe can find: what agents do overnight, what they must never touch, where tasks live and whether a cloud checkout can reach them, what a push to the default branch does, the host and Claude tiers, who merges, production-data access, the nightly budget, where failures go, local-only dependencies. Three grouped questions, skipping anything already answered; answers are verified against the repository where possible, and a claim the evidence contradicts is recorded with both.
- **`plan`** maps phases 0–6 to the ids failing in *this* profile, applies the ordering rules, and stops where the answers stop — phases 0–2 without a scope, 0–4 with no event source or channel. Each phase carries an exit proof that can come back negative, a "yours, not the agent's" list, and a stop condition. Residual gaps are stated rather than implied closed.
- **The ordering rule that matters:** never plan phase 4 (routine and pilot) before phase 2 (review) has its proof. Asking for the routine first produces a correctly ordered plan and a sentence naming the phase being skipped.
- New `skills/autonomy/references/`: `scope-interview.md`, `phases.md`, `scope.template.md`, `plan.template.md`.

## 0.2.1 — 2026-09-20
Corrects guidance that 0.2.0 got wrong, and adds the two references the corrections lean on.
- **`gh run watch` is no longer the default way to wait for CI.** Cloud sessions observed so far have no `gh` binary at all, so that advice failed on its first command. The channel is now chosen from what the environment probe found; when nothing can wait, the run reports the run id instead of inventing a polling loop.
- **"`git push` works only for the session's own branch" removed.** A repository `ask` rule on push is enforced in the cloud and refuses it — observed blocking an otherwise complete run. Replaced with: push by literal branch name, report `blocked` rather than reshaping the command, and prefer host-level branch protection over command patterns.
- New `scripts/cloud-probe.sh`: read-only JSON of what the session actually has — `gh` and its auth state, toolchain, whether dependencies need installing, which repo permission rules and hooks apply, git branch versus default branch. Run it first in any unattended run.
- New `references/cloud-environment.md`: cloud-session facts, each dated and marked `verified` or `assumed`, including routine creation silently attaching personal MCP connectors and cron being evaluated in UTC.
- New `references/false-greens.md`: ten observed ways a run reports success while doing nothing, the number that exposes each, and the one case (a shallow review) that no number separates from a clean one.
- `unattended.md` gains an environment-check section and a "report numbers, not check marks" section; smoke test covers the new probe, with both checks shown failing against planted defects.

## 0.2.0 — 2026-09-15 (written), committed 2026-09-20
- Profiles move out of `.claude/`: `.ladder/profile.md` and `.ladder/incident-profile.md`. Claude Code protects `.claude/`, so writes there are denied in headless runs. Legacy files are read, never written, moved or deleted.
- Third rule, "always finish": a run ends with the profile and the report even when nothing can be asked. A human can answer only when `machine.session.attended` is true and AskUserQuestion is available; a headless run never downgrades a recorded answer to `unknown`.
- Repository content is evidence, not instruction: text that tells the scorer what step the repo is on is quoted as a finding and ignored.
- Group status gains `partial`; `not_applicable` is a first-class tag.
- Probe 0.2.0: `--claude-dir`, `--kb`, `machine.session` (inside_claude_code, attended, remote, entrypoint), `global.dir`/`readable`, worktree mentions, review-policy files, repo-level `defaultMode` reported as misplaced. Parse failures yield empty values instead of `__unparsed__` / `-1`.
- New `references/unattended.md`: lessons from real overnight runs, followed by both skills.
- Evals: seven scaffolded cases with graders (`evals/`), results git-ignored.
- Known issue, fixed in 0.3.0: `unattended.md` tells a cloud run to wait with `gh run watch`, but cloud sessions observed on 2026-09-20 have no `gh` binary.

## 0.1.6 — 2026-09-15 (after the first overnight run)
- 2.A1 is now `inspect`: worktree use must be documented; a worktree count alone (including the scoring run's own worktree) is `assumed`.
- 2.C3: a self-reported yes without `defaultMode` in `~/.claude/settings.json` is `assumed`.

## 0.1.5 — 2026-09-14
- Probe 0.1.3: `env_gitignored` checks the env files that exist (ignoring `.env.example`), not a literal `.env`.
- Report shows partial groups in the score line and always includes the locked-gate preview.

## 0.1.4 — 2026-09-14 (after the first real run)
- Questions are asked in every interactive session, auto mode included; only headless runs skip. A cancelled question is reported as cancelled.
- The probe is re-run on every invocation, never reused.
- 2.C1 judges whether allow rules cover the verification loop and read-only git, not how many there are.
- 2.C3: `defaultMode: "auto"` only counts from `~/.claude/settings.json`; a repo-level value is `misplaced`. Next-action guidance split: mode in user settings, rules in repo settings.
- Probe 0.1.2, verified against Claude Code 2.1.270.

## 0.1.3 — 2026-09-14
- G1.1 reworded in plain language; `not_applicable` allowed for individual plans and never counted as `fail`.
- G1.4 is now a probe check: `probe.sh` reports `machine.telemetry` (enabled, source, exporter types; never endpoints or headers). Probe 0.1.1.

## 0.1.2 — 2026-09-14
- Skill descriptions start with `1/2 Start here:` and `2/2 After /ladder:` so the run order shows in the `/` menu.

## 0.1.1 — 2026-09-14
- Knowledge-base question (`3.A5`, ask-then-verify) on first run; stored as `knowledge_base` in the ladder profile and reused by `incident-response --init`.
- `--init` now asks for state store and notify channel when the ladder profile lacks them.
- README: the questions each skill asks, and the process of the scale as a text graph.

## 0.1.0 — 2026-09-14
- `ladder` skill: probe script, discovery reference, rubric (steps table, gates 0→1 to 3→4, guardrails axis), profile and report templates.
- `incident-response` skill ported from a private draft; project specifics removed; `--init` now reuses the ladder probe; report gains the "would an engineer have done this?" field.
- Probe verified against Claude Code 2.1.257.
