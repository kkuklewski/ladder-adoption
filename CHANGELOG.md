# Changelog

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
