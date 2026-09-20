#!/usr/bin/env bash
# summarize.sh <result.json> — one line per case, failing graders with their explanation
f="$1"
jq -r '
  "overall=\(.aggregates.overallScore) passed=\(.aggregates.casesPassed)/\(.aggregates.casesTotal) cost=$\(.costUsd|tostring|.[0:5]) dur=\(.durationSeconds)s",
  (.cases[] | "\n## \(.name)  score=\(.aggregates.score)",
    (.arms.with[] | "  run: score=\(.score) turns=\(.turns) err=\(.error // "-")",
      (.graders[] | select(.passed != true) | "   ✗ \(.name): \(.explanation|tostring|.[0:260])")))
' "$f"
