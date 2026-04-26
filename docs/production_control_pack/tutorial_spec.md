# Rail Empire — Tutorial Specification

**Purpose:** Onboarding and progressive tutorial design. Defines exactly what the player learns, when, and how failure/success is handled.  
**Scope:** Colonial Bengal MVP (Phase 1) with forward-compatible hooks for Phase 2+.  
**Audience:** Tutorial implementers, UX designers, playtesters.

---

## Legend

| Term | Meaning |
|---|---|
| **Trigger** | Condition that causes the tutorial to appear. |
| **Goal** | What the player must understand or accomplish. |
| **Steps** | Numbered instructions shown to the player. |
| **Success Criteria** | How the game knows the tutorial is complete. |
| **Failure Handling** | What happens if the player cannot or will not complete the step. |
| **Skippable** | Can the player dismiss this tutorial permanently? |
| **Repeatable** | Can the tutorial be re-triggered later? |

---

## Global Tutorial Settings

| Setting | Value |
|---|---|
| **Tutorial enabled by default** | Yes |
| **Skip button position** | Top-right corner, small text link: "Skip Tutorial" |
| **Hint pulse interval** | Every 8 s if player idle on current step |
| **Auto-advance timeout** | 120 s per step; then gentler hint + target pulse |
| **Tutorial state storage** | Saved in player profile (not per-save); can be reset from Settings |
| **Overlay color** | Semi-transparent black (`#000000` at 60% alpha) |
| **Highlight border** | 2 px gold (`#D4AF37`) dashed animated rectangle around target |
| **Text box style** | Bottom-center, max 2 lines, white text, dark panel background |

---

## Tooltip System (Global)

**Purpose:** Hover explanations for all UI elements. Active at all times, not tied to tutorial progress.

### Trigger
Player hovers cursor over any interactive UI element or map entity for ≥ 0.4 s.

### Behavior
| Element Type | Tooltip Content |
|---|---|
| **HUD — Treasury** | "Your company funds. Track construction, train purchases, and penalties are deducted here. Revenue and rewards are added." |
| **HUD — Date** | "Current in-game date. Economy ticks run daily. Contract deadlines use this calendar." |
| **HUD — Speed Button** | "Pause, 1×, 2×, or 4× game speed. Use faster speeds while waiting for deliveries." |
| **HUD — Objective** | "Current scenario or campaign goal. Completing objectives unlocks new cities and systems." |
| **Build Menu — Track Tool** | "Build rail track between cities or extend your network. Cost varies by terrain." |
| **Build Menu — Cancel Tool** | "Pan the camera and inspect cities or trains." |
| **Build Menu — Train Purchase** | "Buy a new locomotive. Trains spawn at your starting city or a connected hub." |
| **Build Menu — Station Upgrade** | "Improve a city’s station. Unlocks after completing Tutorial 2." (Phase 2+) |
| **City Marker** | City name, role, and one-line summary: "Kolkata — Port metropolis. Demands coal and grain." |
| **Train Sprite** | Train name, current state (Idle/Loading/Traveling), cargo carried, destination if assigned. |
| **Track Segment** | Length, terrain type, owner (if rival phase active), condition (if maintenance phase active). |
| **Cargo Row (in panel)** | Cargo name, base price, current price, stock level, and demand trend (↑ ↓ →). |
| **Contract Row** | Reward, deadline, and one-line risk assessment: "Tight deadline — use a fast train." |

### Edge Cases
- Tooltip does not appear if a modal dialog is open.
- Tooltip dismissed immediately on cursor move off target.
- On controller (future): tooltip appears on focus hold for 0.6 s.

---

## Tutorial 1: First Coal Route

**Unlocks:** Immediately on first launch of Colonial Bengal scenario.  
**Phase Requirement:** Route Toy (Phase 0) minimum; Colonial Core (Phase 1) preferred.

### Trigger
- Player starts a new game AND tutorial has not been completed/skipped before.
- Game begins paused with camera centered on Kolkata.

### Goal
Teach the absolute minimum loop: build track, buy train, assign route, deliver cargo.

### Step-by-Step Instructions

