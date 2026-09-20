#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$here/../_fixtures/lib.sh"
typical_step1
mkdir -p notes && echo '# decisions' > notes/decisions.md
cat > .claude/ladder-profile.md <<'P'
---
ladder_profile_version: 1
generated: 2026-08-01
current_step: 1
next_gate: "1->2"
knowledge_base: ./notes
knowledge_base_status: verified
---
# Ladder profile — typical-app

## Self-reported answers
| id | answer | date |
|---|---|---|
| 2.A2 | yes | 2026-08-01 |
| 2.B8 | no | 2026-08-01 |
| G1.1 | not_applicable | 2026-08-01 |
P
