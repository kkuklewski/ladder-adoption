# Gate 1 → 2: from Assisted to Parallel

Source row: *Run more than one agent at a time; a self-verification loop you trust (tests +
build + lint + e2e testing with a real dev environment); auto mode, to avoid blocking
permission prompts; automate code review.*

Four items in the source, so four groups. A group passes only when every `required` check
in it is `verified`. Unknown self-reports do not pass a group.

## A. More than one agent at a time
| id | check | kind | pass when | required |
|---|---|---|---|---|
| 2.A1 | Worktree isolation is the documented way of working | inspect | CLAUDE.md, a skill, or a command tells Claude to work in a worktree (or cloud sessions are the documented default). `repo.worktrees` ≥ 2 alone is `assumed`: a worktree created by the run being scored, or one left over from a single task, is not a habit | yes |
| 2.A2 | The human has run ≥ 2 sessions in parallel on this repo | self-report | yes | no |

## B. A self-verification loop you trust
| id | check | kind | pass when | required |
|---|---|---|---|---|
| 2.B1 | lint command exists | probe | `repo.scripts` has `lint` (or Makefile/pyproject equivalent) | yes |
| 2.B2 | typecheck command exists | probe | `repo.scripts` has `typecheck`/`tsc`, or `tsconfig.json` + a script that runs `tsc --noEmit`; for untyped stacks, `not_applicable` | yes |
| 2.B3 | unit tests exist and a command runs them | probe | `repo.scripts` has `test` **and** a test config in `repo.test_configs` | yes |
| 2.B4 | build command exists | probe | `repo.scripts` has `build` | yes |
| 2.B5 | e2e tests exist against a real dev environment | probe | `playwright`/`cypress` (or equivalent) in `repo.test_configs` **and** a script runs them | yes |
| 2.B6 | Claude is told to run the loop before reporting | inspect | CLAUDE.md or a skill says "run lint/typecheck/tests/build before finishing" | yes |
| 2.B7 | The loop runs on every change, not only when remembered | probe | `repo.ci.runs_tests` **or** `repo.precommit_hooks` | yes |
| 2.B8 | The human trusts the loop enough to skip reading every diff | self-report | yes | no |

## C. Auto mode, no blocking permission prompts
| id | check | kind | pass when | required |
|---|---|---|---|---|
| 2.C1 | The verification loop and read-only git are pre-approved | inspect | allow rules (repo or global) cover the repo's lint/typecheck/test/build commands **and** `git status`/`git diff`/`git log`. Count alone is not evidence: a long list of one-off approvals (`Bash(cat:*)`, single MCP reads) is `assumed` at best | yes |
| 2.C2 | Dangerous commands are denied explicitly | probe | `deny_rules` ≥ 1 covering deploy/push/migrate for this repo | yes |
| 2.C3 | Auto mode (or an equivalent non-blocking default) is the norm | probe | `machine.global.default_mode` is `auto` (or `acceptEdits` with a deny list). **`auto` and `bypassPermissions` are ignored in project and local settings** (Claude Code ≥ 2.1.257), so a repo-level `defaultMode: "auto"` is `misplaced`, not `verified`. Shift+Tab toggling is not saved anywhere; if nothing is set, ask the human. A self-reported yes with no `defaultMode` in `~/.claude/settings.json` is `assumed`, not `verified`: the next session starts in the default mode. | yes |

## D. Automated code review
| id | check | kind | pass when | required |
|---|---|---|---|---|
| 2.D1 | Code review runs on every PR without a human starting it | probe | `repo.ci.claude_review` **or** another review bot in `repo.ci.workflows` | yes |
| 2.D2 | Security review runs automatically | probe | `repo.ci.security_scan` | yes |
| 2.D3 | Human review still gates merge (same bar as human code) | inspect | branch protection or documented PR policy | yes |

When proposing the next action for group C: the mode goes in `~/.claude/settings.json`,
the allow/deny rules go in the repo's committed `.claude/settings.json`. Never propose
`defaultMode: "auto"` inside the repo; Claude Code will not honour it there.

**Step 2 is reached when groups A–D all pass.** Report each group as `pass / partial / fail`
with the failing ids listed; the score line is `groups passed / 4`.
