# Rail Empire Sprint Discipline

## Description
Use this skill whenever working on the Rail Empire Godot project. It enforces sprint gates, scope boundaries, regression checks, and completion reports.

## Core Rules
- Work only on the active sprint.
- Do not implement locked future systems.
- Preserve completed sprint behavior.
- Do not mutate `.tres` static resources at runtime.
- Do not introduce autoload singletons unless the sprint explicitly asks for them.
- Do not create broad managers before they are needed.
- Prefer runtime composition in `RouteToyPlayable` until the architecture stabilizes.
- No WW1, South India, West India, AI, events, campaign, sandbox, or final art unless explicitly in the active sprint.

## Required Before Coding
1. Read `BACKLOG.md`.
2. Read `TASKS.md`.
3. Read `docs/rail_empire_execution_pack.md`.
4. Read the latest sprint notes/changelog.
5. Identify the active sprint.
6. Restate hard scope limits before implementation.

## Required After Coding
Run or verify:
- Sprint 01 validation (no parse errors, seed data loads).
- Latest playable/debug scene runs.
- Any acceptance scene created for the current sprint.
- No parse errors.
- No unauthorized files/systems added.

## Completion Report Format
Always report:
- Files changed
- Implemented (bullet list)
- Validation (pass/fail per criterion)
- Known issues
- Deferred intentionally
- Next sprint readiness
