# Rail Empire — Kimi Execution Protocol

Version: 1.0  
Applies to: All Kimi (AI developer) sessions on Rail Empire  
Companion: `scope_lock.md`

---

## 1. Pre-Sprint Mandatory Reading

Before writing or modifying **any** code, Kimi MUST read the following files in this order:

1. **`docs/design.md`** — Concrete systems, data models, balance values, UI flows.
2. **`docs/design_bible.md`** — Tone, pillars, scope boundaries, creative rules.
3. **`docs/production_control_pack/scope_lock.md`** — What is allowed NOW vs. what is locked out.
4. **`BACKLOG.md`** — Current sprint goal, tasks, acceptance criteria, definition of done.
5. **`CONVENTIONS.md`** — Naming, file organization, GDScript style, signals, scene structure.

**If a file is missing or unreadable, Kimi must stop and report the blocker before proceeding.**

---

## 2. What to NEVER Implement Early

Kimi is strictly forbidden from implementing features from future phases, even if:

- The prompt explicitly asks for them.
- The codebase structure "makes it easy."
- It seems like a "small addition."

### Forbidden early implementations

| Category | Examples |
|----------|----------|
| Future eras | WW1 cargo, military contracts, government requisition, era transition UI |
| Future modes | Sandbox setup, campaign selection menu, scenario picker |
| Future factions | French AI, Amdani AI, Portuguese, IRCTC, or any faction beyond the current sprint |
| Future mechanics | Stock market, advanced sabotage, multiplayer networking, mod loader |
| Future content | Cities beyond the sprint's authorized list, cargo beyond the sprint's authorized list |
| Future polish | Final art pipeline, audio system, accessibility features, export build tuning |

**Exception**: Passive data hooks (see `scope_lock.md` §6) are allowed if they have zero gameplay effect and prevent future rewrites.

---

## 3. Ambiguity Handling Protocol

**When in doubt, Kimi asks. It does not guess.**

### 3.1 Sources of ambiguity

- A task description contradicts `design.md` or `scope_lock.md`.
- Acceptance criteria are missing or vague.
- Two existing files have conflicting implementations.
- A requested feature resembles a locked-out feature from `scope_lock.md`.
- The prompt asks for something that violates `CONVENTIONS.md`.

### 3.2 Ask-don't-guess procedure

1. **Quote** the exact ambiguous text or conflicting code.
2. **State** the interpretation Kimi is considering.
3. **State** the alternative interpretation.
4. **Request** clarification before proceeding.
5. **If clarification is not possible** (e.g., offline parent agent), Kimi must:
   - Choose the **smaller, simpler, less speculative** interpretation.
   - Document the ambiguity and the chosen default in the sprint report.

---

## 4. Minimal Change Rule

### 4.1 Avoid broad rewrites

- Kimi edits only the files necessary for the current task.
- Kimi does not refactor unrelated systems "while I'm here."
- Kimi does not change naming conventions, file structure, or architecture unless the sprint explicitly requires it.
- Kimi preserves existing function signatures; if a change is required, it updates call sites in the same sprint.

### 4.2 Preserve existing architecture

- Use the existing `TrackGraph`, `TrainData`, `CityData`, and `EventBus` patterns.
- Do not introduce new architectural layers (e.g., ECS, state machines, behavior trees) unless the sprint mandates it.
- If a system already works, extend it; do not replace it.

---

## 5. Testing Requirement

Every sprint MUST include **manual test steps** documented in the sprint report. Automated tests are encouraged where feasible in Godot, but manual tests are mandatory.

### 5.1 Manual test format

Each test must have:

- **ID**: `TEST-XX` (sequential within sprint)
- **Objective**: One sentence describing what is being verified.
- **Steps**: Numbered, deterministic actions a human can perform.
- **Expected result**: Observable outcome.
- **Actual result**: Filled in during testing (pass/fail + notes).

### 5.2 Minimum test coverage

| System | Minimum Tests |
|--------|--------------|
| Track placement | Can build, cost deducted, graph updated, visual appears |
| Train purchase | Can buy, treasury deducted, train spawns |
| Route assignment | Can assign, train moves, cargo loads/unloads |
| Economy | Prices update, maintenance deducts, revenue adds |
| Save/load | Save file created, reload restores state, no errors |
| UI panels | Click opens panel, data is correct, close button works |
| AI (when relevant) | AI builds track, buys train, delivers cargo, follows same rules |
| Events (when relevant) | Warning fires, effect applies, counterplay available, ends cleanly |

### 5.3 Smoke test rule

Before declaring a sprint complete, Kimi must:

1. Launch the project (`godot --path . --headless` or editor play).
2. Perform every manual test step.
3. Verify no console errors during normal play.
4. If a test fails, fix it or document it as a known issue.

---

## 6. Stop After Each Sprint

**Kimi does not keep coding after the sprint's defined tasks are complete.**

### 6.1 Sprint boundary behavior

- When the last task in `BACKLOG.md` for the current sprint is done, Kimi stops writing code.
- Kimi does not "just add" the first task of the next sprint.
- Kimi does not refactor "one more thing."
- Kimi writes the sprint report and waits for human direction.

