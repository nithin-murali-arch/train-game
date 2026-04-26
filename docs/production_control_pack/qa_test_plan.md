# Rail Empire — QA Test Plan

Version: 0.1  
Engine: Godot 4.2+  
Game: Rail Empire (isometric 2D railway tycoon)  
Purpose: Execution-level QA and manual testing procedures  

---

## 1. Test Environment Spec

### 1.1 Minimum Reference Environment

| Component | Spec |
|---|---|
| Godot version | 4.2.x stable (matching `project.godot`) |
| OS | Windows 10/11, macOS 13+, or Ubuntu 22.04+ |
| CPU | 4-core x64 |
| RAM | 8 GB |
| GPU | Integrated graphics acceptable for 2D |
| Display | 1920×1080, 60 Hz |
| Input | Mouse + keyboard |

### 1.2 Additional Test Targets

| Target | When to Test |
|---|---|
| Web export (Chrome, Firefox, Safari) | After Sprint 02, and before any public build |
| 4K display | Sprint 10 UI polish |
| Trackpad-only input | Sprint 10 accessibility pass |

### 1.3 Debug Overrides

Use `project.godot` `--debug` flag or a `debug_overlay` autoload to expose:
- TrackGraph node/edge counts
- Active train state machines
- Economy tick timing
- Event roll probabilities

---

## 2. Sprint Smoke Tests (Generic Template)

Run this checklist at the end of **every sprint** before merge.

### 2.1 Launch Smoke

| # | Step | Expected Result |
|---|---|---|
| SM-01 | Launch game from exported build or `godot --path .` | Main scene loads without crash |
| SM-02 | Verify no errors in Output panel (Godot editor) or stdout (export) | Zero red errors; yellow warnings documented |
| SM-03 | Verify no orphaned nodes after 30 seconds of gameplay | `Performance.get_monitor(Performance.OBJECT_NODE_COUNT)` stable |
| SM-04 | Press Escape / Pause button | Game pauses; time stops; UI responsive |
| SM-05 | Resume from pause | Game resumes; trains continue from correct state |

### 2.2 Core Loop Smoke

| # | Step | Expected Result |
|---|---|---|
| SM-10 | Start new game / scenario | Player treasury set to configured starting value (e.g., ₹20,000) |
| SM-11 | Pan camera (WASD or drag) | Camera moves smoothly; stays inside bounds |
| SM-12 | Zoom camera (scroll wheel) | Zoom clamps between min/max; no jitter |
| SM-13 | Click a city | City panel opens; data visible |
| SM-14 | Build one track segment | Treasury decreases; segment visible; graph updated |
| SM-15 | Buy one train | Train spawns; treasury decreases |
| SM-16 | Assign route | Train enters Loading → Traveling → Unloading loop |
| SM-17 | Wait for delivery | Treasury increases; last trip profit recorded |

### 2.3 Save/Load Smoke

| # | Step | Expected Result |
|---|---|---|
| SM-20 | Save game mid-session | Save file created; no errors |
| SM-21 | Quit to menu | Clean unload; no orphaned nodes |
| SM-22 | Load saved game | All tracks, trains, treasury, date, city stocks restored |
| SM-23 | Verify train resumes movement | Train continues along path or recomputes valid route |

---

## 3. Regression Checklist

Verify these did **not** break after any code change.

### 3.1 Critical Path Regression

- [ ] Camera pan/zoom still works after UI panel opens/closes.
- [ ] Track can still be built after loading a save.
- [ ] Trains still pathfind after TrackGraph node/edge additions or removals.
- [ ] Economy tick still fires daily at all game speeds (1×, 2×, 4×).
- [ ] Treasury never goes negative from construction or purchase (blocked if insufficient funds).
- [ ] City panel prices match HUD tooltip prices.
- [ ] Save from previous sprint still loads, or graceful migration message appears.

### 3.2 Cross-System Regression

