# Gate 3 → 4: from Supervised autonomy to AI-native

Source row: *Scaled automation of domain-specific use cases (e.g. code migration, fuzzing,
feature-building, feedback remediation).*

Only scored when gate 2→3 passes. Otherwise `locked`.

| id | check | kind | pass when | required |
|---|---|---|---|---|
| 4.1 | At least one domain-specific automation runs end to end without a human starting it | inspect | routine/SDK job with a named use case (migration, fuzzing, feature-building, feedback remediation) | yes |
| 4.2 | Agents are built or scheduled programmatically (Agent SDK) | probe | SDK dependency in `repo.manifests` (`@anthropic-ai/claude-agent-sdk`, `claude-agent-sdk`) or a scheduler config | yes |
| 4.3 | Most sessions are started by Claude, not by a person | self-report | yes | no |
| 4.4 | Monitoring by exception: alerts fire on failures, not on every run | inspect | notify channel receives failures/escalations only | yes |
| 4.5 | Per-work-type guardrails exist (deny lists, budgets, model choice per job) | inspect | settings or routine config differ by job type | yes |

**Step 4 is reached when 4.1, 4.2, 4.4, 4.5 are `verified`.**