| Step | Instruction Text | Target Highlight | Input Blocked Except |
|---|---|---|---|
| 1 | "Welcome to Rail Empire. Let’s build your first railway. Click the Track Tool." | Bottom bar — Track Tool button | Track Tool button |
| 2 | "Good. Every route needs a starting city. Click Kolkata." | Map — Kolkata city marker | Kolkata marker |
| 3 | "Now choose where the track will end. Click Patna." | Map — Patna city marker | Patna marker |
| 4 | "Track built. Now you need a train. Click the Train Purchase button." | Bottom bar — Train Purchase button | Train Purchase button |
| 5 | "Buy a Freight Engine — it’s built for hauling coal." | Train Purchase Panel — Freight Engine row | Freight Engine row + Confirm |
| 6 | "Your train is ready in Kolkata. Click it." | Map — newly spawned train sprite | Train sprite |
| 7 | "Assign a route: first click Kolkata to load cargo." | Map — Kolkata city marker | Kolkata marker |
| 8 | "Now click Patna to set the destination." | Map — Patna city marker | Patna marker |
| 9 | "Route set. Click the play button to unpause and watch your train go." | HUD — 1× speed button | Speed buttons only |
| 10 | "Your train will load coal, travel to Patna, and sell it. Come back when you’ve earned some money." | None (overlay fades) | All input unblocked |

### Success Criteria
- Track exists between Kolkata and Patna (bidirectional graph edges).
- Player owns at least one train.
- That train has assigned route `[Kolkata, Patna]`.
- Cumulative coal delivered to Patna ≥ 100 tons.

### Completion Feedback
- Toast: "Tutorial complete: First Coal Route."
- Treasury bonus: +₹1,000 (softens early learning curve).
- Unlocks: Tutorial 2 trigger conditions now active.

### Failure Handling
- **Player cancels track build:** Tutorial pauses. When player re-enters Track Tool, tutorial resumes at Step 2.
- **Player runs out of money:** If treasury < track cost + train cost, tutorial grants emergency ₹5,000 loan (no repayment mechanic in tutorial) and shows: "Here’s a small loan to get you started."
- **Player skips:** Tutorial 1 marked complete but no bonus given. Player can retry via Settings → Tutorials.

### Skippable: Yes
### Repeatable: Yes (via Settings menu)

---

## Tutorial 2: Reading Supply and Demand

**Unlocks:** After Tutorial 1 complete AND player has delivered ≥ 100 coal.  
**Phase Requirement:** Colonial Core (Phase 1).

### Trigger
- Player clicks any city marker for the first time after Tutorial 1 completes.

### Goal
Teach the player to read city panels, understand produced vs. demanded cargo, and interpret prices.

### Step-by-Step Instructions

| Step | Instruction Text | Target Highlight | Input Blocked Except |
|---|---|---|---|
| 1 | "Cities produce and demand different cargo. Click Patna to inspect it." | Map — Patna city marker | Patna marker |
| 2 | "Patna produces Coal — that’s the supply. It demands Textiles and Grain." | City Panel — Produced section | City Panel close button (delayed 3 s) |
| 3 | "Prices change based on supply and demand. Hover over Coal to see the details." | City Panel — Coal row | Cargo row hover only |
| 4 | "When stock is low and demand is high, prices rise. When stock piles up, prices fall." | Tooltip on Coal | — |
| 5 | "Close the panel and open Kolkata. Compare its prices." | City Panel — Close button; then Kolkata marker | Close button, then Kolkata |
| 6 | "Kolkata demands Coal but doesn’t produce it. That’s why your route is profitable." | City Panel — Coal demand row | City Panel close button (delayed 3 s) |
| 7 | "Find a cargo that one city produces and another demands. That’s your next route." | None | All input unblocked |

### Success Criteria
- Player has opened at least 2 distinct city panels.
- Player has hovered at least 2 cargo rows to view tooltips.
- Time since trigger ≥ 30 s (ensures reading, not just clicking through).

### Completion Feedback
- Toast: "Tutorial complete: Reading Supply and Demand."
- Unlocks: Tutorial 3 trigger; Station Upgrade button tooltip updates to active.

