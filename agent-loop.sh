#!/usr/bin/env bash
# Phase-based agent loop: investigate -> (build -> qa) x N, one model per phase.
# Usage: ./agent-loop.sh "add feature XYZ"
set -euo pipefail

TASK="${1:?usage: agent-loop.sh \"task description\"}"
MAX_CYCLES="${MAX_CYCLES:-3}"

mkdir -p .agent
grep -qxF '.agent/' .gitignore 2>/dev/null || echo '.agent/' >> .gitignore
printf '%s\n' "$TASK" > .agent/TASK.md
rm -f .agent/PLAN.md .agent/HANDOFF.md .agent/QA.md

echo "==> investigate (scout)"
opencode run --agent investigate "Read .agent/TASK.md and write .agent/PLAN.md."
[ -s .agent/PLAN.md ] || { echo "No plan produced"; exit 2; }

for i in $(seq 1 "$MAX_CYCLES"); do
  echo "==> cycle $i/$MAX_CYCLES: build (coder)"
  opencode run --agent build "Implement .agent/PLAN.md. If .agent/QA.md exists, fix every issue it lists."

  echo "==> cycle $i/$MAX_CYCLES: qa (reviewer)"
  rm -f .agent/QA.md
  opencode run --agent qa "Review the change against .agent/PLAN.md and write .agent/QA.md."

  if head -n1 .agent/QA.md 2>/dev/null | grep -q '^VERDICT: PASS'; then
    echo "==> PASS after $i cycle(s)"
    exit 0
  fi
done

echo "==> still failing after $MAX_CYCLES cycles; see .agent/QA.md"
exit 1
