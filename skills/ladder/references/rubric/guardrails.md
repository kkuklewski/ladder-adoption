# Guardrails axis

Source: the *Guardrails* column of Cherny's table. Scored separately from the gates: a
repo can pass a gate's capability checks and still fail its guardrails, and the report
must say so. Right-edge text was cut in the source export; those lines end with
`[truncated in source]` and are scored as written.

Check kinds: `probe` = decided from `probe.sh` output · `inspect` = Claude reads the named
file and judges · `self-report` = not observable on disk; ask the human once, else `unknown`.

## Step 0 → 1 guardrails
| id | check | kind | evidence |
|---|---|---|---|
| G0.1 | SSO/SCIM plus role-based access | self-report | org setting |
| G0.2 | Org-level budget cap `[truncated in source]` | self-report | org setting |
| G0.3 | Deploy inside existing approvals/IAM | self-report | org setting |
| G0.4 | Data governance pa… `[truncated in source]` | self-report | org setting |

## Step 1 guardrails
| id | check | kind | evidence |
|---|---|---|---|
| G1.1 | Per-seat spend caps | self-report | org/team setting |
| G1.2 | Centrally managed model/effort setting | probe | `machine.global.settings_json` has `model`; managed settings present |
| G1.3 | Centrally managed p… `[truncated in source]` (permissions) | probe | `allow_rules`/`deny_rules` > 0 in global or repo settings |
| G1.4 | OpenTelemetry export to existing SIEM/observability stack | self-report | env `CLAUDE_CODE_ENABLE_TELEMETRY` or OTel exporter configured |

## Step 2 guardrails
| id | check | kind | evidence |
|---|---|---|---|
| G2.1 | Analytics to monitor usage | self-report | analytics dashboard or API in use |
| G2.2 | Automatic code-quality enforcement: lint, automated tests, typecheck | probe | `repo.scripts` has lint+typecheck+test **and** `repo.ci.runs_tests` or `repo.precommit_hooks` |
| G2.3 | Claude-powered end-to-end verification (Chrome extension, iOS/Android simulators) | inspect | e2e config present and a skill/CLAUDE.md instruction tells Claude to run it |
| G2.4 | Manual code review, merge, and security review hold the same quality bar for human and agent-generated code | inspect | branch protection / PR template / CONTRIBUTING says agent PRs get the same review |
| G2.5 | Pre-approve common bash and MCP commands in `settings.json` | probe | `allow_rules` > 0 in repo `.claude/settings*.json` |

## Step 3 guardrails
| id | check | kind | evidence |
|---|---|---|---|
| G3.1 | Automatic code review `[truncated in source]` | probe | `repo.ci.claude_review` or a review action on PR |
| G3.2 | Automatic security review | probe | `repo.ci.security_scan` |
| G3.3 | Agent sandboxing | probe | `machine.global.sandbox_configured` or repo settings `sandbox` |
| G3.4 | CLAUDE.md and Skills encode standards | inspect | `repo.claude_md` non-empty **and** `dot_claude.skills` non-empty, content states conventions not history |
| G3.5 | Tune auto-mode classifier based on your team `[truncated in source]` | self-report | — |
| G3.6 | Manage token use: model selection, advisors, breaking up CLAUDE.md, lazy Skills | inspect | no CLAUDE.md > ~200 lines; skills used instead of one huge CLAUDE.md; model set per task |

## Step 4 guardrails
| id | check | kind | evidence |
|---|---|---|---|
| G4.1 | Cost controls for automation `[truncated in source]` | self-report | — |
| G4.2 | Model selection for automated agents `[truncated in source]` | self-report | — |