### Failure Handling
- **Player closes panel too fast at Step 2 or 6:** Countdown pauses; panel reopens automatically with gentler pulse after 4 s.
- **Player never hovers cargo row:** After 60 s idle, tooltip auto-appears on Coal row with arrow pointer.

### Skippable: Yes
### Repeatable: Yes

---

## Tutorial 3: Train Types

**Unlocks:** After Tutorial 2 complete AND treasury ≥ ₹10,000.  
**Phase Requirement:** Colonial Core (Phase 1).

### Trigger
- Treasury crosses ₹10,000 threshold for the first time after Tutorial 2.
- Toast appears: "You can now afford a new train type."

### Goal
Teach the tradeoff between Freight Engine (high capacity, slow, cheap) and Mixed Engine (lower capacity, fast, expensive).

### Step-by-Step Instructions

| Step | Instruction Text | Target Highlight | Input Blocked Except |
|---|---|---|---|
| 1 | "You’ve earned enough to expand. Let’s look at a different train. Open Train Purchase." | Bottom bar — Train Purchase button | Train Purchase button |
| 2 | "This is the Mixed Engine. It’s faster but carries less and costs more to maintain." | Train Purchase Panel — Mixed Engine row | Mixed Engine row hover |
| 3 | "Compare the stats. Freight = 200 tons, slow. Mixed = 100 tons, fast. Same route, different economics." | Side-by-side comparison tooltip | — |
| 4 | "Buy a Mixed Engine for a shorter, faster route — like Kolkata to Dacca." | Train Purchase Panel — Confirm button | Mixed Engine Confirm |
| 5 | "Assign it to a route and see how the speed affects delivery time." | Map — new Mixed Engine sprite | Train sprite, then route assignment flow |

### Success Criteria
- Player owns at least one Mixed Engine.
- Mixed Engine has been assigned to any route.
- Mixed Engine completes at least one delivery.

### Completion Feedback
- Toast: "Tutorial complete: Train Types."
- Treasury bonus: +₹500.

### Failure Handling
- **Player buys Freight instead of Mixed:** Tutorial adapts. Text changes to: "Freight is still a solid choice. Next time, try a Mixed Engine for comparison." Success criteria relax to "own 2+ trains of any type."
- **Player runs out of money before purchase:** Trigger re-arms when treasury ≥ ₹10,000 again.

### Skippable: Yes
### Repeatable: Yes

---

## Tutorial 4: Route Profitability

**Unlocks:** After Tutorial 3 complete AND player has built ≥ 2 routes.  
**Phase Requirement:** Colonial Core (Phase 1).

### Trigger
- Player opens the Route Preview Panel for the 3rd+ time.

### Goal
Teach the player to read the Route Preview Panel and understand break-even analysis.

### Step-by-Step Instructions

| Step | Instruction Text | Target Highlight | Input Blocked Except |
|---|---|---|---|
| 1 | "Before you build, check the numbers. This panel shows if a route will make money." | Route Preview Panel (auto-opened) | — |
| 2 | "Construction cost is what you pay now. Break-even trips tell you how many deliveries to recover it." | Route Preview Panel — Break-even line | — |
| 3 | "Hover the break-even number. It compares your train’s capacity to the destination price and upkeep." | Route Preview Panel — Break-even value | Hover only |
| 4 | "If break-even is more than 20 trips, the route may be too long or the cargo too cheap." | Tooltip explanation | — |
| 5 | "Build this route only if you’re happy with the numbers — or cancel and try another." | Confirm and Cancel buttons | Confirm or Cancel |

### Success Criteria
- Player has viewed the Route Preview Panel ≥ 3 times.
- Player has cancelled at least one route preview (demonstrates evaluation).
- Player has confirmed at least one route with break-even ≤ 20 trips.

### Completion Feedback
- Toast: "Tutorial complete: Route Profitability."
- Unlocks: Advanced tooltip on break-even line shows formula details.

### Failure Handling
- **Player confirms high break-even route (> 20 trips):** Tutorial shows warning overlay: "This route will take a long time to pay off. Are you sure?" Player can proceed; tutorial still completes but notes "Risk-taker profile" internally (future analytics hook).
- **Player never cancels a preview:** After 5th preview, tutorial adds extra text: "Tip: You can cancel if the numbers look bad."

