# Unattended runs: headless, routines, cloud sessions

Lessons from real overnight runs. Both skills follow them whenever no human is watching:
`claude -p`, a cloud routine, a scheduled task, an eval, or a session started by a trigger.

Two companions: `cloud-environment.md` for what a cloud session actually has, and
`false-greens.md` for the ways a run reports success without doing the work.

## Check the environment before following any procedure

Run `scripts/cloud-probe.sh` first and put its output in the report. A procedure written
against tools that are not installed fails on its first command; the probe turns that into
a fact you can route around instead of a dead run. In particular **`gh` was absent** from
every cloud session observed so far.

## Never block on a question

- There is nobody to answer. Do not ask in a tool and do not end on a question in plain text.
  Record what you would have asked as `unknown` and finish the deliverable.
- A tool that is outside the run's allowed list stops the run at a permission prompt until
  someone clicks, often all night. In routines the allowed list is fixed when the routine
  is created. Use only the tools you were given.

## Waiting for CI

- **Pick the channel from what the probe found, not from habit.** `gh run watch <run-id>
  --exit-status` waits without polling, but only where `gh` exists and is authenticated —
  which excludes every cloud session seen so far. Otherwise use the session's pull-request
  subscription, or the GitHub MCP tools if the session has them.
- If no channel can wait, say so and report the run id instead of inventing a polling loop.
  An unfinished check is a fact worth reporting; a fabricated result is not.
- Do not use `Monitor` or chains of `sleep` unless the run explicitly allows them.
- A red job is not automatically a broken workflow. Read the log before retrying: a job
  that fails on real findings (an audit, a scan that cannot upload) is a result to report,
  not a fix to attempt. Retries are for workflow-definition mistakes, at most 3.

## What exists in a cloud session

The full list, with how each fact was established, is in `cloud-environment.md`. The three
that change how a procedure is written:

- **Only what is committed to the repository.** User-level skills, commands, agents,
  plugins and MCP servers stay on the laptop.
- **Dependencies are not installed.** A SessionStart hook that runs only in the cloud:
  `[ "$CLAUDE_CODE_REMOTE" != "true" ] || npm ci`. Hooks that call local-only services (a
  private task tracker, a desktop app) must skip the other way round:
  `[ "$CLAUDE_CODE_REMOTE" = "true" ] || <hook command>`.
- **The repository's own permission rules apply.** A committed `ask` or `deny` rule is
  enforced in the cloud, and `ask` with nobody to ask means refused. A cloud session clones
  the default branch, so it gets the current rules — the checkout most likely to be missing
  them is the human's laptop, not the agent's.

## Pushing your branch

Do not assume a push will be allowed. In the first observed cloud run the agent did the
whole task correctly and then could not push, because the repository's `ask` rule covered
**every** push, not just one to the default branch — a guardrail written to protect
production, blocking the only output the agent was asked to produce.

- **Push by literal branch name**: `git push -u origin <name>`. A bare push, `HEAD`, or a
  name in a variable gives a guard no way to tell where the push is going, and a guard that
  cannot tell must refuse.
- **If the push is refused, stop and report it as `blocked`**, naming the exact command and
  the rule. Do not reshape the command to get past the rule.
- A permission rule is a fuse, not a lock. Where the git host offers branch protection or a
  ruleset on the default branch, that is the protection to rely on; command patterns are
  read as text and can be worked around by syntax nobody anticipated.

## Scope and stopping

- Touch only what the task names. Never merge, deploy, run migrations against a real
  database, or change repository settings.
- Stop and report when a step needs a secret, a settings or billing change, or a decision
  about product behaviour.
- End with a short report: what changed, local and CI results, what is still open, and the
  one decision the human has to make. Correct an earlier wrong claim explicitly.

## Report numbers, not check marks

`false-greens.md` catalogues ten ways a run reports success while doing nothing. The rule
that follows from all of them:

- **Name the number that proves it.** A green check is a claim; turns taken, permission
  denials, and the artifact visible from outside the run are evidence.
- **Say `UNVERIFIED` and what is missing** when no number exists. Never round an unknown up
  to "done".
- **Prove a new test can fail** before trusting it: break the branch it covers, watch it go
  red, restore, and say in the report what was broken.
