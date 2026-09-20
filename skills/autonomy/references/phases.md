# The phases, their order, and what each one owes

Seven phases. The order is fixed and the reason is Cherny's trap: agent count scaled before
the loop has earned trust. A repository that schedules an unattended agent before automated
review works has not reached step 3; it has a step-1 loop with a step-3 mechanism bolted on.

**Each phase ends with a proof, not a file.** A file that exists is `assumed`. A run whose
numbers are recorded is `verified`. That distinction is the whole point of the sequence —
see `../../../references/false-greens.md`.

## The table

| Phase | Closes | Touches production? | Exit proof |
|---|---|---|---|
| **0. Guardrails and the written contract** | 2.A1, 2.B6, 2.C2 | no | A headless dry run in a throwaway clone shows three results: a read-only command runs, a push to the default branch is refused, **and the agent's own working-branch push is allowed.** Plus: the contract exists as text an agent will actually read (CLAUDE.md or a skill), naming what is off-limits and when to stop. |
| **1. The loop runs on every change** | 2.B2, 2.B7, G2.2 | no | One run on the real CI runner is green, **and** one deliberately planted violation turns it red. Local-only evidence does not close this phase: runner and laptop differ in ways that only the runner shows. |
| **2. Automated review that finds things** | 2.D1, 2.D2, 2.D3 | no | A canary change carrying defects drawn from this repository's own fix history. The review run's record shows turns above the floor, no denial on a tool it needed, a posted comment, and at least one planted defect named. A green check with no numbers behind it does not close this phase. |
| **3. A queue with an arming step** | 3.C2, 3.C3, 3.C4 | no | A task template exists whose acceptance criteria are checkable without a live database; filing a task does **not** queue it — a separate deliberate step does. At least one task in the queue is a negative case whose correct outcome is "stop and ask a human", not a pull request. |
| **4. One routine, one supervised pilot** | 3.C1, 3.D4 | no (pull requests only) | The routine is created **disabled**, run once by hand with a human present, and its log read. The run ends in a pull request or an honest `blocked` report, and every claim in that report matches what is visible from outside the run. Only then is the schedule enabled. |
| **5. An event can start a run** | 3.D1, 3.D2 | read-only | One real event starts exactly one session; a duplicate event starts none. Hand off to `incident-response` for the loop itself. |
| **6. Failure-only reporting and usage numbers** | G1.4, G2.1, G4.4 | no | One failure actually arrives in the channel, sent by the mechanism rather than by hand. Quiet runs stay quiet. |

## Ordering rules

1. **Never plan phase 4 before phase 2 has its proof.** An unattended agent's pull request
   is only as trustworthy as the review that reads it.
2. **Phase 0 comes first whenever the scope says a push to the default branch deploys.**
   With no branch protection available on the tier, say so in the plan as a residual gap
   rather than implying the rules close it — permission patterns match text, and text can be
   written in ways nobody anticipated.
3. **Phase 1 before phase 2.** A review job is not a substitute for a loop; it reads diffs,
   it does not run code.
4. **Phase 3 before phase 4**, and if the scope says the queue lives somewhere a fresh cloud
   checkout cannot reach, moving it is part of phase 3, not a later surprise.
5. **Phases 5 and 6 may be dropped.** If the scope names no event source and no channel,
   say the plan stops at 4 rather than inventing work.

## What a phase entry in `.ladder/plan.md` must contain

- the rubric ids it closes, taken from the ladder profile's failing list
- the files it touches, and which of them are the human's to change (secrets, billing,
  application installs, branch protection, merges)
- whether it touches production, answered from the scope, not guessed
- the exit proof, written as something that can come back negative
- a stop condition: what would make this phase the wrong thing to do

## Headless behaviour

Without a scope (`interview` never ran, or ran headless), a plan may cover **phases 0–2
only**, and must say why it stops there: those three are the same for every project, while
3 onward depend on answers no probe can find. Filling them in from assumptions is how a
plan ends up protecting the wrong branch and queueing work into a tracker the agent cannot
open.
