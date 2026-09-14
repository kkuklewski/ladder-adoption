# Gate 2 → 3: from Parallel to Supervised autonomy

Source row: *Give Claude a way to pull in context (let Claude read code, wikis, discussions);
agency and code-review speed (agents may touch code owned by other teams); break up your
work into loops and routines; let Claude kick off Claude.*

Only score this gate when gate 1→2 passes. Otherwise list it as `locked` and show the
items anyway, so the human sees what is coming.

## A. Context retrieval
| id | check | kind | pass when | required |
|---|---|---|---|---|
| 3.A1 | CLAUDE.md exists and states conventions, not history | inspect | `repo.claude_md` non-empty; content is rules and pointers | yes |
| 3.A2 | Skills encode repeatable procedures | probe | `repo.dot_claude.skills` or plugin skills relevant to the repo ≥ 1 | yes |
| 3.A3 | Claude can read the team's knowledge beyond the repo (wiki, docs, discussions) | probe | `repo.mcp_servers` or `machine.global.mcp_servers` includes a docs/wiki/issue source, **or** `repo.docs_dirs` non-empty and CLAUDE.md points to it | yes |
| 3.A4 | Source-of-truth vs notes is distinguishable | inspect | docs or vault has a stated lookup order / decisions folder | no |
| 3.A5 | Where is the knowledge base (second brain, vault, wiki, docs repo)? | ask-then-verify | human gives a path, repo, or URL, **or** `none`; a local path is checked with `ls` and becomes `verified`; stored as `knowledge_base` in the profile and reused by every other skill | no |

## B. Agency and review speed
| id | check | kind | pass when | required |
|---|---|---|---|---|
| 3.B1 | Agents may open PRs across the codebase, not one owner's corner | self-report | yes | no |
| 3.B2 | Review turnaround is measured or bounded | self-report | yes | no |
| 3.B3 | Agent-generated PRs are labelled or identifiable | inspect | PR template / commit trailer convention | no |

## C. Loops and routines
| id | check | kind | pass when | required |
|---|---|---|---|---|
| 3.C1 | At least one recurring task is defined as a routine, `/loop`, scheduled task, or cron | probe | scheduled task/routine config referencing this repo, or a skill documents the loop | yes |
| 3.C2 | Repetitive work is split into batchable units | inspect | a skill or command takes a list and fans out | no |
| 3.C3 | Stop conditions exist (max turns, cost, runtime) | inspect | documented in the routine, skill, or profile | yes |

## D. Claude kicks off Claude
| id | check | kind | pass when | required |
|---|---|---|---|---|
| 3.D1 | An external event can start a session without a human (webhook → routine, `claude -p` on a trigger, Claude Tag on a channel) | inspect | trigger config or a documented, tested trigger path | yes |
| 3.D2 | One agent per event is guaranteed (dedupe / idempotency) | inspect | state store + fingerprint, or equivalent | yes |
| 3.D3 | Subagents are used for isolated sub-tasks | probe | `repo.dot_claude.agents` or `machine.global.agents` non-empty, or Explore/worktree subagents referenced in skills | no |
| 3.D4 | Every automated run ends in a human-readable report with a recommended action | inspect | report template exists and is used | yes |

**Step 3 is reached when A, C, D pass and B is at least `partial`.** The incident-response
skill in this plugin is one concrete way to earn C and D.
