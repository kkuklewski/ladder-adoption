# Gate 1 → 2: from Assisted to Parallel

Source row: *Run more than one agent at a time; a self-verification loop you trust (tests +
build + lint + e2e testing with a real dev environment); auto mode, to avoid blocking
permission prompts; automate code review.*

Four items in the source, so four groups. A group passes only when every `required` check
in it is `verified`. Unknown self-reports do not pass a group.

## A. More than one agent at a time
| id | check | kind | pass when | required |
|---|---|---|---|---|
| 2.A1 | Worktree isolation is used | probe | `repo.worktrees` ≥ 2 **or** a skill/CLAUDE.md instructs worktree use | yes |
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
| 2.C1 | Common commands are pre-approved | probe | `repo.dot_claude.allow_rules` ≥ 5 **or** `machine.global.allow_rules` ≥ 5 | yes |
| 2.C2 | Dangerous commands are denied explicitly | probe | `deny_rules` ≥ 1 covering deploy/push/migrate for this repo | yes |
| 2.C3 | Auto mode (or an equivalent non-blocking default) is the norm | probe | `default_mode` set in global or repo settings, or the human confirms auto mode is on | yes |

## D. Automated code review
| id | check | kind | pass when | required |
|---|---|---|---|---|
| 2.D1 | Code review runs on every PR without a human starting it | probe | `repo.ci.claude_review` **or** another review bot in `repo.ci.workflows` | yes |
| 2.D2 | Security review runs automatically | probe | `repo.ci.security_scan` | yes |
| 2.D3 | Human review still gates merge (same bar as human code) | inspect | branch protection or documented PR policy | yes |

**Step 2 is reached when groups A–D all pass.** Report each group as `pass / partial / fail`
with the failing ids listed; the score line is `groups passed / 4`.
