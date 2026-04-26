# Rail Empire — Scope Lock

Version: 1.0  
Authority: Overrules any contradictory scope statements in `design.md`, `BACKLOG.md`, or conversation history.  
Companion: `kimi_execution_protocol.md`

---

## 1. Purpose

This document resolves the tension between the **depth-first build order** (design.md §3) and older broad-MVP language that may still exist in the backlog or conversation history.

**The only source of truth for what Kimi may build right now is this file combined with the currently active sprint in `BACKLOG.md`.**

---

## 2. Current Build Target: Colonial Bengal ONLY

Kimi is authorized to build **only** systems, content, and UI required for the Colonial Bengal region.

### 2.1 What IS in scope (active sprints)

| Layer | Status | Content |
|-------|--------|---------|
| Route Toy | In progress (Sprint 01) | 2 cities, 1 cargo, 1 train, no AI, no events |
| Colonial Bengal Core Loop | Planned (Sprint 02) | 4 cities, 3 cargo, 2 trains, terrain, pricing, save/load |
| Economic Depth | Planned (Sprint 03) | 5–6 cities, 4 cargo, contracts, station upgrades, tech shop |
| First Rival Pressure | Planned (Sprint 04) | British East India Rail AI only |
| Network Control | Planned (Sprint 05) | Ownership, tolls, access modes, maintenance |
| Events & Disruption | Planned (Sprint 06) | 4 Colonial events only |
| Colonial Campaign | Planned (Sprint 07) | `Bengal Railway Charter` 5-act campaign |

### 2.2 What is NOT in scope (locked out)

The following features, systems, content, or modes **must not be implemented** regardless of how "ready" the codebase feels:

| Feature | Lock Reason | Earliest Phase |
|---------|-------------|--------------|
| **WW1 era** | Requires proven Colonial loop + campaign | Phase 8 (Sprint 09) |
| **Sandbox mode** | Requires all core systems proven | Phase 9 (Sprint 10) |
| **Campaign menu / mode selection screen** | Campaign structure comes after loop is deep | Phase 9 (Sprint 10) |
| **Full faction roster** | Only British AI is authorized; French MAY be added in Sprint 05 if British is stable | Phase 7 (Sprint 08) for full roster |
| **Advanced sabotage / counter-intelligence** | Design smell: turns logistics into pseudo-combat | Post-launch if ever |
| **Stock market system** | Explicitly listed as "not this game" in design bible §16 | Post-launch if ever |
| **Global map / multiple regions** | India-first rule; Bengal must be deep before Punjab, Bombay, or Madras are added | Post-Phase 10 |
| **Multiplayer** | Single-player only until core loop is proven | Post-launch if ever |
| **Mod support** | Requires stable data pipeline and finalized formats | Post-launch if ever |
| **WW2, Cold War, Modern, WW3 eras** | Deferred indefinitely in backlog | Not planned |
| **3D camera rotation** | 2D isometric only | Not planned |
| **Real-time weather shaders** | Visual polish deferred to Phase 10 | Not planned |
| **Scenario mode** | Packaging layer; requires campaign proven | Phase 9 (Sprint 10) |
| **Portuguese, IRCTC, Amboney, Tota, Mahendra factions** | Long-term roster only | Post-Phase 10 |
| **Passenger/luxury cargo focus** | French faction flavor; irrelevant until factions exist | Phase 7 (Sprint 08) |
| **Government requisition mechanics** | WW1-era system | Phase 8 (Sprint 09) |
| **Era transition system** | Requires at least two proven eras | Phase 8 (Sprint 09) |

---

## 3. Phase Gating Rule

**No phase may begin until the previous phase has passed its exit criteria.**

### 3.1 Exit criteria are mandatory

| Phase | Exit Criteria (from design.md) | Gatekeeper |
|-------|-------------------------------|------------|
| 0 Route Toy | Player can build track, buy train, assign route, deliver cargo, earn money without debug intervention. | Human review + smoke test |
| 1 Colonial Core | Player plays meaningful 20+ min session, expands 1→3+ routes, makes strategic trade-offs. | Human playtest |
| 2 Economic Depth | Game is interesting without rivals because economy creates meaningful optimization decisions. | Human playtest |
| 3 First Rival | Rival creates pressure without feeling random, unfair, or opaque. | Human playtest |
| 4 Network Control | Player wins/loses through infrastructure control, not just train count. | Human playtest |
| 5 Events | Events make runs feel different and encourage planning without arbitrary failure. | Human playtest |
| 6 Colonial Campaign | Colonial Bengal stands alone as a satisfying small game. | Human review |
| 7+ | TBD at campaign retrospective | Human decision |

