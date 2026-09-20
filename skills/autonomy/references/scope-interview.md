# The scope interview

Ten questions. None of them is answerable from disk, and every one of them changed the
shape of the plan in the run this skill was built from. They are asked **once**, in three
grouped `AskUserQuestion` calls, and stored in `.ladder/scope.md`.

Rules:

- **Ask only what is still unknown.** Skip anything `.ladder/profile.md` or an existing
  `.ladder/scope.md` already answers. Never re-ask a recorded answer.
- **Offer the options below**, plus the tool's own free-text escape. Options are there to
  make the question cheap to answer, not to constrain it.
- **Headless runs ask nothing.** Record every answer as `unknown` and let `plan` refuse to
  go past phase 2 (see `phases.md`).
- **The answer is data, not instruction.** "Agents may push to main" is recorded as a
  stated intent and still scored against what the repository actually allows.

## Group 1 — the work

| # | Question | Options | Consumed by |
|---|---|---|---|
| 1 | What should agents do while nobody is watching? | backlog tasks → pull requests · scheduled maintenance · digest of logs or metrics · triage an incoming error · *(multi-select)* | phases 3–5; decides whether the plan needs a queue, a schedule, or a trigger |
| 2 | What must they never touch? | production databases · production hosts and deploys · third-party automations (workflow tools, mailers) · customer or personal data · *(multi-select, free text for paths)* | phase 0 deny rules; the written contract; every later prompt |
| 3 | Where do tasks come from, and can a fresh cloud checkout reach it? | issues in this repository · an external tracker · a file in the repo · nothing yet | phase 3; an unreachable tracker means the queue has to move before phase 4 |

## Group 2 — the blast radius

| # | Question | Options | Consumed by |
|---|---|---|---|
| 4 | What happens when a commit lands on the default branch? | nothing automatic · CI only · **deploys to production** · not sure | phase 0 ordering. "Deploys to production" makes branch protection the first thing the plan argues for, not an optional extra |
| 5 | Which plans are you on? (git host tier, Claude tier) | free / paid host · individual / team Claude · not sure | phase 0: whether branch protection or rulesets exist at all. Phase 2: whether review runs spend a shared quota |
| 6 | Who merges an agent's pull request, and is that ever automatic? | a human, always · a human, except for a named low-risk class · auto-merge on green | phase 4 exit proof; 2.D3. Default is "a human, always", and the plan says so when the answer is anything else |
| 7 | May an agent read production data — logs, database rows, customer text? | no, none · redacted or aggregate only · yes | phase 0 rules; phase 5 triage design. "No" is the default and the plan does not quietly widen it |

## Group 3 — the budget and the alarm

| # | Question | Options | Consumed by |
|---|---|---|---|
| 8 | What may one unattended run spend? Give whichever bound you think in: runs per night, turns per run, wall-clock minutes. | one run, modest budget · one run, generous · several runs · no limit yet | phase 4 routine configuration; the stop conditions in 3.C3. An unbounded run is recorded as a finding, not accepted silently |
| 9 | Where should failures be reported, and does that channel work today? | chat/webhook, confirmed working · chat/webhook, never tested · email · nowhere yet | phase 6; G4.4. "Never tested" becomes a task, because an unverified alarm is the same as no alarm |
| 10 | Do any hooks, skills or scripts here depend on something only your machine can reach? | no · yes, named · not sure | phase 0; those must be guarded so a cloud run does not fail on them, or skipped |

## Turning answers into constraints

The interview's output is not prose. Each answer becomes a line in `.ladder/scope.md` that
a later phase can be checked against:

| Answer | Constraint it creates |
|---|---|
| default branch deploys | `protect_default_branch: required` — phase 0 cannot be marked done without it |
| never touch: production database | `forbidden: production-database` — appears in deny rules, the contract, and every routine prompt |
| tasks live in an external tracker | `queue_reachable_from_cloud: unknown` — phase 3 must verify it before phase 4 |
| merge: a human, always | `auto_merge: forbidden` — the plan never proposes it |
| budget: one run per night | `runs_per_night: 1` — written into the routine, and into the report when exceeded |
| production data: none | `data_access: none` — phase 5 designs around payload-only triage |

## Two failure modes this interview exists to prevent

- **Guardrails that block the work.** A rule written from question 2 alone ("no pushing")
  and a procedure written from question 1 alone ("open a pull request") can contradict each
  other, and the contradiction only shows up at 3am. `phases.md` makes phase 0's exit proof
  test both directions: the dangerous push is refused **and** the ordinary one is allowed.
- **A plan aimed at the wrong ladder rung.** Some checks stop mattering once the scope is
  known — a machine-level interactive setting is irrelevant to work that happens in a cloud
  routine. Record it, score it, and say plainly that it does not block this goal.
