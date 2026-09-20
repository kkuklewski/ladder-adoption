#!/usr/bin/env bash
# Smoke test for the probe scripts: valid JSON on an empty dir, a non-git dir,
# this repo, and a missing path. Requires python3 or jq for validation.
set -u
here="$(cd "$(dirname "$0")/.." && pwd)"
probe="$here/skills/ladder/scripts/probe.sh"
cloud="$here/scripts/cloud-probe.sh"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
validate() { if command -v jq >/dev/null; then jq -e . >/dev/null; else python3 -m json.tool >/dev/null; fi; }
fail=0
for target in "$tmp" "$here" "/definitely/not/here"; do
  if bash "$probe" --repo-only "$target" | validate; then echo "ok   repo-only $target"; else echo "FAIL repo-only $target"; fail=1; fi
done
if bash "$probe" --machine-only | validate; then echo "ok   machine-only"; else echo "FAIL machine-only"; fail=1; fi
# blank-sheet: output must not contain the plugin author's name or any obvious secret-looking value
if bash "$probe" "$tmp" | grep -qiE 'kuklewski|sk-ant-|ghp_|AKIA[0-9A-Z]{16}'; then echo "FAIL blank-sheet: author name or secret-like string in output"; fail=1; else echo "ok   blank-sheet"; fi

# cloud-probe: same three targets, plus the one judgement it makes (a manifest with no
# installed dependencies means the run has to install them).
for target in "$tmp" "$here" "/definitely/not/here"; do
  if bash "$cloud" "$target" | validate; then echo "ok   cloud $target"; else echo "FAIL cloud $target"; fail=1; fi
done
dep="$tmp/dep"; mkdir -p "$dep"; echo '{}' > "$dep/package.json"
if bash "$cloud" "$dep" | grep -q '"install_needed":true'; then echo "ok   cloud install_needed"; else echo "FAIL cloud install_needed (manifest, no deps)"; fail=1; fi
mkdir -p "$dep/node_modules"
if bash "$cloud" "$dep" | grep -q '"install_needed":false'; then echo "ok   cloud install_present"; else echo "FAIL cloud install_needed (deps present)"; fail=1; fi
exit $fail
