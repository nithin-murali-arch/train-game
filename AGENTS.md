# AGENTS.md — Rail Empire

**Project:** Rail Empire  
**Engine:** Godot 4.6+ (GDScript)  
**Strategy:** Depth-first, one strategic layer per sprint

---

## Mandatory Pre-Flight Checklist

Before writing **any code** or modifying **any scene**, read these files in this exact order:

1. **`docs/design_bible.md`** — Creative vision, tone, pillars, scope boundaries
2. **`docs/design.md`** — Systems, data models, balance numbers, UI flows
3. **`docs/production_control_pack/scope_lock.md`** — What you are ALLOWED to build now vs what is FORBIDDEN
4. **`BACKLOG.md`** — Current sprint tasks, acceptance criteria, done criteria
5. **`CONVENTIONS.md`** — Naming, signals, scene structure, GDScript style
6. **`docs/production_control_pack/kimi_execution_protocol.md`** — How to report, when to stop, how to handle ambiguity

**Do not skip files.** If a file conflicts with another, `scope_lock.md` wins for build permissions, `design.md` wins for system behavior, `design_bible.md` wins for tone and creative direction.

---

## Document Index

### Creative & Product (Read First)
| File | Purpose | When to Read |
|------|---------|-------------|
| `docs/design_bible.md` | Tone, pillars, creative boundaries, faction canon | Every sprint start |
| `docs/design.md` | Implementation GDD: systems, balance, UI, testing checklists | Every sprint start |

### Production Control (Read Before Coding)
| File | Purpose | When to Read |
|------|---------|-------------|
| `docs/production_control_pack/scope_lock.md` | Current build target, forbidden features, phase gating, scope creep rejection | Every sprint start |
| `docs/production_control_pack/kimi_execution_protocol.md` | Agent operating procedure: how to stop, how to report, ambiguity protocol | Every sprint start |
| `BACKLOG.md` | Sprint tasks, acceptance criteria, done criteria, known issues | Every sprint start |
| `CONVENTIONS.md` | Naming, signals, autoloads, scene structure, save/load rules | When writing new files |

### Technical & Data (Read When Implementing Relevant System)
| File | Purpose | When to Read |
|------|---------|-------------|
| `docs/production_control_pack/technical_architecture.md` | Autoloads, scene hierarchy, signal contracts, tick order, manager responsibilities | When adding/modifying systems |
| `docs/production_control_pack/godot_project_setup.md` | Godot version, folder rules, input map, collision layers, TileMap layers, groups | When creating new scenes or nodes |
| `docs/production_control_pack/data_schema.md` | Exact field definitions for all Resource classes | When creating or modifying data |
| `docs/production_control_pack/save_schema.md` | Save file JSON structure, versioning, migration | When implementing save/load |

### Balance & UX (Read When Designing Features)
| File | Purpose | When to Read |
|------|---------|-------------|
| `docs/production_control_pack/balance_model.md` | Starting money, costs, prices, production rates, break-even targets | When adding economy features |
| `docs/production_control_pack/ux_flows.md` | Step-by-step UI flows for every player action | When building UI or input handling |
| `docs/production_control_pack/tutorial_spec.md` | Onboarding tutorials, tooltips, first-time player flow | When building Phase 1+ tutorials |

### QA & Testing (Read Before Sprint Completion)
| File | Purpose | When to Read |
|------|---------|-------------|
| `docs/production_control_pack/qa_test_plan.md` | Smoke tests, regression checklist, manual test scripts per system | Before declaring sprint done |
| `docs/production_control_pack/debug_tools.md` | Debug commands, cheats, inspection tools | When testing your own work |
| `docs/production_control_pack/performance_budget.md` | FPS targets, max entities, tick frequencies | When optimizing or stress-testing |

