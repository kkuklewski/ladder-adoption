# False greens: when success is reported and nothing happened

A status is a claim. A count is evidence.

Every entry below was observed in one project over two days, while building exactly the
kind of automation this plugin scores for. They matter here for one reason: an unattended
agent reports on its own work, and each of these makes "done" and "never ran" look
identical from outside.

## The catalogue

| # | What it looks like | What actually happened | The number that exposes it |
|---|---|---|---|
| 1 | A review job passes in about two seconds. | The action refused to run because the pull request modifies the workflow file that defines it, and validation requires the file to match the default branch. It exits cleanly, so the job is green. | duration, and the absence of any execution record |
| 2 | A review job passes, posts nothing. | An allow-list flag **replaced** the command's own declared tool list instead of extending it. The command was denied its first tool call and stopped before reading the diff. | turns (3), permission denials (1) |
| 3 | Two review jobs pass, one posts nothing. | Both ran in parallel as the same author. One command stops when "the bot has already commented", so whichever finished first silenced the other. | the two jobs' start and end timestamps overlapping |
| 4 | A review job passes with a clean report on a diff carrying three real defects. | It genuinely ran and found nothing. A shallow review and a clean review are mechanically indistinguishable. | **none** — see below |
| 5 | Alerts are "sent" for months. | The webhook fell back to an editor test endpoint, which accepts the request and discards it unless someone has the workflow open. The send resolves, so nothing errors. | the delivery side, which nobody was watching |
| 6 | A notification step is skipped and the job stays green. | The secret was never set, and the step treats a missing secret as "nothing to do". | secret presence, and one deliberate red run |
| 7 | A command prints three URLs and exits 0. | The labels were already there. The output is identical whether or not anything changed. | read the state afterwards, not the exit code |
| 8 | A test suite is green. | The mock always succeeds, so the assertions prove the mock's behaviour. They would pass against a function that does nothing. | break the branch on purpose and watch the test go red |
| 9 | A verifier reports "0 denials" on every run. | It read a count field that only exists in one of the two shapes the data comes in, and treated absent as zero. The runs it examined had 11 and 2. | a fixture built from the real artifact, not from the log |
| 10 | Nothing new appears in a window that was searched. | The filter's start time was later than the events. | widen the window and compare against a known-present item |

## The rule

**Before reporting that something worked, name the number that proves it.** If no number
exists, say `UNVERIFIED` and what is missing. "The check was green" is not a number.

For a run of any Claude-based automation, the numbers are: turns taken, permission denials,
whether an execution record exists at all, whether the intended artifact (a comment, a
branch, a pull request) is visible **from outside the run**, and cost. A run of zero or one
turn did not do the work. A denial on a tool the task needs means it stopped early.

## Row 4 has no number, and that is the point

A review that ran properly and missed real defects produces exactly the metrics of a review
that ran properly and found nothing. No amount of run inspection separates them.

Two things help, and neither is a metric:

- **A canary.** Send a change containing defects whose class is known, and check the review
  names them. Repeat it when the prompt or the model changes.
- **A prompt built from the project's own failures.** In the run that produced this file, an
  off-the-shelf review command found 0 of 3 planted defects; a prompt naming the classes
  taken from that project's own fix history found all 3 plus a fourth the author had not
  planted. Same diff, same model, same cost.

Generic review asks "is this good code". The question that works is "does this repeat the
way this project has broken before".

## Two ways this catalogue misleads

- **Every entry is from one project, one stack, one CI provider.** The shapes generalise;
  the specifics do not. Treat them as things to look for, not things to expect.
- **Writing a verifier does not make a run honest.** Entry 9 is a verifier that was itself
  a false green for its entire existence. Whatever checks the claims is also a claim.
