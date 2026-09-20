# evals

- **`claude plugin eval` suite** — one directory per case, generated from
  `_fixtures/build_cases.py` (expectations) and `_fixtures/lib.sh` (synthetic repositories).
  Run from the plugin root:

  ```bash
  claude plugin eval . --scaffold --trust-plugin --allow-tools Bash Write Edit --ablation none
  ```

  The bar is every case at score 1.0 over 3 runs.
- **`probe-smoke.sh`** — no model needed: the probe must emit valid JSON for an empty dir, a
  non-git dir, this repo and a missing path, and never print the author's name or a
  secret-looking string.
