---
scope_version: 1
generated: <YYYY-MM-DD>
plugin: ladder-adoption <plugin version from plugin.json>
run: <attended | headless>
answered: <n>/10
work: <backlog-prs, maintenance, digest, incident-triage | unknown>
forbidden: <production-database, production-hosts, third-party-automations, personal-data, paths… | unknown>
queue: <repo-issues | external:<name> | repo-file | none | unknown>
queue_reachable_from_cloud: <yes | no | unknown>
default_branch_push: <nothing | ci-only | deploys-to-production | unknown>
protect_default_branch: <available | unavailable-on-this-tier | in-place | unknown>
host_tier: <free | paid | unknown>
claude_tier: <individual | team | unknown>
auto_merge: <forbidden | allowed-for:<class> | unknown>
data_access: <none | redacted | full | unknown>
runs_per_night: <n | unbounded | unknown>
turn_budget: <n | unbounded | unknown>
notify: <channel name, verified | channel name, untested | none | unknown>
local_only_dependencies: <none | named… | unknown>
---
# Scope — <repo name>

Answers to the ten questions in `scope-interview.md`. They are the user's, not the
skill's: every later run keeps them, and a headless run never overwrites one with
`unknown`. Edit them by hand when the project changes.

## What agents do unattended
<answer, one or two lines>

## What they must never touch
<list, one per line, each as a constraint a rule or prompt can be checked against>

## Blast radius
- **A commit on the default branch:** <answer>
- **Branch protection on this tier:** <available / unavailable / already in place>
- **Merging:** <who, and whether anything is automatic>
- **Production data:** <none / redacted / full>

## Budget and alarm
- **Per night:** <runs, turns, minutes>
- **Failures reported to:** <channel> — <verified working | never tested | none>

## Environment
- **Queue:** <where tasks live> — reachable from a fresh cloud checkout: <yes | no | unknown>
- **Local-only dependencies:** <named, or none>

## Constraints this creates
| constraint | value | phases that must honour it |
|---|---|---|
| <key from the frontmatter> | <value> | <phase numbers> |

## Unanswered
<ids and questions still `unknown`, and what each one blocks; or "none">