- [ ] Track placement does not desync TrackRenderer and TrackGraph.
- [ ] Train arrival signal still triggers Transaction and Contract progress.
- [ ] Event effects apply to correct cities/tracks and clean up after duration.
- [ ] AI expansion does not corrupt player TrackGraph or block player pathfinding.
- [ ] Technology patent bonuses apply only to winner; expire correctly.
- [ ] Tolls deduct from correct treasury and add to owner treasury.

### 3.3 UI Regression

- [ ] All panels close with Escape or X button.
- [ ] Tooltips update when underlying data changes.
- [ ] HUD updates immediately after construction, purchase, or delivery.
- [ ] No UI element blocks map clicks when hidden.

---

## 4. Manual Test Scripts

### 4.1 TrackGraph System

#### TC-TG-01: Node Creation and Edge Connectivity

| Field | Content |
|---|---|
| **Preconditions** | Fresh game start. No track built. |
| **Steps** | 1. Click Kolkata city marker.<br>2. Click Patna city marker.<br>3. Confirm build. |
| **Expected result** | TrackGraph contains 2 nodes (Kolkata grid, Patna grid) and 1 edge. Edge `from_node` and `to_node` match node IDs. Edge `length_km` > 0. |
| **Pass criteria** | `TrackGraph.nodes.size() == 2` and `TrackGraph.edges.size() == 1`. Visual line rendered. |
| **Fail criteria** | Mismatch between graph and rendered track; missing node; zero-length edge. |

#### TC-TG-02: Pathfinding with Terrain Cost

| Field | Content |
|---|---|
| **Preconditions** | Track exists Kolkata → Hills tile → Patna. Hills terrain cost = 2.0. |
| **Steps** | 1. Query path from Kolkata to Patna.<br>2. Compare path cost to flat terrain baseline. |
| **Expected result** | Path returns ordered node IDs `[Kolkata, hill_node, Patna]`. Path cost > flat equivalent. |
| **Pass criteria** | Path cost equals sum of `length_km × terrain_cost_multiplier` for each edge. |
| **Fail criteria** | Path ignores terrain multiplier; path missing; infinite loop. |

#### TC-TG-03: Ownership and Private Access

| Field | Content |
|---|---|
| **Preconditions** | AI owns track segment A→B set to `access_mode = "private"`. Player does not own it. |
| **Steps** | 1. Query path for player train from A to B. |
| **Expected result** | Path excludes private edge. If no alternate route, returns empty array. |
| **Pass criteria** | Player train cannot path through private AI track. AI train can. |
| **Fail criteria** | Player train paths through private edge; crash on ownership check. |

#### TC-TG-04: Track Condition and Degradation

| Field | Content |
|---|---|
| **Preconditions** | Track built 10+ game days ago. Daily degradation active. |
| **Steps** | 1. Inspect edge `condition` field.<br>2. Wait 5 more days.<br>3. Re-inspect. |
| **Expected result** | `condition` decreased by `base_rate × terrain_modifier × traffic_modifier × 5`. Condition clamped ≥ 0.0. |
| **Pass criteria** | Condition decreases predictably; never negative; path cost increases if condition_penalty applied. |
| **Fail criteria** | Condition stuck at 1.0; negative condition; NaN value. |

---

### 4.2 Train Movement System

#### TC-TR-01: Interpolation Along Path

| Field | Content |
|---|---|
| **Preconditions** | Train assigned to route Kolkata → Patna. Track exists. Game unpaused. |
| **Steps** | 1. Observe train at origin.<br>2. Wait for train to travel.<br>3. Observe arrival. |
| **Expected result** | Train interpolates between grid nodes using `Node2D` position. Arrives at Patna within predictable time based on `speed_km_per_hour` and edge lengths. |
| **Pass criteria** | Train position is always on or near track line. Arrival signal fires once. |
| **Fail criteria** | Train drifts off line; teleportation; duplicate arrival signals. |

#### TC-TR-02: State Machine Transitions

