# Agent guidance

## Environment constraints (local models)
- Models run locally on one 24GB machine, **one at a time**. Context is small (32–64k). Treat it as scarce.
- Never `cat` large files or dump long command output. Use `rg`/grep to locate, then read narrow line ranges.
- Pipe noisy commands through `tail -n 40` / `head -n 40`.
- Do not spawn parallel subagents: each different model forces a reload.

## Handoff protocol (files in `.agent/`, git-ignored)
- `TASK.md`   — the request (written by the human / loop script)
- `PLAN.md`   — investigator output: relevant files, approach, ordered steps, how to verify
- `HANDOFF.md`— builder output: what changed and what was run
- `QA.md`     — reviewer output: first line `VERDICT: PASS` or `VERDICT: FAIL`, then issues
Each role reads the previous role's file instead of relying on chat history.

## Roles
- `investigate` (scout model): read-only; produces PLAN.md.
- `build` (coder model): implements PLAN.md, fixes QA.md issues, never pushes.
- `qa` (reviewer model): read-only except `.agent/`; runs tests; writes QA.md.
- `quick` (reviewer model): read-only Q&A via /ask and /check; never writes files, never part of the .agent/ loop.
