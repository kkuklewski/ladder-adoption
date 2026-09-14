# `--init` discovery — incident-specific checklist

Run **after** the ladder probe (`../../ladder/references/discovery.md`); it already covers
identity, Claude context, verification scripts, deploy files, migrations, env-file names.
Read-only. Tag every line `verified` or `assumed`.

## 1. Verification contract
For each of `lint, typecheck, unit, integration, e2e, build, security` record the **exact
command** from the probe's `repo.scripts` (or Makefile / pyproject) or `not_available`. A
script that exists but references a missing config is `assumed`. Try `--help` or a dry run
only. Note wall-clock cost where CI logs or workflow timeouts show it.

## 2. Error intake (where incidents come from)
- grep the repo for: `sentry`, `logtail`, `pino`, `winston`, `console.error`, `error.tsx`,
  `global-error`, `onError`, `*_WEBHOOK`, API handlers with try/catch that forward errors.
- External pipeline the repo does not own (an automation host, a chat channel, a triage
  script): record what docs prove; tag `assumed` unless a file in this repo shows it.
- Payload shape available today vs. the normalised shape in SKILL.md step 1: list missing
  fields (typically `request_id`, `git_commit`, `fingerprint`).

## 3. State store
- Is there already a table/collection/tracker for incidents (a DB table, GitHub Issues, a
  task tool)? Prefer extending it over a new table. Record: name, access method (REST, MCP,
  CLI), columns present, columns missing for the loop
  (`fingerprint, status, agent_session_url, pr_url, resolution`).
- Dedupe: does intake already compute a fingerprint? If not, propose one from fields that
  exist (`error_type + route + top stack frame`) and say it belongs in intake, not the agent.

## 4. Deploy and blast radius
Which single action deploys (push to main? tag? dashboard click?) and which command applies
migrations. Both go on the proposed deny list.

## 5. Secrets (names only)
From `.env.example`, CI workflow `secrets.*` references, and env names in docs. Classify
each name: `read-only for agent` / `must not be available to agent` / `proxied by intake`.
Never print values.

## 6. Knowledge beyond code
Start from `knowledge_base` in `.claude/ladder-profile.md` if present; otherwise it was
asked in SKILL.md Mode A step 3. Is a docs folder, wiki, or vault linked? Which parts are source of truth vs notes? Is a
lookup order documented (cite it, do not restate it)? Prior incidents for this repo: count
and where.

## 7. Autonomy and limits
Propose `autonomy_phase: 1` for a fresh profile. Suggest 2 only when unit + typecheck are
`verified` and a state store with dedupe exists. Defaults: `max_turns: 40`,
`max_runtime: 20m`, `max_cost`: owner sets. Written as fields the human edits.

## 8. Write and report
Fill `profile.template.md` → `.claude/incident-profile.md`. Print the gap list ordered by
what blocks Phase 1 first (no state store, no dedupe), then Phase 2 (no tests), then
nice-to-have. Print the proposed `permissions.deny` block; do not apply it.