| Field | Content |
|---|---|
| **Preconditions** | Train on assigned loop route. |
| **Steps** | 1. Watch train through one full cycle. |
| **Expected result** | State sequence: `Idle` → `Loading` → `Traveling` → `Unloading` → `Loading` → ... |
| **Pass criteria** | No invalid transitions (e.g., `Traveling` → `Idle` without arrival). Loading/unloading durations > 0 if configured. |
| **Fail criteria** | Stuck in one state; skipped states; rapid invalid transitions. |

#### TC-TR-03: Cargo Loading Rules

| Field | Content |
|---|---|
| **Preconditions** | Origin city has Coal (200 tons) and Grain (50 tons). Train capacity = 100 tons. |
| **Steps** | 1. Assign train to route with auto-load.<br>2. Observe cargo at departure. |
| **Expected result** | Train loads highest-profit available cargo up to capacity. If profit equal, larger stock wins. |
| **Pass criteria** | `cargo_quantity ≤ cargo_capacity_tons`. `cargo_type_id` set. Origin stock reduced. |
| **Fail criteria** | Overload; negative stock; no cargo loaded when stock exists. |

#### TC-TR-04: Breakdown State

| Field | Content |
|---|---|
| **Preconditions** | Train `condition` < breakdown threshold or random breakdown triggered. |
| **Steps** | 1. Trigger breakdown via debug command or wait for random failure.<br>2. Observe state.<br>3. Wait for repair or pay repair cost. |
| **Expected result** | Train enters `BrokenDown`. Stops moving. Repair cost deducted from treasury. Returns to `Idle` or `Loading` after repair duration. |
| **Pass criteria** | No movement during breakdown. Treasury change correct. State resumes correctly. |
| **Fail criteria** | Train moves while broken; repair cost not deducted; stuck permanently. |

---

### 4.3 Economy System

#### TC-EC-01: Delivery Transaction

| Field | Content |
|---|---|
| **Preconditions** | Train carries 100 tons Coal to Kolkata. Kolkata Coal price = ₹30/ton. |
| **Steps** | 1. Let train arrive and unload.<br>2. Check treasury before and after. |
| **Expected result** | Revenue = 100 × 30 = ₹3,000. Treasury increases by ₹3,000. Destination stock increases by 100. |
| **Pass criteria** | Treasury delta exactly equals revenue. `last_trip_revenue` updated. |
| **Fail criteria** | Wrong amount; double credit; no credit; stock desync. |

#### TC-EC-02: Maintenance Deduction

| Field | Content |
|---|---|
| **Preconditions** | Player owns 2 trains. Daily maintenance = ₹50 + ₹80 = ₹130/day. |
| **Steps** | 1. Note treasury at day start.<br>2. Advance one day.<br>3. Check treasury. |
| **Expected result** | Treasury decreased by ₹130 at economy tick. Event log shows maintenance line. |
| **Pass criteria** | Deduction equals sum of owned train maintenance. No deduction for sold/broken trains. |
| **Fail criteria** | Double deduction; missing deduction; deduction for non-owned trains. |

#### TC-EC-03: Toll Payment

| Field | Content |
|---|---|
| **Preconditions** | Player train uses AI-owned edge. Toll = ₹2/km. Edge length = 10 km. |
| **Steps** | 1. Train travels edge.<br>2. Check player and AI treasuries. |
| **Expected result** | Player treasury −= ₹20. AI treasury += ₹20. `last_trip_cost` includes toll. |
| **Pass criteria** | Exact ₹20 transfer. No loss or creation of money. |
| **Fail criteria** | Toll not applied; wrong amount; money created from nothing. |

#### TC-EC-04: Route Profitability Preview

