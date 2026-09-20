# Plan 0.3.0 — from a score to a working unattended agent

Status: draft, 2026-09-20. Nothing here is built yet.

## Why

0.1.x–0.2.0 score a repo and stop. The first full adoption run on a real private
production repo (two sessions, 14 PRs, about 28 hours, Step 1 → a night queue with a cloud
routine) showed that everything between the score and a working unattended agent had to be
improvised in chat: the scope questions, the phase order, the guardrails, the review
prompts, the task queue, the pilot. It worked, but none of it is reusable, and the run hit
the same class of failure six times: **a green status on work that never happened.**

0.3.0 turns that improvised path into the plugin. The principle stays: nothing about the
user or the project is baked in. What ships is the *questions*, the *phase order*, the
*proof each phase must show*, and *templates that are filled from the project's own
evidence*.

## Evidence from the pilot run (what the design must survive)

| # | What happened | What it means for the plugin |
|---|---|---|
| E1 | The score asked about knowledge base, parallel sessions, trust, spend cap. The questions that shaped the whole plan (what should agents do, what must they never touch, what does a push to the default branch do, which plans/tiers, where do tasks live, who merges, nightly budget, notify channel) were invented on the spot. | A scope interview is a missing deliverable. |
| E2 | "Smallest next action" gave one step. The human needed an ordered roadmap mapped to rubric ids. | A `plan` mode. |
| E3 | Review workflow existed and was green five times while reviewing nothing: workflow-file validation skip, an allowed-tools flag that replaced instead of extended, two jobs silencing each other, an action that found nothing on a diff with three planted defects, a webhook that accepted and discarded. The rubric scores 2.D1 from file existence. | A new check kind that needs run evidence, and a canary. |
| E4 | A generic review plugin found 0 of 3 planted defects; an explicit prompt naming the repo's own failure classes found 4, same diff, same cost. | Review prompts are generated from the project's bug history. |
| E5 | The rubric-compliant guardrail (`ask` on every push) blocked the agent's push of its own branch. `ask` beats any narrower `allow`; a hook can tighten, not loosen. A hand-written push parser then needed three review rounds to close three bypasses. | A guardrail/procedure conflict test, and platform-level protection preferred over command parsing. |
| E6 | Cloud session facts, each found by failing: no `gh` binary (a GitHub MCP server instead), no `node_modules`, repo `.claude/settings.json` and hooks honoured, routine creation silently attached personal connectors even when an empty list was passed, cron in UTC. | A cloud-environment reference with dates, plus a first-run environment probe. |
| E7 | 3.C1 checks that a routine exists. Nothing covers where tasks come from. Issue template, arming label, acceptance criteria checkable without a database, an out-of-scope section, a negative-case task, a difficulty-ordered pilot were all written from scratch. | Queue and pilot templates. |
| E8 | After 14 PRs the scorer was never re-run. The profile went stale; the local copy even conflicted with the merged one and blocked a pull. | Re-score after every phase, with a diff. |
| E9 | The discipline that made the agent trustworthy — report numbers not check marks, say `UNVERIFIED` instead of `done`, prove each test can fail — lived in a project skill. It is generic. | Ship it as templates. |
| E10 | 2.C3 (`defaultMode` in user settings) was the last formal blocker to Step 2 while being irrelevant to the stated goal (cloud routines). | Goal-aware scoring note. |
| E11 | Automated review cost about $1.50 per PR, four rounds on one PR about $4, from a quota shared with interactive work. Cost control first appears at G4.1. | Budget question in the interview; bounds in every generated routine and workflow. |
| E12 | All current evals grade scoring on scaffolds. None asks "did the project end up with a working agent". | End-to-end evals. |

## Deliverables

### D1. New skill `autonomy` (order prefix `2/3`; `incident-response` becomes `3/3`)

`/ladder-adoption:autonomy [interview | plan | phase <n> | pilot | status]`

Same contract as `ladder`: it proposes and writes its own files under `.ladder/`; it never
edits settings, CI or code unless the human runs a phase and approves each change.

