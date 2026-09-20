# What a cloud session actually has

A cloud routine does not run on the laptop that created it. Every assumption carried over
from an interactive session has to be checked, and most of the entries below were found by
a run failing, not by reading documentation.

**Treat this file as a starting hypothesis, never as the answer.** Environments change and
differ per account and per repository. The first unattended run in a new project runs
`scripts/cloud-probe.sh` and reports what it found; that output, not this page, is what the
run relies on.

Each row says when it was observed and how strongly. `verified` = seen directly in a run
log. `assumed` = inferred from one observation, or seen in a tool list without being called.

## The environment

| Fact | Status | Observed |
|---|---|---|
| The `gh` CLI is **not installed**. `which gh` exits 127. | verified | 2026-09-20 |
| A GitHub MCP server is available instead; `mcp__github__list_issues` worked. | verified | 2026-09-20 |
| Other `mcp__github__*` tools (issue write, list pull requests, create PR) appear in the tool list. Names and argument shapes are not confirmed by a call. | assumed | 2026-09-20 |
| Dependencies are **not** installed: no `node_modules`. The run has to install them. | verified | 2026-09-20 |
| The repo's committed `.claude/settings.json` **is honoured**, including `ask` and `deny` permission rules and hooks. | verified | 2026-09-20 |
| `CLAUDE_CODE_REMOTE=true` in the environment, so hooks and scripts can tell cloud from laptop. | verified | 2026-09-20 |
| The session starts on the repository's default branch, on a fresh clone. | verified | 2026-09-20 |
| Routine environment variables are empty unless the routine sets them: no secrets, no tokens. | verified | 2026-09-20 |
| Creating a routine through the API **silently attaches the account's personal MCP connectors** (mail, calendar and whatever else is connected). Passing an empty connector list at creation does not prevent it; it is read as "not specified". A separate update that explicitly clears them does, and the result must be read back to confirm. | verified | 2026-09-20 |
| Routine cron expressions are evaluated in **UTC**. A local-time schedule shifts by an hour at every daylight-saving change. | verified | 2026-09-20 |
| Only what is committed to the repository exists. User-level skills, commands, agents, plugins and MCP servers stay on the laptop. | verified | 2026-09-14 |
| Whether a cloud session loads a project skill through the Skill tool, rather than only by reading the file, is untested. | unknown | — |

## What follows from it

- **Write procedures in terms of a capability, not a binary.** "Read the queue" and then a
  table of the ways to do it: `gh issue list`, the GitHub MCP tool, the API. A procedure
  written entirely in `gh` commands is a procedure that cannot run in the cloud.
- **State which channels are allowed, by name.** A rule like "if the usual tool is missing,
  do not work around it" has to say what counts as a workaround. An official connector is
  not a stolen token, and an agent left to judge that distinction at 3am will judge it —
  possibly correctly, possibly not. Either outcome is a rule that failed to decide.
- **Install dependencies inside the run**, guarded so it only fires in the cloud:
  `[ "$CLAUDE_CODE_REMOTE" != "true" ] || npm ci`.
- **Skip local-only services** in hooks: `[ "$CLAUDE_CODE_REMOTE" = "true" ] || <hook command>`.
- **Verify connectors after creating a routine.** Read the routine back and check the
  connector list is empty. An unattended agent whose contract is "produce a pull request"
  should not also hold the account's mailbox.
- **Set cron in UTC deliberately** and write the local times, including both sides of a
  daylight-saving change, in the routine description.

## Enabling this plugin in a cloud session

Declare it in the repository's committed `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": { "ladder-adoption": { "source": { "source": "github", "repo": "kkuklewski/ladder-adoption" } } },
  "enabledPlugins": { "ladder-adoption@ladder-adoption": true }
}
```
