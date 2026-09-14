---
profile_version: 1
generated: <YYYY-MM-DD>
stale: false
autonomy_phase: 1        # 1 diagnose · 2 prepare fix · 3 supervised autonomy
---
# Incident profile — <repo>

## Identity
- remote: <url> (`verified`)   base_branch: <main>   on_github: <yes|no>
- claude context: CLAUDE.md <path|none>, skills: <list>, deny rules present: <yes|no>

## Verification contract (run in this order)
| step | command | status | ~time |
|---|---|---|---|
| lint | `<cmd>` | verified / not_available | |
| typecheck | | | |
| unit | | | |
| integration | | | |
| build | | | |
| e2e | | | |
| security | | | |

## Error intake
- pipeline: <source → … → where the agent reads it>  (`verified|assumed`)
- payload fields available: <list>; missing for the loop: <list>
- fingerprint: <computed where, from what> | none yet

## State store
- store: <table / system>, access: <REST|MCP|CLI>, credentials env var: <NAME>
- columns present / missing: …
- statuses used: new · investigating · fix_prepared · verification_failed · waiting_for_human · resolved · ignored

## Knowledge base
- knowledge_base: <local path | repo | url | none>  (`verified|assumed`) — same value as the ladder profile

## Context order (retrieval, stop early)
1. `git log -20 -- <affected path>`
2. code path of the endpoint
3. <CLAUDE.md / docs paths>
4. <knowledge base: decisions → context → notes> (lookup order defined in <path>; follow it)
5. state-store history for the fingerprint
6. logs: <where, read-only command>

## Safe-fix rules (Phase ≥ 2)
- ≤ 3 files, no migrations, no auth/payment/deletion paths, no prod config, no deps added.
- worktree: `git worktree add ../<repo>-incident-<short> -b incident/<short> <base_branch>`

## Report sink + notify
- report_sink: <state-store comment | PR body | incidents/<id>.md>
- notify: <webhook env NAME | chat channel | none>
- pr: open draft PR against <base_branch> — yes/no (Phase ≥ 2 only)

## Limits
- max_turns: 40   max_runtime: 20m   max_cost: <owner sets>

## Deny list (proposed for .claude/settings.json — applied by a human)
```json
{ "permissions": { "deny": [ "Bash(git push*)", "Bash(git merge*)", "<deploy cmd>*", "<migrate cmd>*" ] } }
```

## Gaps found at init
- …