### Skippable: Yes
### Repeatable: Yes

---

## Tutorial 5: Maintenance

**Unlocks:** After Tutorial 4 complete AND in-game day ≥ 15 (enough time for daily maintenance to accumulate visibly).  
**Phase Requirement:** Colonial Core (Phase 1) minimum; Economic Depth (Phase 2) for station upgrades.

### Trigger
- First daily maintenance tick that reduces treasury by ≥ ₹50 (first Freight Engine upkeep) after Tutorial 4.

### Goal
Teach the player that trains cost money every day, not just upfront.

### Step-by-Step Instructions

| Step | Instruction Text | Target Highlight | Input Blocked Except |
|---|---|---|---|
| 1 | "Notice your treasury dropped. Trains cost money every day to maintain." | HUD — Treasury (flashes red briefly) | — |
| 2 | "Click your Freight Engine to see its daily upkeep." | Map — Freight Engine sprite | Train sprite |
| 3 | "₹50 per day. That’s ₹1,500 per month — per train. More trains = more upkeep." | Train Panel — Maintenance line | — |
| 4 | "If a train isn’t profitable, it’s draining your company. Consider selling or re-routing." | Train Panel — Last trip profit line | — |
| 5 | "Later you can build a Maintenance Shed to reduce these costs. For now, keep an eye on profit." | None (overlay fades) | All input unblocked |

### Success Criteria
- Player has opened Train Panel for an owned train after maintenance has ticked ≥ 3 times.
- Player has seen negative or low last-trip profit on at least one train.

### Completion Feedback
- Toast: "Tutorial complete: Maintenance."
- Treasury bonus: +₹1,000 (covers ~20 days of one train’s upkeep).

### Failure Handling
- **Player has only profitable trains:** Tutorial still triggers on upkeep tick. Step 4 adapts: "Your trains are doing well — but imagine if coal prices dropped."
- **Player sells all trains before trigger:** Trigger re-arms when player buys a new train and 3+ days pass.

### Skippable: Yes
### Repeatable: Yes

---

## Tutorial Completion Summary

| Tutorial | Unlocks | Bonus | Required Phase |
|---|---|---|---|
| 1 — First Coal Route | Tutorial 2 | +₹1,000 | Phase 0 |
| 2 — Supply and Demand | Tutorial 3 | — | Phase 1 |
| 3 — Train Types | Tutorial 4 | +₹500 | Phase 1 |
| 4 — Route Profitability | Tutorial 5 | — | Phase 1 |
| 5 — Maintenance | Free play | +₹1,000 | Phase 1 |

**Total tutorial bonus:** +₹2,500 (softens early game without breaking balance).

---

## Settings: Tutorial Controls

Accessible from Main Menu → Settings → Gameplay.

| Option | Default | Behavior |
|---|---|---|
| **Tutorials Enabled** | On | If Off, no tutorials trigger. Existing progress preserved. |
| **Reset Tutorials** | Button | Marks all tutorials incomplete. Next new game restarts from Tutorial 1. |
| **Repeat Tutorial** | Dropdown | Player can re-run any completed tutorial in a practice environment (isolated sandbox with preset state). |
| **Hint Frequency** | Normal | Choices: Off / Normal / Frequent. Affects pulse interval and auto-advance timeout. |

---

## Appendix: Tutorial State Schema

Stored in player profile (`user://tutorial_state.json`):

```json
{
  "tutorials_enabled": true,
  "hint_frequency": "normal",
  "tutorials": {
    "tutorial_01": { "completed": true, "skipped": false, "step_reached": 10 },
    "tutorial_02": { "completed": false, "skipped": false, "step_reached": 3 },
    "tutorial_03": { "completed": false, "skipped": false, "step_reached": 0 },
    "tutorial_04": { "completed": false, "skipped": false, "step_reached": 0 },
    "tutorial_05": { "completed": false, "skipped": false, "step_reached": 0 }
  }
}
```

Note: Tutorial state is **profile-scoped**, not save-scoped. A player who completes tutorials in one campaign should not see them again in a new campaign unless they explicitly reset.
