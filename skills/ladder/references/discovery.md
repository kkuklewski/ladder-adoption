# Discovery — the blank sheet

The skill knows nothing about the user, the machine, or the project. Everything below is
**where to look**, never what to expect. Every finding is tagged:

- `verified` — seen in a file or in command output during this run
- `assumed` — inferred from a name, a convention, or an older profile
- `unknown` — could not be observed; a `self-report` check the human has not answered

Never silently upgrade `assumed` to `verified`.

## 1. Run the probe (deterministic, read-only)

```bash
bash "<plugin-root>/skills/ladder/scripts/probe.sh" <repo-path>
```

`<plugin-root>` is the directory this SKILL.md lives in, two levels up from `references/`.
The script prints one JSON document with `machine` and `repo` sections. It reads only:
`~/.claude/*`, `~/.claude.json` (MCP server **names**), the repo's `.claude/`, `.mcp.json`,
manifests, test configs, `.github/workflows`, git metadata. It never prints secret values
and never writes.

If it fails (no bash, no git): say so, then perform section 2 manually with `ls`, `cat`,
`git`, and tag everything `assumed` unless you saw the file.

## 2. What the probe covers, and what only you can judge

| Area | Probe field | You still inspect |
|---|---|---|
| Machine | `os`, `claude_version`, `clis`, `gh_authenticated` | nothing |
| Global Claude config | `global.settings_json`, `allow/deny_rules`, `hooks_events`, `sandbox_configured`, `skills`, `agents`, `commands`, `rules`, `mcp_servers`, `plugins` | whether any of those skills/rules apply to *this* repo |
| Repo identity | `remote`, `default_branch`, `worktrees`, `branches`, `commits_30d`, `merges_30d`, `claude_sessions_on_this_machine` | activity level; whether the repo is on GitHub (cloud routines need that) |
| Claude context in repo | `claude_md` (path:lines), `agents_md`, `dot_claude.*`, `mcp_servers` | read every CLAUDE.md: does it state conventions and pointers (good) or narrate history (noise)? Is any > ~200 lines (candidate for splitting into skills)? |
| Verification | `scripts`, `test_configs`, `ci.*`, `precommit_hooks` | map script names to lint / typecheck / unit / e2e / build; a script that exists but references a missing config is `assumed` |
| Deploy and blast radius | `deploy_files`, `migration_dirs`, `env_files`, `env_gitignored` | which command would deploy or migrate; those belong on a deny list |
| Knowledge beyond code | `docs_dirs`, `mcp_servers` | is there a stated lookup order or decisions folder? |
| Existing ladder state | `dot_claude.ladder_profile`, `incident_profile` | diff against the previous profile instead of overwriting |

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

Kind `ask-then-verify`: a local path is checked with `ls` and recorded `verified`; a URL or
repo is recorded `assumed`; `none` is recorded as such. The answer is stored as
`knowledge_base` in `.claude/ladder-profile.md` and never asked again unless the path stops
existing. Other skills in this plugin read it from the profile instead of asking.
