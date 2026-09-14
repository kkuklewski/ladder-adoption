# Incident <id> — <one-line title>

**Status:** <investigating | fix_prepared | verification_failed | waiting_for_human>
**Phase:** <1|2|3>   **Confidence:** <high|medium|low>

## Summary
<2–3 sentences: what broke, for whom, since when, how often (count).>

## Root cause
<one hypothesis>

## Evidence
- `<file:line>` — <what it shows>
- commit `<sha>` — <what changed>
- <log / state-store row>

## Fix
<none (Phase 1) | description>
- base_commit: `<sha>`  working_branch: `incident/<short>`
- changed_files: <list>
- PR: <url | not opened>

## Verification
| step | result |
|---|---|
| lint | pass / fail / not_available |
| typecheck | |
| unit | |
| build | |
| e2e (affected flow) | |

## Remaining uncertainty
- <what is not proven; which source conflicts with which>

## Would an engineer have done this?
<yes / no / partly — one sentence. Cherny's Step 3 test for the loop.>

## Recommended human action
<one imperative sentence>

## Proposed knowledge updates (not applied)
- <CLAUDE.md / decisions/ edits the human may want>