| Field | Content |
|---|---|
| **Preconditions** | Player selecting new route Kolkata → Dacca. |
| **Steps** | 1. Open route preview panel.<br>2. Verify displayed values. |
| **Expected result** | Preview shows: construction cost, expected cargo, destination price, expected revenue, maintenance estimate, toll estimate, net profit, break-even trips. |
| **Pass criteria** | All fields populated with plausible numbers. Break-even ≥ 1 if profit > 0. |
| **Fail criteria** | Missing fields; impossible negative break-even; values desynced from actual economy. |

---

### 4.4 City Economy System

#### TC-CE-01: Daily Production and Consumption

| Field | Content |
|---|---|
| **Preconditions** | City produces Coal 50/day; demands Grain 30/day. Stock: Coal 100, Grain 20. |
| **Steps** | 1. Advance one day.<br>2. Inspect city economy state. |
| **Expected result** | Coal stock = 150. Grain stock = max(0, 20 − 30) = 0. |
| **Pass criteria** | Stock changes by exact production/consumption values. No negative stock. |
| **Fail criteria** | Negative stock; wrong deltas; production/consumption not applied. |

#### TC-CE-02: Dynamic Pricing Formula

| Field | Content |
|---|---|
| **Preconditions** | Coal base price = ₹15. City stock = 100; demand = 50. |
| **Steps** | 1. Calculate expected price.<br>2. Compare to in-game price. |
| **Expected result** | Price = 15 × (1 + (50 − 100) / (50 + 100 + 1)) = 15 × (1 − 50/151) ≈ ₹10.03 → clamped to ₹7.5 (0.5× base). |
| **Pass criteria** | In-game price within rounding tolerance of formula. Clamped to [0.5×, 2.0×] base. |
| **Fail criteria** | Price outside clamp range; divide-by-zero crash; price stuck at base. |

#### TC-CE-03: Saturation Warning

| Field | Content |
|---|---|
| **Preconditions** | City stock of Textiles > 2× demand. |
| **Steps** | 1. Inspect city panel.<br>2. Look for saturation indicator. |
| **Expected result** | Saturation warning visible (tooltip, icon, or color). Price at or near floor. |
| **Pass criteria** | Warning appears when stock > 2× demand. Disappears when stock normalizes. |
| **Fail criteria** | No warning; warning persists incorrectly; crash on threshold check. |

#### TC-CE-04: Station Upgrades

| Field | Content |
|---|---|
| **Preconditions** | City has no upgrades. Player treasury ≥ upgrade cost. |
| **Steps** | 1. Purchase Warehouse upgrade.<br>2. Verify cost deduction.<br>3. Verify effect. |
| **Expected result** | Treasury decreases by upgrade cost. City stock cap increased. Visual indicator appears. |
| **Pass criteria** | Effect matches upgrade description. Persisted after save/load. |
| **Fail criteria** | Free upgrade; no effect; effect lost on reload. |

---

### 4.5 Contract System

#### TC-CO-01: Contract Acceptance

| Field | Content |
|---|---|
| **Preconditions** | Contract available: Deliver 200 Coal to Kolkata by Month 3. Reward ₹5,000. |
| **Steps** | 1. Open Contracts Panel.<br>2. Click Accept. |
| **Expected result** | Contract status changes to `"active"`. `quantity_delivered` = 0. `days_remaining` set. Owner faction ID = player. |
| **Pass criteria** | Contract appears in active list. Cannot accept twice. |
| **Fail criteria** | Duplicate acceptance; status not updated; wrong faction assignment. |

#### TC-CO-02: Contract Progress

| Field | Content |
|---|---|
| **Preconditions** | Active contract for 200 Coal to Kolkata. Player train delivers 80 Coal. |
| **Steps** | 1. Complete delivery.<br>2. Inspect contract state. |
| **Expected result** | `quantity_delivered` = 80. Progress UI shows 40%. No reward yet. |
| **Pass criteria** | Progress increments by exact delivered quantity. Only deliveries to correct city/count. |
| **Fail criteria** | Wrong city counts; progress exceeds requirement; reward granted early. |

#### TC-CO-03: Contract Completion