### 3.2 What passing means

- All acceptance criteria in `BACKLOG.md` for the sprint are checked.
- Manual test steps exist and pass.
- No console errors during normal play.
- Code follows `CONVENTIONS.md`.
- **Human explicitly approves advancement** — Kimi does not self-promote to the next phase.

---

## 4. Scope Creep: Definition and Rejection

### 4.1 What constitutes scope creep

Any of the following, when proposed during an active sprint, is scope creep:

1. **Pre-implementation**: Adding a feature from a later phase because "the structure is ready."
2. **Speculative generalization**: Building a system to handle 8 factions when only 1 is needed now.
3. **Future-proofing data**: Adding `era_id` arrays with WW1/WW2 entries before those eras are scoped.
4. **Content padding**: Adding a 5th city in Sprint 02 because "it would be easy."
5. **UI overbuilding**: Creating a campaign selection menu before the campaign exists.
6. **Mechanic drift**: Adding stock-market-like speculation UI, combat-adjacent sabotage, or real-time train-driving controls.
7. **Art blocking**: Refusing to merge a system because placeholder art is "too ugly."

### 4.2 How to reject scope creep

When Kimi encounters scope creep — whether in a prompt, a task description, or its own suggestion — it must:

1. **Stop** and identify the creeping feature by name.
2. **Reference** this document and the phase it belongs to.
3. **State** the smallest implementation that satisfies the current sprint.
4. **Defer** the extra work with a note in the sprint report's "Deferred work" section.
5. **Proceed** with the minimal version.

Example rejection:

> "Adding toll calculation to Sprint 02 is scope creep. Tolls are Phase 4 (Network Control). I will implement track ownership storage in `TrackEdgeState` as a passive string field so Phase 4 can use it, but I will not implement toll logic, UI, or AI toll behavior."

---

## 5. Exception Process: How to Request a Scope Change

If a stakeholder believes a locked-out feature should enter scope early:

### 5.1 Required information

The request must answer the Feature Approval Test (design bible §18):

1. Which design pillar does it deepen?
2. What decision does it create for the player?
3. What information does the UI need to explain it?
4. What is the smallest implementation that proves it?
5. What should be postponed to make room?

### 5.2 Escalation path

1. **Write** a scope-change proposal as a new task in `BACKLOG.md` under the current sprint, tagged `[SCOPE-REQUEST]`.
2. **State** which locked feature is being requested and which active task it would replace or delay.
3. **Wait** for human approval before implementation.
4. **If approved**, update this `scope_lock.md` to reflect the temporary exception and the reason.

### 5.3 Kimi's role

Kimi **does not** self-approve scope changes. If a prompt asks Kimi to implement a locked-out feature, Kimi must:

- Acknowledge the request.
- Cite the lock.
- Ask for explicit human override.
- Offer to implement the smallest preparatory hook (e.g., a data field) if it does not expand behavior.

---

## 6. Preparatory Hooks (Allowed)

Kimi MAY add passive data fields or empty extension points if they have **zero gameplay effect** now and prevent rewrite later.

| Allowed Hook | Example | Forbidden Behavior |
|--------------|---------|-------------------|
| `owner_faction_id: String = "player"` in `TrackEdgeState` | Stores ownership without enforcing it | Toll logic, access blocking, AI reaction |
| `era_ids: PackedStringArray = ["colonial"]` in `CargoData` | Tags content for future filtering | Era transition logic, era-specific unlocks |
| `condition: float = 1.0` in `TrackEdgeState` | Stores health value | Degradation ticks, repair UI, speed penalties |
| Empty `EventData` Resource class | Data structure exists | Event trigger system, warning UI, effect application |

**Rule of thumb**: If the hook requires new UI, new AI behavior, or new player-facing rules, it is not a hook — it is scope creep.

---

## 7. Document Update Rule

If a scope exception is approved, or if a phase is completed and the next phase begins:

1. Update `BACKLOG.md` to mark the completed sprint as done.
2. Update this `scope_lock.md` to move the newly active phase into "Current Build Target" and downgrade the completed phase to "Locked (completed)."
3. Do not delete locked-out features from this document — strike through or move to a "Completed / Unlocked" section for auditability.

---

## 8. Canonical Summary

> Right now, Rail Empire is a single-region, single-era, single-player railway tycoon set in Colonial Bengal. Kimi may build track, trains, cargo, cities, economy, one rival AI, events, and a campaign — in that order. Nothing else enters scope without human approval documented in this file.
