# Unattended runs: headless, routines, cloud sessions

Lessons from real overnight runs. Both skills follow them whenever no human is watching:
`claude -p`, a cloud routine, a scheduled task, an eval, or a session started by a trigger.

## Never block on a question

- There is nobody to answer. Do not ask in a tool and do not end on a question in plain text.
  Record what you would have asked as `unknown` and finish the deliverable.
- A tool that is outside the run's allowed list stops the run at a permission prompt until
  someone clicks, often all night. In routines the allowed list is fixed when the routine
  is created. Use only the tools you were given.

## Waiting for CI

- Use `gh run watch <run-id> --exit-status` in Bash, or the session's pull-request
  subscription where the cloud session offers one. Both wait without polling loops.
- Do not use `Monitor` or chains of `sleep` unless the run explicitly allows them.
- A red job is not automatically a broken workflow. Read the log before retrying: a job
  that fails on real findings (an audit, a scan that cannot upload) is a result to report,
  not a fix to attempt. Retries are for workflow-definition mistakes, at most 3.

## What exists in a cloud session

- Only what is committed to the repository. User-level skills, commands, agents, plugins
  and MCP servers stay on the laptop. Commit them to the repo's `.claude/`, or enable
  plugins in the repo's `.claude/settings.json`:

  ```json
  {
    "extraKnownMarketplaces": { "ladder-adoption": { "source": { "source": "github", "repo": "kkuklewski/ladder-adoption" } } },
    "enabledPlugins": { "ladder-adoption@ladder-adoption": true }
  }
  ```

- Dependencies are not installed. A SessionStart hook that runs only in the cloud:
  `[ "$CLAUDE_CODE_REMOTE" != "true" ] || npm ci`.
- Hooks that call local-only services (a tailnet task tracker, a desktop app) must skip in
  the cloud: `[ "$CLAUDE_CODE_REMOTE" = "true" ] || <hook command>`.
- `git push` works only for the session's own branch. That is the strongest protection of
  the default branch available on plans without branch protection.

## Scope and stopping

- Touch only what the task names. Never merge, deploy, run migrations against a real
  database, or change repository settings.
- Stop and report when a step needs a secret, a settings or billing change, or a decision
  about product behaviour.
- End with a short report: what changed, local and CI results, what is still open, and the
  one decision the human has to make. Correct an earlier wrong claim explicitly.