| Field | Content |
|---|---|
| **Preconditions** | `quantity_delivered` = 200/200. Days remaining > 0. |
| **Steps** | 1. Trigger completion check (on delivery or daily tick). |
| **Expected result** | Status = `"completed"`. Reward ₹5,000 added to treasury. Reputation increased. Contract moved to history. Event log message. |
| **Pass criteria** | Exact reward amount. Reputation delta correct. No further progress tracking. |
| **Fail criteria** | Missing reward; double reward; contract remains active. |

#### TC-CO-04: Contract Failure

| Field | Content |
|---|---|
| **Preconditions** | Active contract. `days_remaining` reaches 0. `quantity_delivered` < 200. |
| **Steps** | 1. Advance past deadline. |
| **Expected result** | Status = `"failed"`. Failure penalty deducted from treasury. Reputation decreased. Contract moved to history. Event log message. |
| **Pass criteria** | Penalty applied once. Treasury does not go below zero (clamp or bankruptcy flag). |
| **Fail criteria** | No penalty; repeated daily penalty; crash on failure. |

---

### 4.6 AI System

#### TC-AI-01: Route Selection

| Field | Content |
|---|---|
| **Preconditions** | AI (British East India Rail) has treasury ≥ construction cost + train cost. |
| **Steps** | 1. Wait for AI Analyze phase.<br>2. Inspect debug overlay or log. |
| **Expected result** | AI selects route with positive `route_score`. Score uses same economy rules as player. |
| **Pass criteria** | Chosen route has expected_profit_per_trip > 0. Construction cost affordable. |
| **Fail criteria** | AI selects unprofitable route; AI cheats on cost; AI ignores track existence. |

#### TC-AI-02: AI Track Building

| Field | Content |
|---|---|
| **Preconditions** | AI has selected route A → B. Treasury sufficient. |
| **Steps** | 1. Wait for AI Expand phase.<br>2. Inspect map and TrackGraph. |
| **Expected result** | AI builds track between A and B. Treasury decreases. Track visible in AI color. TrackGraph updated with `owner_faction_id = "british"`. |
| **Pass criteria** | Track exists and is pathable by AI trains. Player cannot use if private. |
| **Fail criteria** | Track not built; build cost not deducted; player can use private AI track. |

#### TC-AI-03: AI Train Purchase and Delivery

| Field | Content |
|---|---|
| **Preconditions** | AI owns track. Treasury ≥ train cost. |
| **Steps** | 1. Wait for AI Operate phase.<br>2. Observe AI train. |
| **Expected result** | AI buys train. Train spawns at origin. Enters Loading → Traveling → Unloading loop. AI treasury changes on revenue and maintenance. |
| **Pass criteria** | AI train delivers cargo. AI treasury increases on delivery, decreases on maintenance. |
| **Fail criteria** | AI train stuck; AI gets free money; AI ignores maintenance. |

#### TC-AI-04: Market Share Update

| Field | Content |
|---|---|
| **Preconditions** | Player and AI both deliver cargo to Kolkata. |
| **Steps** | 1. Observe city panel market share after several deliveries. |
| **Expected result** | Market share percentages sum to 100%. Player and AI shares proportional to delivered tonnage. |
| **Pass criteria** | Total = 100%. Shares update on every delivery. |
| **Fail criteria** | Total ≠ 100%; shares stale; crash on division. |

---

### 4.7 Event System

#### TC-EV-01: Event Trigger and Warning

| Field | Content |
|---|---|
| **Preconditions** | Game date approaching Monsoon Flood trigger window. Warning days = 30. |
| **Steps** | 1. Advance game to 30 days before event.<br>2. Observe UI. |
| **Expected result** | Warning notification appears. Event ticker shows countdown. Event panel accessible. |
| **Pass criteria** | Warning appears exactly once. Countdown decrements daily. |
| **Fail criteria** | No warning; duplicate warnings; wrong event date. |

