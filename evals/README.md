# evals

- `probe-smoke.sh` — run anywhere: the probe must emit valid JSON for an empty dir, a non-git
  dir, this repo, and a missing path, and must never print the author's name or a
  secret-looking string.
- Blank-sheet acceptance (manual until it is encoded as a `claude plugin eval` case): on a
  machine with a fresh `~/.claude`, clone any public repo, run `/ladder`, expect a Step 0 or
  Step 1 report with no errors and no reference to the plugin author.