### Risk & Planning (Read When Estimating or Blocked)
| File | Purpose | When to Read |
|------|---------|-------------|
| `docs/production_control_pack/risk_register.md` | Top risks, severity, mitigations | When planning or when blocked |
| `docs/production_control_pack/playtest_plan.md` | What to test at each stage, metrics to collect | Before calling a phase complete |
| `docs/production_control_pack/release_plan.md` | Version naming, export targets, milestones | When preparing builds |

### Art & Assets (Read When Creating Visuals)
| File | Purpose | When to Read |
|------|---------|-------------|
| `docs/art_style_guide.md` | Visual direction, placeholder rules, AI asset pipeline | When creating or importing art |
| `docs/production_control_pack/asset_manifest.md` | Required assets list, filenames, sizes, ownership status | When producing assets |
| `docs/production_control_pack/accessibility_controls.md` | Colorblind safety, remapping, scaling, contrast | When polishing UI |

### Historical & Narrative (Read When Writing Text)
| File | Purpose | When to Read |
|------|---------|-------------|
| `docs/production_control_pack/historical_cultural_review.md` | Tone boundaries, colonial context, satire rules | When writing events, contracts, flavor text |
| `docs/production_control_pack/narrative_style_guide.md` | Voice, humor level, event card format, newspaper headlines | When writing any player-facing text |

---

## Hard Rules

### 1. Scope Lock
- **Current build target:** Colonial Bengal ONLY
- **Forbidden:** WW1, Sandbox, Campaign menu, full faction roster, advanced sabotage, stock market, global map, multiplayer, mod support, later eras
- **Exception process:** Formal `[SCOPE-REQUEST]` in BACKLOG.md with Feature Approval Test answers
- **Preparatory hooks allowed:** Passive data fields with zero gameplay effect only

### 2. Phase Gating
- Each phase (0–10) has exit criteria in `BACKLOG.md`
- Do NOT begin a new phase until the previous phase passes its exit criteria
- Human approval required before advancing phases

### 3. Never Implement Early
- Do not add features from future phases because "the structure is ready"
- Do not hardcode world data inside UI scripts
- Do not block development on final art
- Do not add new UI screens before the core loop is proven

### 4. Data-Driven Design
- All tunable parameters use `@export` on Resource classes
- City, cargo, train, event, contract, and technology data live in `data/` as `.tres` files
- Never hardcode balance numbers in gameplay scripts

### 5. Test Before Declaring Done
- Every sprint ends with manual smoke tests documented in `qa_test_plan.md`
- Run `godot --path . --headless` after every significant change
- Verify no console errors during normal play

### 6. Report Format
At sprint end, produce a report with these exact sections:
1. Files Changed
2. Systems Implemented
3. Manual Tests Performed
4. Acceptance Criteria Passed
5. Known Issues
6. Deferred Work
7. Architecture Notes
8. Next Sprint Readiness

---

## Quick Reference: What To Build Now

| Phase | Status | What To Build |
|-------|--------|--------------|
| 0 — Route Toy | Not started | 2 cities, 1 cargo, 1 train, track placement, basic profit |
| 1 — Colonial Core | Locked | Wait for Phase 0 exit criteria |
| 2 — Economic Depth | Locked | Wait for Phase 1 exit criteria |
| 3+ | Locked | Wait for prior phases |

---

## Quick Reference: Where To Put Things

| What | Where |
|------|-------|
| New script | `src/<system>/<name>.gd` |
| New scene | `scenes/<category>/<name>.tscn` |
| New Resource class | `src/resources/<name>_data.gd` |
| New data instance | `data/<category>/<name>.tres` |
| New art | `assets/<category>/<name>.png` |
| New autoload | `src/autoload/<name>.gd` + update `project.godot` |
| New docs | `docs/` or `docs/production_control_pack/` |

---

## Contact & Escalation

If documents conflict:
1. `scope_lock.md` wins for build permissions
2. `design.md` wins for system behavior
3. `design_bible.md` wins for tone and creative direction
4. If still ambiguous, ask rather than guess

If you discover a missing document that should exist, add a `[DOC-REQUEST]` task to `BACKLOG.md` and proceed with the smallest safe interpretation.