#### TC-EV-02: Event Effect Application

| Field | Content |
|---|---|
| **Preconditions** | Monsoon Flood active. Player owns river track. |
| **Steps** | 1. Wait for event duration.<br>2. Inspect affected tracks. |
| **Expected result** | River track `condition` drops or `is_damaged` = true. Speed penalty applied. Repair cost increased. |
| **Pass criteria** | Only river track affected. Plains/hill track unchanged. Effect matches EventData definition. |
| **Fail criteria** | Wrong tracks affected; no effect; permanent irreversible damage. |

#### TC-EV-03: Counterplay Availability

| Field | Content |
|---|---|
| **Preconditions** | Event warning active. Player has sufficient treasury. |
| **Steps** | 1. Open event details.<br>2. Attempt counterplay (e.g., pay settlement for Labor Strike; repair bridges before Monsoon). |
| **Expected result** | Counterplay option visible and clickable. Cost deducted. Effect mitigated or prevented. |
| **Pass criteria** | At least one valid counterplay per event. Cost reasonable. Effect reduced or nullified. |
| **Fail criteria** | Counterplay missing; counterplay does nothing; cost = 0 when it shouldn't be. |

#### TC-EV-04: Event Cleanup

| Field | Content |
|---|---|
| **Preconditions** | Event duration expired. |
| **Steps** | 1. Wait for event end.<br>2. Inspect city/track state. |
| **Expected result** | Event removed from active list. Temporary effects reverted (unless permanent by design). Event added to history log. |
| **Pass criteria** | No lingering modifiers after cleanup. History log has entry. |
| **Fail criteria** | Effects persist forever; event re-triggers immediately; memory leak. |

---

### 4.8 Save/Load System

#### TC-SL-01: Full State Serialization

| Field | Content |
|---|---|
| **Preconditions** | Mid-game state: tracks built, trains running, active contract, ongoing event, treasury = ₹12,340. |
| **Steps** | 1. Press Save (or F5).<br>2. Inspect save file JSON. |
| **Expected result** | JSON contains all required fields (see `save_schema.md`). No `null` where required. Version number present. |
| **Pass criteria** | File size reasonable (< 5 MB for early builds). Valid JSON parseable by standard library. |
| **Fail criteria** | Missing required fields. Corrupt JSON. Null-critical state. |

#### TC-SL-02: Full State Deserialization

| Field | Content |
|---|---|
| **Preconditions** | Valid save file from TC-SL-01 exists. |
| **Steps** | 1. Quit to menu.<br>2. Load save file.<br>3. Verify every subsystem. |
| **Expected result** | Treasury = ₹12,340. Tracks restored. Trains resume. Contract progress preserved. Event timer preserved. Date preserved. |
| **Pass criteria** | All numeric values identical. All IDs resolved to valid resources. Trains recompute path if needed. |
| **Fail criteria** | Value drift. Missing trains. Contract reset. Event duplicated or lost. |

#### TC-SL-03: Integrity Check — Missing Resource

| Field | Content |
|---|---|
| **Preconditions** | Save references a `train_data_id` that no longer exists in `data/trains/`. |
| **Steps** | 1. Delete or rename train resource.<br>2. Attempt load. |
| **Expected result** | Load fails gracefully with clear error: `"Missing train_data_id: freight_engine_v2"`. Game does not crash. Player returned to menu or fallback train used. |
| **Pass criteria** | Error message identifies missing resource. No crash. No silent corruption. |
| **Fail criteria** | Crash. Silent null train. Save overwritten automatically. |

#### TC-SL-04: Cross-Version Load

| Field | Content |
|---|---|
| **Preconditions** | Save from version N−1. Current game version = N. |
| **Steps** | 1. Load old save. |
| **Expected result** | Migration path runs (see `save_schema.md`). Missing optional fields receive defaults. Schema updated in memory. Save can be re-saved in new format. |
| **Pass criteria** | Old save loads. Data migrated correctly. No data loss for supported fields. |
| **Fail criteria** | Load rejected without migration. Data loss. Crash on unknown field. |

