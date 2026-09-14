#!/usr/bin/env bash
# ladder probe — read-only discovery of this machine and one repo.
# Emits JSON on stdout. Never prints secret values, only names and presence.
# Portable: bash 3.2+, coreutils, git. Uses jq or python3 for JSON parsing when present.
#
# usage: probe.sh [repo-path]        (default: current directory)
#        probe.sh --machine-only
#        probe.sh --repo-only [path]
PROBE_VERSION="0.1.0"
WRITTEN_FOR_CLAUDE="2.1.257"   # bump when the probe list is re-verified against a newer CLI

set -u
MODE="both"
TARGET="."
for a in "$@"; do
  case "$a" in
    --machine-only) MODE="machine" ;;
    --repo-only) MODE="repo" ;;
    -h|--help) sed -n '2,9p' "$0"; exit 0 ;;
    *) TARGET="$a" ;;
  esac
done

# ---------- json helpers ----------
esc() { printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\t/\\t/g' | tr -d '\r' | awk 'BEGIN{ORS="\\n"} {print}' | sed 's/\\n$//'; }
str() { printf '"%s"' "$(esc "$1")"; }
bool() { if [ "$1" = "1" ] || [ "$1" = "true" ]; then printf 'true'; else printf 'false'; fi; }
arr() { # arr item1 item2 ...
  local first=1; printf '['
  for x in "$@"; do [ $first = 1 ] || printf ','; first=0; str "$x"; done
  printf ']'
}
lines_arr() { # stdin lines -> json array (empty lines dropped)
  local first=1; printf '['
  while IFS= read -r l; do [ -z "$l" ] && continue; [ $first = 1 ] || printf ','; first=0; str "$l"; done
  printf ']'
}
have() { command -v "$1" >/dev/null 2>&1; }
exists() { [ -e "$1" ] && printf 1 || printf 0; }

# json_keys FILE JSONPATH -> newline-separated keys (names only), or "__unparsed__"
json_keys() {
  local f="$1" path="$2"
  [ -f "$f" ] || return 0
  if have jq; then
    jq -r "($path // {}) | keys[]" "$f" 2>/dev/null || echo "__unparsed__"
  elif have python3; then
    python3 - "$f" "$path" <<'PY' 2>/dev/null || echo "__unparsed__"
import json,sys
d=json.load(open(sys.argv[1])); 
for p in [x for x in sys.argv[2].strip('.').split('.') if x]:
    d=d.get(p,{}) if isinstance(d,dict) else {}
print('\n'.join(d.keys()) if isinstance(d,dict) else '')
PY
  else echo "__unparsed__"; fi
}
# json_len FILE JSONPATH -> integer length of array (0 if missing)
json_len() {
  local f="$1" path="$2"
  [ -f "$f" ] || { printf 0; return; }
  if have jq; then jq -r "($path // []) | length" "$f" 2>/dev/null || printf -- -1
  elif have python3; then python3 - "$f" "$path" <<'PY' 2>/dev/null || printf -- -1
import json,sys
d=json.load(open(sys.argv[1]))
for p in [x for x in sys.argv[2].strip('.').split('.') if x]:
    d=d.get(p,None) if isinstance(d,dict) else None
print(len(d) if isinstance(d,(list,dict)) else 0)
PY
  else printf -- -1; fi
}
json_str() { # json_str FILE JSONPATH -> scalar as string or ""
  local f="$1" path="$2"
  [ -f "$f" ] || return 0
  if have jq; then jq -r "$path // empty" "$f" 2>/dev/null
  elif have python3; then python3 - "$f" "$path" <<'PY' 2>/dev/null
import json,sys
d=json.load(open(sys.argv[1]))
for p in [x for x in sys.argv[2].strip('.').split('.') if x]:
    d=d.get(p,None) if isinstance(d,dict) else None
print(d if isinstance(d,(str,int,float,bool)) else '')
PY
  fi
}

# ---------- machine scope ----------
machine() {
  local home="${HOME:-~}"
  local cc="$home/.claude"
  local claude_ver; claude_ver="$(claude --version 2>/dev/null | head -1 || true)"
  local clis=""; for c in git gh docker node npm pnpm yarn bun python3 uv go cargo jq rg make; do have "$c" && clis="$clis $c"; done
  local gh_auth=0; have gh && gh auth status >/dev/null 2>&1 && gh_auth=1
  local mcp_global; mcp_global="$(json_keys "$home/.claude.json" ".mcpServers" | lines_arr)"
  local plugins; plugins="$(json_keys "$cc/plugins/installed_plugins.json" ".plugins" | sed 's/@.*//' | sort -u | lines_arr)"
  local marketplaces; marketplaces="$(json_keys "$cc/plugins/known_marketplaces.json" "." | lines_arr)"
  printf '{'
  printf '"os":%s,' "$(str "$(uname -s 2>/dev/null)/$(uname -m 2>/dev/null)")"
  printf '"shell":%s,' "$(str "${SHELL:-unknown}")"
  printf '"claude_version":%s,' "$(str "$claude_ver")"
  printf '"probe_written_for_claude":%s,' "$(str "$WRITTEN_FOR_CLAUDE")"
  printf '"clis":%s,' "$(arr $clis)"
  printf '"gh_authenticated":%s,' "$(bool $gh_auth)"
  printf '"global":{'
  printf '"settings_json":%s,' "$(bool "$(exists "$cc/settings.json")")"
  printf '"default_mode":%s,' "$(str "$(json_str "$cc/settings.json" ".permissions.defaultMode")")"
  printf '"allow_rules":%s,' "$(json_len "$cc/settings.json" ".permissions.allow")"
  printf '"deny_rules":%s,' "$(json_len "$cc/settings.json" ".permissions.deny")"
  printf '"hooks_events":%s,' "$(json_keys "$cc/settings.json" ".hooks" | lines_arr)"
  printf '"sandbox_configured":%s,' "$(bool "$([ -n "$(json_str "$cc/settings.json" ".sandbox.enabled")" ] && printf 1 || printf 0)")"
  printf '"claude_md":%s,' "$(bool "$(exists "$cc/CLAUDE.md")")"
  printf '"skills":%s,' "$(ls -1 "$cc/skills" 2>/dev/null | lines_arr)"
  printf '"agents":%s,' "$(ls -1 "$cc/agents" 2>/dev/null | sed 's/\.md$//' | lines_arr)"
  printf '"commands":%s,' "$(ls -1 "$cc/commands" 2>/dev/null | sed 's/\.md$//' | lines_arr)"
  printf '"rules":%s,' "$(ls -1 "$cc/rules" 2>/dev/null | lines_arr)"
  printf '"mcp_servers":%s,' "$mcp_global"
  printf '"plugins":%s,' "$plugins"
  printf '"marketplaces":%s' "$marketplaces"
  printf '}}'
}

# ---------- repo scope ----------
repo() {
  local t="$1"
  [ -d "$t" ] || { printf '{"error":%s}' "$(str "path not found: $t")"; return; }
  local root; root="$(git -C "$t" rev-parse --show-toplevel 2>/dev/null || true)"
  local is_git=0; [ -n "$root" ] && is_git=1
  [ -n "$root" ] || root="$(cd "$t" && pwd)"
  local remote="" default_branch="" worktrees=0 branches=0 last_commit="" commits_30d=0 merges_30d=0 gitignore_env=0
  if [ $is_git = 1 ]; then
    remote="$(git -C "$root" remote get-url origin 2>/dev/null | sed -E 's#(https?://)[^@/]+@#\1#' || true)"
    default_branch="$(git -C "$root" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#origin/##' || true)"
    [ -n "$default_branch" ] || default_branch="$(git -C "$root" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
    worktrees="$(git -C "$root" worktree list 2>/dev/null | wc -l | tr -d ' ')"
    branches="$(git -C "$root" branch --list 2>/dev/null | wc -l | tr -d ' ')"
    last_commit="$(git -C "$root" log -1 --format=%cs 2>/dev/null || true)"
    commits_30d="$(git -C "$root" rev-list --count --since=30.days HEAD 2>/dev/null || echo 0)"
    merges_30d="$(git -C "$root" rev-list --count --merges --since=30.days HEAD 2>/dev/null || echo 0)"
    git -C "$root" check-ignore -q .env 2>/dev/null && gitignore_env=1
  fi
  local c="$root/.claude"
  # CLAUDE.md files (root + nested, depth 3), with line counts
  local claude_mds; claude_mds="$(find "$root" -maxdepth 3 -name CLAUDE.md -not -path '*/node_modules/*' 2>/dev/null | while read -r f; do printf '%s:%s\n' "${f#$root/}" "$(wc -l <"$f" | tr -d ' ')"; done | lines_arr)"
  # package.json scripts (names only)
  local pkg="$root/package.json"
  local scripts; scripts="$(json_keys "$pkg" ".scripts" | lines_arr)"
  local manifests=""; for m in package.json pyproject.toml requirements.txt Cargo.toml go.mod Makefile Gemfile composer.json pom.xml build.gradle mix.exs; do [ -f "$root/$m" ] && manifests="$manifests $m"; done
  local test_cfgs=""; for p in vitest.config jest.config playwright.config cypress.config pytest.ini setup.cfg tox.ini; do ls "$root"/$p* >/dev/null 2>&1 && test_cfgs="$test_cfgs $p"; done
  [ -f "$root/tsconfig.json" ] && test_cfgs="$test_cfgs tsconfig.json"
  local ci; ci="$(ls -1 "$root/.github/workflows" 2>/dev/null | lines_arr)"
  local ci_claude=0 ci_security=0 ci_tests=0
  if [ -d "$root/.github/workflows" ]; then
    grep -rqiE 'anthropics/claude-code-action|claude-code-review|claude -p' "$root/.github/workflows" 2>/dev/null && ci_claude=1
    grep -rqiE 'codeql|semgrep|snyk|trivy|security-review|npm audit|pip-audit' "$root/.github/workflows" 2>/dev/null && ci_security=1
    grep -rqiE 'npm (run )?test|pnpm test|yarn test|pytest|cargo test|go test|vitest|jest|playwright' "$root/.github/workflows" 2>/dev/null && ci_tests=1
  fi
  local precommit=0; { [ -f "$root/.pre-commit-config.yaml" ] || [ -d "$root/.husky" ] || [ -f "$root/lefthook.yml" ]; } && precommit=1
  local deploy=""; for d in Dockerfile docker-compose.yml compose.yml vercel.json fly.toml netlify.toml render.yaml Procfile; do [ -f "$root/$d" ] && deploy="$deploy $d"; done
  local migrations=""; for d in supabase/migrations prisma drizzle alembic migrations db/migrate; do [ -d "$root/$d" ] && migrations="$migrations $d"; done
  local env_files; env_files="$(ls -1a "$root" 2>/dev/null | grep -E '^\.env' | lines_arr)"
  local docs=""; for d in docs doc documentation wiki ADR adr decisions; do [ -d "$root/$d" ] && docs="$docs $d"; done
  local sessions=0; local slug; slug="$(printf '%s' "$root" | sed 's#[/_]#-#g; s#^-*##')"
  ls "${HOME}/.claude/projects/"*"$slug"* >/dev/null 2>&1 && sessions="$(ls -1 "${HOME}/.claude/projects/"*"$slug"*/*.jsonl 2>/dev/null | wc -l | tr -d ' ')"
  local profile=0; [ -f "$c/ladder-profile.md" ] && profile=1
  local inc_profile=0; [ -f "$c/incident-profile.md" ] && inc_profile=1

  printf '{'
  printf '"root":%s,' "$(str "$root")"
  printf '"is_git":%s,' "$(bool $is_git)"
  printf '"remote":%s,' "$(str "$remote")"
  printf '"default_branch":%s,' "$(str "$default_branch")"
  printf '"worktrees":%s,"branches":%s,' "$worktrees" "$branches"
  printf '"last_commit":%s,"commits_30d":%s,"merges_30d":%s,' "$(str "$last_commit")" "$commits_30d" "$merges_30d"
  printf '"claude_sessions_on_this_machine":%s,' "$sessions"
  printf '"claude_md":%s,' "$claude_mds"
  printf '"agents_md":%s,' "$(bool "$(exists "$root/AGENTS.md")")"
  printf '"dot_claude":{'
  printf '"present":%s,' "$(bool "$(exists "$c")")"
  printf '"settings_json":%s,"settings_local_json":%s,' "$(bool "$(exists "$c/settings.json")")" "$(bool "$(exists "$c/settings.local.json")")"
  printf '"default_mode":%s,' "$(str "$(json_str "$c/settings.json" ".permissions.defaultMode")")"
  printf '"allow_rules":%s,' "$(( $(json_len "$c/settings.json" ".permissions.allow") + $(json_len "$c/settings.local.json" ".permissions.allow") ))"
  printf '"deny_rules":%s,' "$(( $(json_len "$c/settings.json" ".permissions.deny") + $(json_len "$c/settings.local.json" ".permissions.deny") ))"
  printf '"hooks_events":%s,' "$(json_keys "$c/settings.json" ".hooks" | lines_arr)"
  printf '"skills":%s,' "$(ls -1 "$c/skills" 2>/dev/null | lines_arr)"
  printf '"agents":%s,' "$(ls -1 "$c/agents" 2>/dev/null | sed 's/\.md$//' | lines_arr)"
  printf '"commands":%s,' "$(ls -1 "$c/commands" 2>/dev/null | sed 's/\.md$//' | lines_arr)"
  printf '"rules":%s,' "$(ls -1 "$c/rules" 2>/dev/null | lines_arr)"
  printf '"ladder_profile":%s,"incident_profile":%s' "$(bool $profile)" "$(bool $inc_profile)"
  printf '},'
  printf '"mcp_servers":%s,' "$(json_keys "$root/.mcp.json" ".mcpServers" | lines_arr)"
  printf '"manifests":%s,' "$(arr $manifests)"
  printf '"scripts":%s,' "$scripts"
  printf '"test_configs":%s,' "$(arr $test_cfgs)"
  printf '"ci":{"workflows":%s,"runs_tests":%s,"claude_review":%s,"security_scan":%s},' "$ci" "$(bool $ci_tests)" "$(bool $ci_claude)" "$(bool $ci_security)"
  printf '"precommit_hooks":%s,' "$(bool $precommit)"
  printf '"deploy_files":%s,' "$(arr $deploy)"
  printf '"migration_dirs":%s,' "$(arr $migrations)"
  printf '"env_files":%s,"env_gitignored":%s,' "$env_files" "$(bool $gitignore_env)"
  printf '"docs_dirs":%s' "$(arr $docs)"
  printf '}'
}

printf '{"probe_version":%s,"generated":%s,' "$(str "$PROBE_VERSION")" "$(str "$(date -u +%Y-%m-%dT%H:%M:%SZ)")"
case "$MODE" in
  machine) printf '"machine":'; machine ;;
  repo)    printf '"repo":'; repo "$TARGET" ;;
  both)    printf '"machine":'; machine; printf ',"repo":'; repo "$TARGET" ;;
esac
printf '}\n'
