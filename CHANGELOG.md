# Changelog

## 0.1.1 — 2026-09-14
- Knowledge-base question (`3.A5`, ask-then-verify) on first run; stored as `knowledge_base` in the ladder profile and reused by `incident-response --init`.
- `--init` now asks for state store and notify channel when the ladder profile lacks them.
- README: the questions each skill asks, and the process of the scale as a text graph.

## 0.1.0 — 2026-09-14
- `ladder` skill: probe script, discovery reference, rubric (steps table, gates 0→1 to 3→4, guardrails axis), profile and report templates.
- `incident-response` skill ported from a private draft; project specifics removed; `--init` now reuses the ladder probe; report gains the "would an engineer have done this?" field.
- Probe verified against Claude Code 2.1.257.