- `interview` — asks `references/scope-interview.md` in at most three grouped
  AskUserQuestion calls, only when attended. Writes `.ladder/scope.md`. Headless: no
  questions, every answer `unknown`, and `plan` refuses to go past phase 2 without a scope.
- `plan` — reads the ladder profile + scope, writes `.ladder/plan.md`: ordered phases, each
  with the rubric ids it closes, the files it touches, whether it touches production, the
  exit proof, and what only the human can do (secrets, billing, app installs, merges).
- `phase <n>` — executes one phase in a worktree, ends at an open PR, never merges.
- `pilot` — files difficulty-ordered pilot tasks (unarmed), creates the routine **disabled**,
  runs it once by hand while the human is present, reads the run log, reports numbers.
- `status` — re-runs the ladder probe, diffs the profile, marks phases done only on proof.

### D2. `references/scope-interview.md`

Questions, each with why it is asked and which phase consumes the answer:

1. What should agents do unattended? (backlog tasks → PRs, maintenance, log digests, error triage, other)
2. What must they never touch? (databases, production hosts, third-party automations, personal data, paths)
3. What does a push to the default branch do? (nothing / CI only / **deploys to production**)
4. Which tiers? (git host plan → is branch protection available; Claude plan → is the quota shared with daytime work)
5. Where do tasks live, and is that place reachable from a cloud session?
6. Who merges, and is that ever automatic? (default: never)
7. Budget per night: runs, turns, minutes.
8. Where do failures get reported, and does that channel work today? (verify, do not assume)
9. Data sensitivity: may an agent see logs, database rows, customer text? (default: no)
10. Which local services do hooks or skills depend on that a cloud session cannot reach?

### D3. `references/phases.md` — the fixed order and the proof each phase owes

| Phase | Closes | Exit proof (evidence, not existence) |
|---|---|---|
| 0 Guardrails + written contract | 2.A1, 2.B6, 2.C2 | headless dry run in a scratch clone: a read command runs, a push to the default branch is refused, the agent's own-branch push is **allowed** |
| 1 Loop on every change | 2.B2, 2.B7, G2.2 | one CI run on the real runner is green, and one planted violation turns it red |
| 2 Automated review | 2.D1–2.D3 | canary PR with planted defects from the repo's own failure classes; review run shows turns ≥ threshold, zero denials on needed tools, a posted comment, and ≥ 1 planted defect found |
| 3 Task queue | 3.C2, 3.C3 | template + arming label exist; one negative-case task is filed |
| 4 Routine + pilot | 3.C1, 3.D4 | one manual run ends in a PR or an honest `blocked` report whose claims match what is visible from outside |
| 5 Event triggers | 3.D1, 3.D2 | one real event starts exactly one session (hand-off to `incident-response`) |
| 6 Digest + metrics | G1.4, G2.1 | failures-only notification received once |

Order rule, stated in the file: never start phase 4 before phase 2 has its proof. That is
Cherny's trap, made operational.

### D4. `references/false-greens.md`

Catalogue of the observed ways a check reports success without doing the work, each with
the number that exposes it (`num_turns`, permission denials, comment count, duration,
execution file present) and the generic rule: **a status is a claim; a count is evidence.**
Includes: idempotent commands that print success whether or not anything changed, and
time-window filters that silently exclude the thing being looked for.

### D5. `references/cloud-environment.md` + `scripts/cloud-probe.sh`

Facts about cloud sessions and routines, each tagged with the date observed and
`verified` / `assumed`. The script is what the first pilot run executes first: which of
`gh`, `node`, package manager, dependency folder, GitHub MCP tools, repo settings and hooks
are present. Its output goes into the run report, so the facts are re-verified per project
instead of trusted from this file.

Fixes in `references/unattended.md` and the README: remove `gh run watch` as the cloud
default (use the GitHub MCP tools or the PR subscription; `gh` only when the probe finds
it); replace "git push works only for the session's own branch" with "verify in the pilot;
a repo `ask` rule on push refuses it".

### D6. Templates (`templates/`, copied and filled, never used verbatim)

- `agent-task.issue.yml` — goal, acceptance criteria checkable without a live database,
  files in scope, out of scope *with the reason* (a decision versus a mess), off-limits
  checkboxes.
