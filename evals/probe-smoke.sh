#!/usr/bin/env bash
# Smoke test for skills/ladder/scripts/probe.sh: valid JSON on an empty dir, a non-git dir,
# this repo, and a missing path. Requires python3 or jq for validation.
set -u
here="$(cd "$(dirname "$0")/.." && pwd)"
probe="$here/skills/ladder/scripts/probe.sh"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
validate() { if command -v jq >/dev/null; then jq -e . >/dev/null; else python3 -m json.tool >/dev/null; fi; }
fail=0
for target in "$tmp" "$here" "/definitely/not/here"; do
  if bash "$probe" --repo-only "$target" | validate; then echo "ok   repo-only $target"; else echo "FAIL repo-only $target"; fail=1; fi
done
if bash "$probe" --machine-only | validate; then echo "ok   machine-only"; else echo "FAIL machine-only"; fail=1; fi
# blank-sheet: output must not contain the plugin author's name or any obvious secret-looking value
if bash "$probe" "$tmp" | grep -qiE 'kuklewski|sk-ant-|ghp_|AKIA[0-9A-Z]{16}'; then echo "FAIL blank-sheet: author name or secret-like string in output"; fail=1; else echo "ok   blank-sheet"; fi
exit $fail
