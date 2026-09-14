# The Steps of AI Adoption — reference table

Source: Boris Cherny, *Steps of AI Adoption*, 16 Jul 2026 (Claude Code team). This file is
a condensed transcription for scoring. It is the only place the ladder is defined; the
gate files reference it. Where the exported source was cut off, the text is marked
`[truncated in source]` rather than guessed.

| Step | Your role | Agents | What it looks like | Bottleneck |
|---|---|---|---|---|
| **0 Gated** | — | 0 | Only older or lighter models approved; latency compounds through gateways and custom auth; no MCP governance; access to AI tools is gated or process-heavy. No infra or approval path for hosting Claude-created code; outputs only exist locally. | Legacy security and approval processes; focus on cost-per-token containment instead of outcomes; no technical voices in decision-making. |
| **1 Assisted** | You + an agent (a pair) | ~1 | One engineer, one agent, mostly supervised: a fast pair programmer. One session at a time, you review almost every change before it merges. **Unlock:** an afternoon's change becomes something you finish between meetings. | Your attention. Low trust in output and no self-verification means you read everything and never look away. Work is synchronous: you watch Claude work instead of moving to the next task. |
| **2 Parallel** | Orchestrator | ~10 | One engineer orchestrates 5–10 agents, each on its own worktree or checkout. Claude checks its own work (tests, build, lint, security scan) before you see it. Auto mode always on. Automated code review and security review on by default. You review final diffs, not keystrokes; the maintenance backlog shrinks. Claude writes most of the code. **Unlock:** a backlog that took the team weeks becomes one engineer's afternoon of orchestration. | Reviewing output: you hand-write less and check six streams instead. Prompting and steering while juggling sessions. |
| **3 Supervised autonomy** | Manager of managers (an org tree) | ~100 | Claude writes all or nearly all the code. "Did you read the code?" becomes "what context was the model missing and how do we solve it for next time?" **Unlock:** Claude proactively does work you used to kick off manually; maintenance and cleanup run continuously in the background. | Trust in the loop and the team's decision throughput. The agent tree is too deep to babysit; the trap is scaling agent count before the loop has earned trust. Token efficiency as usage grows: needs monitoring (OTel or Analytics) and a culture of experimentation with cost control once use cases find PMF. Ask: *is this something an engineer would have done?* |
| **4 AI-native** | VP steering by intent | ~1,000+ | The loop is fully closed; most agents are kicked off by Claude. Hundreds to thousands of agents run; you steer by intent and monitor by exception. **Unlock:** the quarter-long migration becomes a workflow you kick off and check on. | Identifying and automating work at scale, and enforcing the right guardrails for each type of work. |

## How to get from one step to the next (the gates)

These rows are the rubric. Each gate file turns one row into checks.

- **0 → 1** — Executive/buyer alignment and escalation of blockers; frameworks for launching Claude securely.
- **1 → 2** — Run more than one agent at a time; a self-verification loop you trust (tests + build + lint + e2e testing with a real dev environment); auto mode, to avoid blocking permission prompts; automate code review.
- **2 → 3** — Give Claude a way to pull in context (let Claude read code, wikis, discussions); agency and code-review speed (agents may touch code owned by other teams); break up your work into loops and routines; let Claude kick off Claude.
- **3 → 4** — Scaled automation of domain-specific use cases (e.g. code migration, fuzzing, feature-building, feedback remediation).

## Products named per step (for recognising what a repo or machine already uses)

- **0:** Claude.ai chat.
- **1:** Claude Code in Desktop, CLI, or IDE; Cowork; Design; API via Anthropic, Bedrock, Vertex, or Microsoft Foundry; analytics dashboard and Analytics API; Compliance API; plan mode to review intent before edits.
- **2:** Auto mode; Agent view; Claude Code Review; Claude Security Review; Claude Code on Mobile and cloud execution in Desktop; Teams or Enterprise; Claude Tag for a single task; worktree isolation in CLI and Desktop; remote control from your phone.
- **3:** Subagents with worktree isolation; Routines, `/loop`, `/batch`, `/goal` to fan out repetitive work; dynamic workflows; Claude Tag monitoring a channel or data source and kicking off tasks proactively.
- **4:** Claude Agent SDK to build and schedule agents programmatically; Claude Tag active in most Slack channels, auto-responding.