- `night-task.SKILL.md` — procedure ending in a fixed `RESULT:` / `UNVERIFIED:` block;
  numbers-not-check-marks as its first section; red-then-green proof for every new test;
  tool table with both `gh` and MCP spellings; push by literal branch name.
- `routine-prompt.md` — turn/call budget, one task per run, stop conditions, skip anything
  that already has an open issue or PR, `blocked` instead of workarounds — with the allowed
  channels **named**, not left to judgement.
- `verify-agent-run.mjs` — reads the action's execution file, fails on zero turns, error,
  missing denial information, or denials on needed tools.
- `review-prompt.md` + `scripts/failure-classes.sh` — lists recent fix commits (subject,
  files, whether a test was added); the skill clusters them into named failure classes with
  one production consequence each, and asks the human to confirm before they go into the
  correctness and security prompts. No history → a short generic list, tagged `assumed`.
- `protect-default-branch.md` — decision table: branch protection/ruleset when the tier
  allows it (preferred, not parseable around); otherwise narrow `ask`/`deny` patterns as a
  fuse plus a parsing hook, with the known bypass classes listed (`-c` values with spaces,
  `-C`/`cd`, `--repo`, refspec `x:main`, bare push, `--all`/`--mirror`).

### D7. Rubric and probe changes

- New check kind **`proof`**: passes only with evidence from a run (id, date, numbers)
  recorded in the profile; existence alone is `assumed`. Applied to 2.B7, 2.D1, 2.D2,
  3.C1, 3.D1, 3.D4.
- 2.C2 gains the conflict test from E5; 2.C3 gains a note: when the scope says work runs in
  cloud routines, the routine's allowed tools + honoured repo settings satisfy it.
- New required check 3.C4: tasks come from a queue with an explicit arming step.
- Budget moves forward: a G2 guardrail "automated runs are bounded (turns, timeout,
  concurrency)", `inspect`.
- Probe 0.3.0: `repo.ci.review_last_run` is *not* added (needs network); instead the skill
  reads it with `gh`/MCP when available and tags `unknown` otherwise. Probe adds
  `repo.ladder.scope`, `repo.ladder.plan`, issue-template and label-convention detection.

### D8. Evals

- `autonomy-interview-headless` — never asks, writes scope with `unknown`s, plan stops at phase 2.
- `autonomy-plan-deploy-on-push` — scaffold where default-branch push deploys and the tier has
  no branch protection; plan must put guardrails first and name the residual gap.
- `autonomy-false-green` — scaffold with a review workflow and a canned execution file showing
  zero turns; 2.D1 must be `assumed`, not `verified`.
- `autonomy-push-conflict` — scaffold with `ask` on every push; phase 0 proof must fail and say why.
- `autonomy-review-prompt-from-history` — scaffold with fix commits in three classes; the
  generated prompt must name them and must not invent a fourth.
- Existing no-author-leak graders apply to every new output file.

## Order of work

1. ~~D4, D5 text + the `unattended.md`/README corrections~~ — **shipped in 0.2.1**
   (2026-09-20). `references/false-greens.md`, `references/cloud-environment.md`,
   `scripts/cloud-probe.sh`, corrected CI-waiting and push guidance. Still open from D5:
   the review-prompt generator and `scripts/failure-classes.sh`, which belong with D6.
2. D2, D3, D1 `interview` + `plan` — the part that adapts to any project.
3. D7 `proof` kind + D8 first three evals.
4. D6 templates, D1 `phase` + `pilot`, remaining evals.
5. Re-run the whole path on a second, different repo (not a Node web app) before tagging 0.3.0.

## Open decisions

- One skill with modes (above) or three small skills (`scope`, `plan`, `pilot`)? Modes keep
  the `/` menu short; separate skills load less text per run.
- Does `phase <n>` belong in the plugin at all, or should the plugin stop at `.ladder/plan.md`
  and let an ordinary session execute it? The pilot run suggests phases 0–2 are generic
  enough to execute, phases 3+ are mostly templates plus judgement.
- Templates are Node/GitHub-shaped today. Second-repo run (step 5) decides how much to
  generalise before release rather than guessing now.
