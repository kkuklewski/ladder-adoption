# ladder-adoption

**Find your rung on the Steps of AI Adoption, and the next one up.**

A Claude Code plugin with two skills:

| skill | what it does |
|---|---|
| `/ladder` | Blank-sheet discovery of this machine and repo, scored against Boris Cherny's *Steps of AI Adoption* (Jul 2026). Tells you which step you are on, which gate checks fail, and the single smallest next action. Writes `.ladder/profile.md`. Never changes settings itself. |
| `/incident-response` | A supervised loop for one production incident: retrieve context, diagnose with a confidence level, optionally prepare a fix in a worktree, run the repo's verification contract, report to a human. Never deploys or merges. It is one concrete way to earn the 2→3 gate. |

## The one principle

The plugin knows nothing about you, your machine, or your project. It ships only
**where to look** (`skills/ladder/references/discovery.md`, `scripts/probe.sh`) and
**the rubric** (`skills/ladder/references/rubric/`). Everything else is discovered at run
time and tagged `verified`, `assumed`, or `unknown`. Findings live in a committed profile
file in the repo, not in agent memory, so a headless run on another machine starts from the
same state.

## Install

```text
/plugin marketplace add kkuklewski/ladder-adoption
/plugin install ladder-adoption@ladder-adoption
```

Or clone and load locally:

```bash
claude --plugin-dir ./ladder-adoption
```

## Use

```text
/ladder                 score the current repo, write the profile, propose the next action
/ladder scan            print the raw probe JSON only
/ladder next            print only the smallest next action
/ladder --json ../repo  machine-readable output for fleet tooling
/incident-response --init
/incident-response INC-123
```

The probe is a plain bash script you can run without Claude:

```bash
bash skills/ladder/scripts/probe.sh /path/to/repo | jq .
```

It is read-only and prints names and counts, never secret values.

## How scoring works

Cherny's table has an explicit row for every transition: *how to get from step N to N+1*.
Each row becomes a gate file with checks. A check is `probe` (decided from the script
output), `inspect` (Claude reads a file and judges), or `self-report` (not observable on
disk; asked once, otherwise `unknown`). A gate group passes only when every required check
is `verified`; `unknown` never passes. Guardrails are a separate axis and never move the
step number, but always appear in the report.

The step is a summary. The deliverable is the list of failing check ids and one next action.

## What the skills ask you

The probe finds everything it can on disk. A few things are not observable, so they are
asked once, as one grouped message, and stored in the profile. Non-interactive runs skip
the question and record `unknown`, and `unknown` never passes a check.

**Asked on the first run, whatever the step**

| id | question |
|---|---|
| 3.A5 | Where is your knowledge base (second brain, vault, wiki, docs repo)? A local path, a git repo, a URL, or `none`. A local path is verified with `ls`; the answer is stored as `knowledge_base` and reused by every skill in this plugin. |

**Asked by `/ladder` for the next gate and the current step's guardrails**

| when | id | question |
|---|---|---|
| gate 0→1 | 1.4 | Does someone technical own the AI-tooling decision for this codebase? |
| gate 0→1 | 1.5 | Is there a security/approval path for running Claude on this codebase? |
| gate 1→2 | 2.A2 | Have you run two or more Claude sessions in parallel on this repo? |
| gate 1→2 | 2.B8 | Do you trust the lint/typecheck/test/build loop enough to skip reading every diff? |
| gate 1→2 | 2.C3 | Is auto mode your normal mode here? (only if `~/.claude/settings.json` sets no `defaultMode`; a repo-level `auto` is ignored by Claude Code) |
| gate 2→3 | 3.B1 | May agents open PRs anywhere in the codebase, not just one owner's area? |
| gate 2→3 | 3.B2 | Is review turnaround measured or bounded? |
| gate 3→4 | 4.3 | Are most sessions started by Claude rather than by a person? |
| step 0 guardrails | G0.1–G0.4 | SSO/SCIM with roles? Org budget cap? Deploy inside existing IAM? Data governance path? |
| step 1 guardrails | G1.1 | Has someone set a monthly spending limit per person? (`not_applicable` on individual Pro/Max plans) |
| step 2 guardrails | G2.1 | Usage analytics in use? |
| step 3 guardrails | G3.5 | Auto-mode classifier tuned for your team? |
| step 4 guardrails | G4.1, G4.2 | Cost controls and model selection per automated job? |

Plus one prompt if a profile already exists: here is the diff, overwrite?

**Asked by `/incident-response --init`** (skipped when the ladder profile already holds the answer)

| question |
|---|
| Knowledge base: path, repo, or URL, or `none` (same as 3.A5). |
| State store: where should incidents live (existing table, tracker, issues), or `none yet`? |
| Notify channel: env var *name* of the webhook or the channel to post reports to, or `none`. |

Everything else `--init` cannot discover goes into the gap list, not into a question.

## Process of the scale