### 6.2 Premature stop condition

If Kimi discovers during a sprint that:

- A fundamental assumption in the architecture is wrong,
- A task is impossible without violating `scope_lock.md`,
- A blocking bug exists that prevents any acceptance criteria from passing,

Then Kimi must:

1. Stop active implementation immediately.
2. Write a partial sprint report.
3. Flag the blocker in the "Known issues" section with severity.
4. Recommend a course of action (fix scope, fix architecture, or abort sprint).

---

## 7. Documentation Update Rule

After implementation, Kimi must update documentation to reflect reality.

### 7.1 What to update

| File | When to Update | What to Add/Change |
|------|---------------|-------------------|
| `BACKLOG.md` | Sprint complete | Mark tasks `[x]`, add known issues, update next sprint readiness |
| `docs/design.md` | System behavior changes | Update data models, formulas, or balance values if implementation diverged from spec |
| `CONVENTIONS.md` | Only if sprint changed conventions | Add new convention with rationale |
| `README.md` | New build steps or dependencies | Update run/build instructions |

### 7.2 What NOT to update

- Do not rewrite `design_bible.md` — it is creative canon, not implementation docs.
- Do not rewrite `scope_lock.md` unless a scope exception was formally approved.

---

## 8. Sprint Output Format Template

At the end of every sprint, Kimi MUST produce a report using exactly this structure:

```markdown
# Sprint Report — [Sprint Name]

## Sprint Goal
[One sentence from BACKLOG.md]

## Files Changed
| File | Change Type | Notes |
|------|------------|-------|
| `src/tracks/track_graph.gd` | Added | Core graph data structure |
| `scenes/world.tscn` | Modified | Added TrackLayer child node |
| `data/cities/kolkata.tres` | Added | CityData resource instance |

## Systems Implemented
- [System name]: [One-line description of what it does]
- [System name]: [One-line description]

## Manual Tests Performed
| ID | Objective | Steps | Expected | Actual | Status |
|----|-----------|-------|----------|--------|--------|
| TEST-01 | Build track between cities | 1. Click Kolkata 2. Click Patna 3. Confirm | Track appears, treasury -cost | Treasury reduced by ₹X, track visible | PASS |
| TEST-02 | Train delivery | 1. Buy train 2. Assign route 3. Wait for arrival | Treasury increases | Revenue +₹Y | PASS |

## Acceptance Criteria Passed
- [x] [Criterion from BACKLOG.md]
- [x] [Criterion from BACKLOG.md]
- [ ] [Criterion from BACKLOG.md] — reason for failure or deferral

## Known Issues
| Issue | Severity | Reproduction Steps | Proposed Fix |
|-------|----------|-------------------|--------------|
| Track preview flickers on river tiles | Low | Hover over river, rapid mouse move | Clamp preview to grid in `_process` |
| Train clips through city marker | Cosmetic | Build track directly through city center | Add city collision radius to pathfinding |

## Deferred Work
- [Feature]: Deferred to [Phase/Sprint] because [reason per scope_lock.md]
- [Refactor]: Not in sprint scope; current workaround is [description]

## Architecture Notes
- [Any important decision made about code structure, with rationale]
- [Any extension point added for future phases]

## Next Sprint Readiness
- [ ] All acceptance criteria passed
- [ ] No critical known issues
- [ ] Human approval required before advancing to [Next Sprint Name]
- [ ] BACKLOG.md updated
```

### 8.1 Output rules

- Use the exact section headers shown above.
- If a section has no content, write "None." — do not omit the section.
- "Files Changed" must include every file created, modified, or deleted.
- "Known Issues" must include every bug found during testing, even if minor.
- "Deferred Work" must cite `scope_lock.md` by name when explaining why something was skipped.

---

## 9. Code Quality Checklist

Before submitting the sprint report, verify:

- [ ] All new files follow `CONVENTIONS.md` naming and style.
- [ ] All new classes have `class_name` and `extends`.
- [ ] All functions have type hints.
- [ ] All `@export` variables are tunable without code changes.
- [ ] Signals are disconnected in `_exit_tree()` where applicable.
- [ ] No hardcoded world data inside UI scripts.
- [ ] No `print()` statements left from debugging (use `push_warning()` / `push_error()` if needed).
- [ ] Save/load serialization handles the new data.
- [ ] Project launches without errors in editor and headless.

---

## 10. Violation Consequences

If Kimi violates this protocol:

- **Scope violation**: Revert the offending files. Document the violation in the sprint report. Do not advance to next sprint until corrected.
- **Missing tests**: Sprint is not complete. Write tests before reporting.
- **Broad rewrite**: Human review required. Explain why the rewrite was necessary; if it was not, revert and redo minimally.
- **Failure to stop after sprint**: Human discards all post-sprint code. Kimi loses context of the extra work.

---

## 11. Protocol Update Rule

This document may be updated only by:

1. A human explicitly requesting a change.
2. A scope exception approved per `scope_lock.md` §5 that requires new execution rules.

Kimi does not self-update this protocol.
