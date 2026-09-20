#!/usr/bin/env bash
# cloud-probe — what this session can actually do. Read-only, prints JSON on stdout.
# Run it as the first step of any unattended run, and put the result in the report.
# Never prints secret values: names, presence and versions only.
#
# usage: cloud-probe.sh [repo-path]   (default: current directory)
PROBE_VERSION="0.2.1"

set -u
TARGET="${1:-.}"
case "$TARGET" in -h|--help) sed -n '2,7p' "$0"; exit 0 ;; esac

esc() { printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' | tr -d '\r\n'; }
str() { printf '"%s"' "$(esc "$1")"; }
bool() { if [ "$1" = "1" ]; then printf 'true'; else printf 'false'; fi; }
have() { command -v "$1" >/dev/null 2>&1; }
ver() { command -v "$1" >/dev/null 2>&1 && "$1" --version 2>/dev/null | head -1 || true; }

ROOT="$TARGET"
if have git; then
  r="$(git -C "$TARGET" rev-parse --show-toplevel 2>/dev/null || true)"
  [ -n "$r" ] && ROOT="$r"
fi

printf '{'
printf '"probe":"cloud","probe_version":%s,' "$(str "$PROBE_VERSION")"
printf '"generated":%s,' "$(str "$(date -u +%Y-%m-%dT%H:%M:%SZ)")"

# ---------- session ----------
remote=0; [ "${CLAUDE_CODE_REMOTE:-}" = "true" ] && remote=1
printf '"session":{"remote":%s,"entrypoint":%s,"inside_claude_code":%s},' \
  "$(bool $remote)" "$(str "${CLAUDE_CODE_ENTRYPOINT:-}")" \
  "$(bool "$([ "${CLAUDECODE:-}" = "1" ] && echo 1 || echo 0)")"

# ---------- tools ----------
# gh is the one most procedures are written in, and the one most likely to be missing.
gh_present=0; have gh && gh_present=1
gh_auth="unknown"
if [ $gh_present = 1 ]; then
  if gh auth status >/dev/null 2>&1; then gh_auth="yes"; else gh_auth="no"; fi
fi
printf '"tools":{"gh":%s,"gh_authenticated":%s' "$(bool $gh_present)" "$(str "$gh_auth")"
for t in git node npm pnpm yarn python3 jq curl make cargo go; do
  p=0; have "$t" && p=1
  printf ',%s:%s' "$(str "$t")" "$(bool $p)"
done
printf ',"node_version":%s,"git_version":%s},' "$(str "$(ver node)")" "$(str "$(ver git)")"

# ---------- dependencies ----------
dep_dir=""
for d in node_modules .venv venv vendor target; do
  [ -d "$ROOT/$d" ] && { dep_dir="$d"; break; }
done
manifest=""
for m in package.json pyproject.toml requirements.txt go.mod Cargo.toml Gemfile composer.json; do
  [ -f "$ROOT/$m" ] && { manifest="$m"; break; }
done
lock=""
for l in package-lock.json pnpm-lock.yaml yarn.lock poetry.lock uv.lock Cargo.lock go.sum; do
  [ -f "$ROOT/$l" ] && { lock="$l"; break; }
done
printf '"dependencies":{"manifest":%s,"lockfile":%s,"installed_dir":%s,"install_needed":%s},' \
  "$(str "$manifest")" "$(str "$lock")" "$(str "$dep_dir")" \
  "$(bool "$([ -n "$manifest" ] && [ -z "$dep_dir" ] && echo 1 || echo 0)")"

# ---------- repo settings that govern this run ----------
s="$ROOT/.claude/settings.json"
settings=0; [ -f "$s" ] && settings=1
hooks=0; [ $settings = 1 ] && grep -q '"hooks"' "$s" 2>/dev/null && hooks=1
ask=0; [ $settings = 1 ] && grep -q '"ask"' "$s" 2>/dev/null && ask=1
deny=0; [ $settings = 1 ] && grep -q '"deny"' "$s" 2>/dev/null && deny=1
hookdir=0; [ -d "$ROOT/.claude/hooks" ] && hookdir=1
skills=0; [ -d "$ROOT/.claude/skills" ] && skills=1
printf '"repo_settings":{"settings_json":%s,"declares_hooks":%s,"hook_scripts_dir":%s,"has_ask_rules":%s,"has_deny_rules":%s,"skills_dir":%s},' \
  "$(bool $settings)" "$(bool $hooks)" "$(bool $hookdir)" "$(bool $ask)" "$(bool $deny)" "$(bool $skills)"

# ---------- git ----------
branch=""; remote_url_set=0; default_branch=""
if have git && git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  branch="$(git -C "$ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  git -C "$ROOT" remote get-url origin >/dev/null 2>&1 && remote_url_set=1
  default_branch="$(git -C "$ROOT" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||' || true)"
fi
printf '"git":{"branch":%s,"origin_configured":%s,"default_branch":%s,"on_default_branch":%s}' \
  "$(str "$branch")" "$(bool $remote_url_set)" "$(str "$default_branch")" \
  "$(bool "$([ -n "$branch" ] && [ "$branch" = "$default_branch" ] && echo 1 || echo 0)")"

printf '}\n'

# What this script cannot answer, and the run must check separately:
#   - which MCP tools are available (ask the session's own tool list, not the shell)
#   - whether a push of this session's branch is permitted (only a real push settles it)
#   - whether the network reaches a given host (no egress test here, by design)