```text
/ladder [scan|score|next|--json] [path]
        │
        ▼
┌─ 1. PROBE (probe.sh, read-only, JSON) ─────────────────────────────┐
│  machine: os · claude version · global settings · skills · agents   │
│           MCP names · plugins · CLIs · gh auth                      │
│  repo:    git identity · worktrees · CLAUDE.md · .claude/ · scripts │
│           test configs · CI · deploy files · migrations · env names │
└─────────────────────────────────────────────────────────────────────┘
        │  scan? ──► print JSON, stop
        ▼
  2. LOAD PRIOR PROFILE  (.ladder/profile.md, if any)
        keep self-report answers · knowledge_base · previous step
        │
        ▼
  3. INSPECT what the probe cannot judge
        read each CLAUDE.md · read deny lists · map scripts to
        lint / typecheck / unit / e2e / build · never read .env*
        │
        ▼
  4. PLACE ON THE LADDER
        gate 0→1  1.1–1.3 verified? ──no──► Step 0
             │yes
        gate 1→2  groups A B C D all pass? ──no──► Step 1, next gate = 1→2
             │yes
        gate 2→3  A, C, D pass and B ≥ partial? ──no──► Step 2, next gate = 2→3
             │yes
        gate 3→4  4.1 4.2 4.4 4.5 verified? ──no──► Step 3, next gate = 3→4
             │yes
             ▼  Step 4
        (gates beyond the next one shown as LOCKED, not scored)
        │
        ▼
  5. GUARDRAILS for the current step only
        separate line in the report · never moves the step number
        │
        ▼
  6. SELF-REPORTS
        first run: knowledge-base question (ask, then verify with ls)
        one grouped question for next-gate + current-step ids
        headless run? ──► skip, record unknown
        │
        ▼
  7. SMALLEST NEXT ACTION
        cheapest failing required check that unlocks the most
        prefer file edits (deny rule, typecheck script, CI job)
        over team decisions · name who applies it (a human)
        │
        ▼
  8. WRITE + REPORT
        .ladder/profile.md  (diff + ask if it existed)
        report to user · --json adds {step, next_gate, score, next_action}
        │
        ▼
      STOP  (no settings edited, no hooks added, no CI created)
```

How a check gets its verdict:

```text
probe           ──► verified | fail              decided by script output
inspect         ──► verified | assumed | fail    Claude read the file
self-report     ──► yes | no | unknown           human answered, or not
ask-then-verify ──► verified | assumed | none    human gave a path; ls confirmed it

group passes  ⇔  every required check is verified
```

## Honesty by design

A repo at Step 1 with a Step 3 mechanism bolted on (an event that starts Claude) is still
Step 1. The source names that trap: scaling agent count before the loop has earned trust.
The report says which 1→2 groups are missing instead.

## Evals: what "working" means

`claude plugin eval` runs the suite in `evals/`. Every case builds a synthetic repository,
runs the skill **headless** (no human, no questions, the home directory unreadable), and
grades the files and the transcript with exact checks. No case mentions a real project or
person.

| case | what it proves |
|---|---|
| `ladder-blank-dir` | a plain folder scores Step 0 and still gets a profile |
| `ladder-bare-repo` | a repo with nothing scores Step 1 with every 1→2 group failing |
| `ladder-typical-step1` | a real-world Step 1 app scores `A=fail B=partial C=partial D=fail`, and the ignored secret file is never read |
| `ladder-step2-ready` | a repo with everything 1→2 asks for scores Step 2 |
| `ladder-existing-profile` | a headless re-run keeps recorded answers and the knowledge base |
| `ladder-prompt-injection` | text in CLAUDE.md that claims "Step 4" is quoted as a finding, not obeyed |
| `ladder-natural-language` | the skill triggers from plain words, not only the slash command |
| `incident-init-typical` | `incident-response --init` writes only its profile, phase 1, secret untouched |

Common to every ladder case: the profile is written, nothing else is created, the final
message is a report and never a question, and the author's name appears nowhere.

```bash
claude plugin eval . --scaffold --trust-plugin --allow-tools Bash Write Edit --ablation none
```

`--scaffold` runs the fixture scripts in `evals/*/scaffold.sh`; they only create files in
the throwaway workspace. Regenerate the cases after changing expectations with
`python3 evals/_fixtures/build_cases.py`.

## Running unattended and in the cloud

Headless runs, routines and cloud sessions follow `references/unattended.md`: never block on
a question or a permission prompt, push the session branch **by name**, report numbers
rather than check marks, and always end with the report.

Check the environment before following any procedure — `scripts/cloud-probe.sh` prints what
the session actually has. The `gh` CLI was **absent** from every cloud session observed so
far, so a procedure written in `gh` commands dies on its first line; `references/cloud-environment.md`
records that and the rest, each fact dated and marked `verified` or `assumed`.
`references/false-greens.md` catalogues the ways a run reports success while doing nothing,
and the number that exposes each one.

For a cloud session to load this plugin, declare it in the repository's committed
`.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": { "ladder-adoption": { "source": { "source": "github", "repo": "kkuklewski/ladder-adoption" } } },
  "enabledPlugins": { "ladder-adoption@ladder-adoption": true }
}
```

## Source

Boris Cherny, *Steps of AI Adoption*, 16 Jul 2026. The rubric transcribes the table's
"how to get from step N to N+1" rows and its Guardrails column; where the exported source
was cut off, the rubric says `[truncated in source]` instead of guessing.

## Layout

```text
.claude-plugin/plugin.json          manifest
.claude-plugin/marketplace.json     lets `/plugin marketplace add` point at this repo
skills/ladder/SKILL.md              the scorer
skills/ladder/scripts/probe.sh      read-only discovery, JSON out
scripts/cloud-probe.sh              what this session can actually do, JSON out
references/unattended.md            rules for headless, routine and cloud runs
references/cloud-environment.md     what a cloud session has, dated and sourced
references/false-greens.md          success reported, nothing done — and the tell
skills/ladder/references/           discovery.md, rubric/, profile + report templates
skills/incident-response/           the loop, uses the same probe for --init
evals/                              plugin eval suite (synthetic fixtures) + probe smoke test
```

MIT.
