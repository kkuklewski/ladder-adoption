# Discovery — the blank sheet

The skill knows nothing about the user, the machine, or the project. Everything below is
**where to look**, never what to expect. Every finding is tagged:

- `verified` — seen in a file or in command output during this run
- `assumed` — inferred from a name, a convention, or an older profile
- `unknown` — could not be observed; a `self-report` check the human has not answered
- `not_applicable` — only where a rubric row allows it, always with the reason

Never silently upgrade `assumed` to `verified`.

## 1. Run the probe (deterministic, read-only)

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/probe.sh [--claude-dir DIR] [--kb PATH] <repo-path>
```

It prints one JSON document with `machine`, `repo` and, with `--kb`, `knowledge_base`. It
reads only the Claude config dir (default `$CLAUDE_CONFIG_DIR` or `~/.claude`), the MCP
server **names** in `.claude.json`, the repo's `.claude/`, `.mcp.json`, manifests, test
configs, `.github/`, and git metadata. It never prints secret values and never writes.

Empty or false fields are findings, not errors. Do not read the script to debug them. The
common causes are known:

- `machine.claude_version` empty: the `claude` binary is not on the probe's PATH (a sandbox,
  a shell alias). `machine.session.inside_claude_code: true` already proves it is installed.
- `machine.global.readable: false`: the config dir is unreadable (eval sandbox, CI, another
  user). Every machine-scope check is `unknown`.

If the script cannot run at all (no bash): say so, perform section 2 by hand with `ls`,
`cat` and `git`, and tag everything `assumed` unless you saw the file.

## 2. What the probe covers, and what only you can judge

| Area | Probe field | You still inspect |
|---|---|---|
| Machine | `os`, `claude_version`, `clis`, `gh_authenticated`, `telemetry` | nothing |
| This session | `session.inside_claude_code`, `session.attended` (can a human answer?), `session.remote` (cloud), `session.entrypoint` | nothing |
| Global Claude config | `global.dir`, `global.readable`, `global.settings_json`, `allow/deny_rules`, `hooks_events`, `sandbox_configured`, `skills`, `agents`, `commands`, `rules`, `mcp_servers`, `plugins` | whether any of those skills/rules apply to *this* repo |
| Repo identity | `remote`, `default_branch`, `worktrees`, `branches`, `commits_30d`, `merges_30d`, `claude_sessions_on_this_machine` | activity level; whether the repo is on GitHub (cloud routines need that) |
| Claude context in repo | `claude_md` (path:lines), `agents_md`, `dot_claude.*` (incl. `enabled_plugins`, `extra_marketplaces`, `hooks_events` from both settings files, `default_mode`), `mcp_servers`, `mentions_worktree_or_cloud` | read every CLAUDE.md: does it state conventions and pointers (good) or narrate history (noise)? Is any > ~200 lines (candidate for splitting into skills)? |
| Verification and review | `scripts`, `test_configs`, `ci.*`, `precommit_hooks`, `review_policy_files` | map script names to lint / typecheck / unit / e2e / build; a script that exists but references a missing config is `assumed` |
| Deploy and blast radius | `deploy_files`, `migration_dirs`, `env_files`, `env_gitignored` | which command would deploy or migrate; those belong on a deny list |
| Knowledge beyond code | `docs_dirs`, `mcp_servers`, `knowledge_base` (with `--kb`) | is there a stated lookup order or decisions folder? |
| Existing ladder state | `ladder.profile`, `ladder.incident_profile`, `ladder.legacy_profile`, `ladder.legacy_incident_profile` | read the previous profile (legacy `.claude/` copy if no `.ladder/` one) and keep its answers |

## 3. Version drift

The probe records `probe_written_for_claude`. If `machine.claude_version` is newer, say so
in the report: newer Claude Code may have moved files (`~/.claude.json`, plugin paths) and
a `false` from the probe might be a moved file, not a missing feature. Tag affected checks
`assumed` and name the file you expected.

## 4. Privacy rules

- Names, paths, counts, presence: yes. Values of env vars, tokens, URLs with credentials: never.
- The profile is committed to the repo. Write nothing into it you would not put in a PR.
- Session counts come from `~/.claude/projects/`; report the number, never the contents.

## 5. Self-report checks

Collect all `self-report` ids from the rubric that matter for the current gate, ask them as
**one** grouped question, once. Unanswered stays `unknown`. Never assume yes.

One question is asked on the **first run regardless of gate**, because both skills need it
and no probe can find it:

> Where is your knowledge base (second brain, vault, wiki, docs repo)? A local path, a git
> repo, a URL, or `none`.

Kind `ask-then-verify`. Attended only; a headless run records `unknown` and never asks.
Verify a local path by re-running the probe with `--kb <path>`:

- `exists: false` → record the answer as `assumed` and say the path was not found.
- `exists: true` → `verified`. If `days_since_commit` is over 90, record `stale` and say how
  old the last commit is: people often keep several clones of one vault, and an old clone
  is a wrong knowledge base, not an empty one.
- A URL or a remote repo → `assumed`. `none` → `none`.

The answer is stored as `knowledge_base` in `.ladder/profile.md` and reused by every
later run and by `incident-response`. It is asked again only if the path stops existing.