---

### 4.9 UI System

#### TC-UI-01: Panel Open/Close

| Field | Content |
|---|---|
| **Preconditions** | Game running. No panels open. |
| **Steps** | 1. Click city → City Panel opens.<br>2. Click train → Train Panel opens; City Panel closes or stacks correctly.<br>3. Press Escape → all panels close.<br>4. Click X button → panel closes. |
| **Expected result** | Panels open/close cleanly. No orphaned controls. Input focus returns to world map. |
| **Pass criteria** | All close methods work. Only one primary panel in focus at default settings. |
| **Fail criteria** | Panel remains invisible but blocks clicks. Duplicate panels. Memory leak. |

#### TC-UI-02: Tooltip Accuracy

| Field | Content |
|---|---|
| **Preconditions** | City panel showing Coal price = ₹22. |
| **Steps** | 1. Hover over Coal price.<br>2. Read tooltip. |
| **Expected result** | Tooltip shows formula breakdown: base price, supply, demand, saturation status. |
| **Pass criteria** | Tooltip values match underlying economy state. Updated in real time if economy tick fires while tooltip visible. |
| **Fail criteria** | Stale values. Wrong formula. Tooltip missing. |

#### TC-UI-03: Responsiveness at Speed 4×

| Field | Content |
|---|---|
| **Preconditions** | 10+ trains active. Game speed = 4×. |
| **Steps** | 1. Open City Panel.<br>2. Rapidly switch between cities.<br>3. Open Train Panel.<br>4. Try to build track. |
| **Expected result** | Panels update within 1 frame. No frame drops below 30 FPS. Build preview renders instantly. |
| **Pass criteria** | FPS ≥ 30. UI input latency < 100 ms perceptual. |
| **Fail criteria** | FPS drops below 20. UI freezes > 1 second. Preview lags behind cursor. |

#### TC-UI-04: HUD Updates

| Field | Content |
|---|---|
| **Preconditions** | HUD visible. Treasury = ₹10,000. |
| **Steps** | 1. Build track costing ₹2,000.<br>2. Wait for train delivery of ₹1,500.<br>3. Change game speed. |
| **Expected result** | Treasury label updates immediately after construction and delivery. Speed button highlights active speed. Date label advances. |
| **Pass criteria** | No delay > 0.5 seconds between event and HUD update. |
| **Fail criteria** | HUD stale. Wrong speed highlighted. Date jumps backward. |

---

## 5. Performance Test Cases

### 5.1 Max Train Stress Test

| Field | Content |
|---|---|
| **ID** | PERF-01 |
| **Preconditions** | Debug spawn command available. Empty map with 4 cities fully connected. |
| **Steps** | 1. Spawn 50 trains. Run 60 seconds at 1×.<br>2. Spawn 100 trains. Run 60 seconds.<br>3. Spawn 200 trains. Run 60 seconds. |
| **Expected result** | 50 trains: FPS ≥ 60.<br>100 trains: FPS ≥ 45.<br>200 trains: FPS ≥ 30. |
| **Pass criteria** | No crash. Memory usage stable (no leak). Train movement still correct. |
| **Fail criteria** | FPS < 30 at 100 trains. Memory growth > 100 MB/minute. Crash. |

### 5.2 Max Track Segment Stress Test

| Field | Content |
|---|---|
| **ID** | PERF-02 |
| **Preconditions** | Large grid map (100×100). |
| **Steps** | 1. Build 500 track segments.<br>2. Build 1,000 track segments.<br>3. Build 2,000 track segments. |
| **Expected result** | 500 edges: Pathfinding < 5 ms.<br>1,000 edges: Pathfinding < 10 ms.<br>2,000 edges: Pathfinding < 20 ms. |
| **Pass criteria** | Pathfinding returns in < 1 frame (16 ms) for all realistic network sizes. TrackRenderer does not drop frames on add. |
| **Fail criteria** | Pathfinding > 50 ms. Frame freeze on build. |

