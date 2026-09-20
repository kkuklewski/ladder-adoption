# Gate 0 → 1: from Gated to Assisted

Source row: *Executive/buyer alignment and escalation of blockers; frameworks for launching
Claude securely.* Mostly organisational, so most checks are `self-report`. The one thing a
machine can prove is that Claude Code actually runs here.

| id | check | kind | pass when |
|---|---|---|---|
| 1.1 | Claude Code is installed and current | probe | `machine.claude_version` non-empty **or** `machine.session.inside_claude_code` is true (this skill is running inside it) |
| 1.2 | A supported model is approved for use | probe | `machine.session.inside_claude_code` is true (a model is serving this very session), or a `model` is set in Claude settings |
| 1.3 | Code produced with Claude can be hosted somewhere (a remote exists) | probe | `repo.is_git` and `repo.remote` non-empty |
| 1.4 | Someone technical owns the AI-tooling decision | self-report | human answers yes |
| 1.5 | Security/approval path exists for launching Claude on this codebase | self-report | human answers yes |

**Step 1 is reached when 1.1–1.3 are `verified`.** 1.4–1.5 are recorded, never blocking.
In the profile this gate is one group: `gate_groups: "G=pass"` or `"G=fail"`.