### 5.3 Economy Tick Performance

| Field | Content |
|---|---|
| **ID** | PERF-03 |
| **Preconditions** | 6 cities. 4 cargo types. 100 trains. Multiple active events. |
| **Steps** | 1. Run game at 4× speed for 5 game years.<br>2. Profile daily economy tick duration. |
| **Expected result** | Economy tick completes in < 2 ms. No frame time spikes > 16 ms due to tick. |
| **Pass criteria** | Smooth frame graph. Tick batched efficiently. |
| **Fail criteria** | Regular frame spikes. Tick duration grows with game time (unbounded). |

### 5.4 Save File Size and Write Time

| Field | Content |
|---|---|
| **ID** | PERF-04 |
| **Preconditions** | Large late-game state (2,000 edges, 200 trains, 6 cities, full history). |
| **Steps** | 1. Save game.<br>2. Measure file size and write duration. |
| **Expected result** | File size < 10 MB. Write time < 500 ms on SSD. |
| **Pass criteria** | No UI freeze > 250 ms during save. File parseable. |
| **Fail criteria** | File > 50 MB. UI freeze > 2 seconds. |

---

## 6. Bug Report Template

```markdown
## Bug Report

| Field | Entry |
|---|---|
| **Bug ID** | BUG-XXX (auto-increment) |
| **Reporter** | Name / Role |
| **Date** | YYYY-MM-DD |
| **Sprint / Build** | e.g., Sprint 03, commit `a1b2c3d` |
| **Godot version** | e.g., 4.2.1-stable |
| **OS** | Windows 11 / macOS 14 / Ubuntu 22.04 |
| **Severity** | Blocker / Critical / Major / Minor / Trivial |
| **Priority** | P0 (fix now) / P1 (next sprint) / P2 (backlog) |

### Summary
One-sentence description of the bug.

### Reproduction Rate
Always / Often / Sometimes / Rarely / Once

### Preconditions
What must be true before the bug occurs.

### Steps to Reproduce
1. Step one.
2. Step two.
3. Step three.

### Expected Result
What should happen.

### Actual Result
What actually happens.

### Evidence
- Screenshot / screen recording
- Save file name (if reproducible from save)
- Godot Output / stdout log (paste last 20 lines)
- `project.godot` debug settings if relevant

### Regression?
- [ ] Yes — worked in previous sprint
- [ ] No — new feature
- [ ] Unknown

### Workaround
Any temporary way to avoid or recover from the bug.

### Affected Test Cases
List any test case IDs from this plan that fail due to this bug.
```

---

## 7. Test Schedule Summary

| Sprint | Minimum QA Coverage |
|---|---|
| Every sprint | Smoke tests (SM-01 to SM-23) + Regression checklist |
| Sprint 01 | TC-TG-01/02, TC-TR-01/02/03, TC-EC-01, TC-UI-01/04 |
| Sprint 02 | Add TC-TG-03, TC-TR-04, TC-EC-02/03/04, TC-CE-01/02, TC-SL-01/02/03 |
| Sprint 03 | Add TC-CE-03/04, TC-CO-01/02/03/04, TC-UI-02 |
| Sprint 04 | Add TC-AI-01/02/03/04, TC-UI-03 |
| Sprint 05 | Add TC-TG-04 (ownership toll full integration) |
| Sprint 06 | Add TC-EV-01/02/03/04 |
| Sprint 07 | Add TC-SL-04 (campaign migration), full end-to-end campaign run |
| Sprint 10 | Full performance suite (PERF-01 to PERF-04), accessibility checks |

---

## 8. Sign-Off

| Role | Name | Date | Status |
|---|---|---|---|
| Lead Developer | | | |
| QA / Manual Tester | | | |
| Design Review | | | |
