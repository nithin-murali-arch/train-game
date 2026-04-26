# Rail Empire — Backlog

Sprint-based task tracking. Each sprint has a goal, tasks with acceptance criteria, and a definition of done.

---

## Legend

- `[ ]` — Not started
- `[-]` — In progress
- `[x]` — Done
- `->` — Deferred to future sprint

---

## Sprint 00 — Repo Setup ✅ COMPLETE

**Goal:** Initialize Godot project, directory structure, documentation, and conventions. No gameplay code.

### Tasks
- [x] Initialize `project.godot` with isometric 2D settings
- [x] Create directory structure (`assets/`, `data/`, `src/`, `scenes/`)
- [x] Write `README.md` with build/run instructions
- [x] Write `CONVENTIONS.md` with coding standards
- [x] Write `BACKLOG.md` with Sprint 01 tasks
- [x] Create `.gitignore` for Godot 4
- [x] Verify `godot --path . --headless` runs without errors

### Definition of Done
- [x] Godot project opens without errors
- [x] All directories documented in README
- [x] Conventions cover naming, signals, autoloads, scene structure
- [x] Backlog has Sprint 01 tasks with acceptance criteria

### Known Issues
- None

### Sprint 01 Readiness
✅ Ready. Proceed to Route Toy implementation.

---

## Sprint 01 — Seed Data Validation ✅ COMPLETE

**Goal:** Create data-driven foundation: Resource classes and seed `.tres` files.

### Phase Reference
PRD-00: E01 Resource/Data Foundation

### Tasks Completed
- [x] `CargoData`, `TrainData`, `CityData`, `CityCargoProfileData`, `RegionData`, `FactionData`, `EraData`, `ModifierValueData` Resource classes
- [x] `DataCatalog` central loader and `ResourceValidator`
- [x] Seed `.tres` files: Coal, Textiles, Grain; Freight Engine, Mixed Engine; Kolkata, Patna, Dacca, Murshidabad; Bengal Presidency
- [x] Automated validation scene (`validate_seed_data.tscn`) — 9 classes, 12 resources, all pass

### Definition of Done
- [x] Godot opens without script errors
- [x] All seed resources load and validate
- [x] Data catalog accessible from autoload

---

## Sprint 02 — Isometric World Map Shell ✅ COMPLETE

**Goal:** Render playable map shell with camera controls and city markers.

### Phase Reference
PRD-00: E02 World Map and Camera

### Tasks Completed
- [x] `WorldMap` with `TerrainDrawer` (TileMapLayer placeholder tiles)
- [x] `CameraController` (WASD pan, drag pan, scroll zoom, bounds clamp)
- [x] `CityMarker` clickable `Area2D` nodes with labels
- [x] `RegionLoader` loads Bengal Presidency with 4 cities
- [x] Grid-to-world and world-to-grid conversion helpers

### Definition of Done
- [x] Main scene loads Bengal map
- [x] Four city markers visible and labeled
- [x] Player can pan and zoom

---

## Sprint 03 — TrackGraph and Pathfinding ✅ COMPLETE

**Goal:** Implement rail graph independent of UI.

### Phase Reference
PRD-00: E03 TrackGraph and Track Placement

### Tasks Completed
- [x] `TrackGraph` custom graph (nodes as grid coords, edges with metadata)
- [x] `TrackEdgeData` Resource class for edge properties
- [x] `TrackPathResult` for pathfinding outcomes
- [x] Custom A* pathfinding (`TrainPathfinder`)
- [x] `add_edge`, `get_neighbors`, `has_path`, serialization support
- [x] 23 automated tests in debug scene

### Definition of Done
- [x] Debug graph finds paths between sample coordinates
- [x] Graph serializes and restores
- [x] All unit tests pass

---

## Sprint 04 — Track Placement and Rendering ✅ COMPLETE

**Goal:** Let the player build visible track.

### Phase Reference
PRD-00: E03 Track Placement

### Tasks Completed
- [x] `TrackPlacer` tool (click origin → click target → preview → confirm)
- [x] `TrackRenderer` draws built edges with `Line2D`
- [x] `TrackPlacementPreview` shows preview line and cost
- [x] Treasury deduction on build confirmation
- [x] Insufficient funds blocks construction
- [x] Debug placement scene with acceptance test

### Definition of Done
- [x] Player can build track between two grid points
- [x] Track cost deducts from treasury
- [x] Built track remains visible
- [x] 10/10 acceptance tests pass

---

## Sprint 05 — Train Entity and Movement ✅ COMPLETE

**Goal:** Make trains move along built track.

### Phase Reference
PRD-00: E04 Train System

### Tasks Completed
- [x] `TrainEntity` scene (`Node2D` + `TrainMovement` child)
- [x] `TrainMovement` path interpolation along graph coordinates
- [x] `TrainPathfinder` wraps `TrackGraph` A* for trains
- [x] Train spawns at city, follows path, stops at destination
- [x] Emits `segment_started`, `segment_arrived`, `destination_arrived` signals
- [x] Rotation follows path direction

### Definition of Done
- [x] Train follows built track from origin to destination
- [x] Train stops at destination
- [x] Movement is readable at default zoom
- [x] 10/10 acceptance tests pass

---

## Sprint 06/07 — Cargo Transaction Loop ✅ COMPLETE

**Goal:** Complete the Route Toy: cargo load, delivery, sale, return.

### Phase Reference
PRD-00: E04-S02, E05-S04

### Tasks Completed
- [x] `CargoInventory` and `CargoStackState` for quantity tracking
- [x] `TrainCargo` component with capacity limits (tons-based)
- [x] `CityRuntimeState` per-city economy runtime
- [x] `TreasuryState` with `can_afford`, `spend`, `add`, overdraft rejection
- [x] `Transaction.sell_cargo()` fixed-price sale
- [x] `StationArrivalHandler` coordinates load/unload/sale at city arrival
- [x] Coal route (Patna→Kolkata) and Grain route (Murshidabad→Dacca) verified end-to-end
- [x] Debug economy route loop scene

### Definition of Done
- [x] Train loads cargo at origin
- [x] Train unloads and sells at destination
- [x] Treasury increases on delivery
- [x] City stock updates
- [x] 19/19 acceptance tests pass

---

## Sprint 08/09/10 — Daily Economy, Dynamic Pricing, Route Scheduling, Profit Tracking ✅ COMPLETE

**Goal:** Make the economy live. Daily ticks, dynamic prices, route automation, profit stats.

### Phase Reference
PRD-01: E05 Economy Expansion, E04 Route Automation

### Tasks Completed
- [x] `SimulationClock` — accelerated calendar (day/month/year), emits `day_passed`
- [x] `EconomyTickSystem` — daily production + demand consumption per city, clamped to `[0, max_stock]`
- [x] `MarketPricing` — dynamic sell price based on shortage ratio from `target_stock`
  - Formula: `base_price × clamp(1 + (target − current)/target × elasticity, 0.5, 2.0)`
- [x] `Transaction.sell_cargo_dynamic()` — quotes price BEFORE unload, returns result dict
- [x] `RouteSchedule` — runtime route instructions (origin, destination, cargo, loop, return_empty)
- [x] `RouteRunner` — state machine: IDLE → LOADING → MOVING → UNLOADING → RETURNING → repeat
  - Quotes price before unloading cargo into destination stock
  - Deducts maintenance after revenue
  - Retries on `day_passed` when origin stock is empty
  - Transitions to FAILED on no path or insufficient maintenance funds
- [x] `RouteProfitStats` — per-route `trips_completed`, `total_revenue`, `total_operating_cost`, `total_profit`, `last_trip_*`
- [x] 23/23 automated acceptance tests pass

### Key Design Decisions (vs Original Plan)
- **No `TrainManager` yet.** Route coordination is handled by `RouteRunner` per assigned train.
- **No `CityEconomy.gd` singleton.** Economy tick is a plain `Node` (`EconomyTickSystem`) wired to `SimulationClock.day_passed`.
- **Pricing formula changed** from `base × (1 + (demand−supply)/(demand+supply+1))` to shortage-ratio model using `CityCargoProfileData.target_stock` and `price_elasticity`. This gives designers explicit control over each cargo/city pair.
- **Maintenance timing:** Revenue added first, then maintenance deducted. If maintenance cannot be paid, route goes FAILED but delivered cargo and revenue remain valid.
- **Dynamic pricing timing:** Price is quoted BEFORE unloading. Delivery is paid based on pre-delivery demand; cargo enters stock AFTER sale.

### Definition of Done
- [x] Clock advances days autonomously
- [x] Cities produce and consume daily
- [x] Prices respond to stock levels (shortage = high, oversupply = low)
- [x] RouteRunner automates full load→move→unload→sell→return cycle
- [x] Per-route profit stats tracked
- [x] Empty origin retries on day tick
- [x] No path fails gracefully

---

## Sprint 11 — Route Toy Playable Scene + Minimal HUD ✅ COMPLETE

**Goal:** Create the first proper playable prototype scene by integrating the completed route/economy systems into one user-facing Route Toy scene.

### Phase Reference
PRD-00: E04, E05, E06

### Tasks Completed
- [x] **RT-01: Route Toy playable scene**
  - AC: `scenes/game/route_toy_playable.tscn` opens without errors
  - AC: Composes `WorldMap`, `TrackGraph`, `TrackRenderer`, `TrainEntity`, `SimulationClock`, `EconomyTickSystem`, `RouteRunner`
  - AC: Pre-built Patna→Kolkata track visible
  - AC: Freight Engine spawned at Patna
  - AC: RouteRunner configured for coal loop

- [x] **RT-02: Minimal HUD**
  - AC: Shows treasury, date, speed controls (pause, 1×, 2×, 4×)
  - AC: Shows route status, cargo type, current price
  - AC: Shows Patna/Kolkata coal stock
  - AC: Shows trips completed, last trip revenue/cost/profit, total profit

- [x] **RT-03: Route control overlay**
  - AC: Start route button
  - AC: Pause/resume button
  - AC: Reset simulation button
  - AC: Advance one day button

- [x] **RT-04: Integration validation**
  - AC: Train completes at least 3 deliveries
  - AC: HUD values update correctly
  - AC: Reset returns all state to initial values
  - AC: All Sprint 01–10 regression tests still pass

### Files Added
- `scenes/game/route_toy_playable.tscn` — Main playable scene
- `scenes/game/route_toy_hud.tscn` — HUD CanvasLayer scene
- `src/game/route_toy_playable.gd` — Scene composition and public control API
- `src/game/route_toy_hud.gd` — HUD logic, signal wiring, polling updates

### Key Design Decisions
- **HUD as separate CanvasLayer scene:** Keeps UI and simulation decoupled. HUD polls state, sends user intent only.
- **RouteRunner signals (3):** `state_changed`, `trip_completed`, `route_failed` — emitted via centralized `_set_state()` helper.
- **No circular dependencies:** `RouteToyPlayable` references HUD via untyped `$HUD` with `has_method()` guard; HUD references `RouteToyPlayable` via untyped `Node` parameter.
- **Auto-start on load:** Route begins immediately on `_ready()`. Start button restarts after reset.
- **Reset fully reinitializes:** CityRuntimeState, TreasuryState, SimulationClock, RouteRunner. Train returns to Patna.

### Definition of Done
- [x] Player can launch scene and see the core loop running
- [x] Player can control pause/speed/reset
- [x] Player can read economy feedback through HUD
- [x] No save/load, AI, events, campaign, contracts, station upgrades

---

## Sprint 12 — MVP Productization: Save/Load + Menus + Stabilization ✅ COMPLETE

**Goal:** Turn the Route Toy into a recoverable MVP. Player can launch from menu, play, save, load, and continue without breaking the economy loop.

### Phase Reference
PRD-01: E07 Save/Load, E06 Core UI

### Tasks
- [x] **SL-01: Save data schema**
  - AC: Versioned JSON save format (v1)
  - AC: Saves clock, treasury, city stocks, track graph, train cargo, route schedule, route stats

- [x] **SL-02: Save/load service**
  - AC: `SaveLoadService` (RefCounted) handles file I/O at `user://saves/route_toy_save.json`
  - AC: `SaveSerializer` serializes/deserializes all runtime state
  - AC: `SaveGameData` plain data container with schema version

- [x] **SL-03: Load runtime state**
  - AC: Restores treasury, date, city stocks, track graph, train cargo, route stats
  - AC: Safe state restore (IDLE or FAILED; mid-transition states reset to safe)
  - AC: Route resumes cleanly after load

- [x] **SL-04: Menu launch**
  - AC: PrototypeStartMenu BeginButton loads `route_toy_playable.tscn`
  - AC: MainMenu LoadGameButton enabled if save exists

- [x] **SL-05: Save/load controls**
  - AC: F5 save, F9 load (handled in RouteToyPlayable)
  - AC: HUD toast feedback on save/load

- [x] **SL-06: MVP stabilization**
  - AC: No console errors during normal play
  - AC: Sprint 01–11 regression clean

### Files Added
- `src/save/save_game_data.gd`
- `src/save/save_serializer.gd`
- `src/save/save_load_service.gd`
- `src/debug/debug_save_load.gd`
- `scenes/debug/debug_save_load.tscn`

### Files Modified
- `src/game/route_toy_playable.gd` — save/load public API, F5/F9 input, toast
- `src/game/route_toy_hud.gd` — toast display
- `src/routes/route_runner.gd` — signal duplicate guard, `set_state_by_name()`, `inject_runtime_refs()`
- `src/menus/PrototypeStartMenu.gd` — launch route_toy_playable.tscn
- `src/menus/MainMenu.gd` — LoadGameButton wiring

### Known Limitations
- Mid-segment train position not saved; restores to nearest graph node
- Single-slot save only (no save slot UI)
- No auto-save
- Continue from MainMenu uses deferred load after scene change

### Definition of Done
- [x] Manual save/load works
- [x] Loaded game matches saved state
- [x] Menu can launch Route Toy scene
- [x] No console errors during normal play
- [x] Sprint 01–11 regression tests still pass

---

## Sprint 13 — Player Agency: Track Cost + Train Purchase + Route Creation UI + Hardening ✅ COMPLETE

**Goal:** Let the player make meaningful build and buy decisions.

### Phase Reference
PRD-01: E03 Track Placement, E04 Train System

### Tasks — Surface
- [x] **PA-01: Track placement UI**
  - AC: Player clicks to build track; preview shows path and cost
  - AC: Track cost (₹500/km) deducted from treasury
  - AC: Insufficient funds blocks construction
  - AC: Snaps to nearest city within 32px

- [x] **PA-02: Train purchase UI**
  - AC: Player can buy Freight Engine or Mixed Engine
  - AC: Train purchase cost deducted from treasury
  - AC: New train spawns at selected city with stable `instance_id`

- [x] **PA-03: Route creation UI**
  - AC: Player assigns train, origin, destination, cargo, loop, return_empty
  - AC: Route auto-starts on creation
  - AC: Multiple routes can run simultaneously

### Tasks — Hardening
- [x] **SH-01: Stable instance IDs**
  - AC: `TrainEntity.instance_id` assigned on purchase (`train_001`, `train_002`, …)
  - AC: `RouteSchedule.instance_id` + `assigned_train_instance_id` on creation
  - AC: Maps `train_by_instance_id` and `route_by_instance_id` maintained in `RouteToyPlayable`
  - AC: Counters `_next_train_instance_id` / `_next_route_instance_id` collision-safe

- [x] **SH-02: Save/Load two-pass deserialize**
  - AC: Serialize writes `instance_id` and `assigned_train_instance_id`
  - AC: Deserialize: trains first → build map → routes second with train lookup
  - AC: Missing assigned train on load → skip route with warning, never crash
  - AC: Save version stays v2; new fields are optional

- [x] **SH-03: v1 backward compatibility**
  - AC: v1 saves (no `instance_id`, no `assigned_train_instance_id`) load successfully
  - AC: Missing train ID → auto-generate `train_migrated_###`
  - AC: Missing route ID → auto-generate `route_migrated_###`
  - AC: Missing assignment → fallback to first train with warning

- [x] **SH-04: HUD selected route**
  - AC: `_selected_route_index` defaults to 0; cycles via Next Route button
  - AC: Route counter shows "Route X / N"
  - AC: Route info, city info, and profit stats display selected route only
  - AC: Signals connected to ALL runners; state changes refresh selected display

- [x] **SH-05: Dynamic HUD city info**
  - AC: Market labels use selected route's origin/destination/cargo (not hardcoded)
  - AC: Safe with 0 routes (shows "—")

- [x] **SH-06: Enhanced route creation preview**
  - AC: Shows train capacity (units), distance, revenue estimate, maintenance/day, net profit
  - AC: Warns if origin stock < capacity
  - AC: Warns if destination shortage (high prices) or oversupply (low prices)

- [x] **SH-07: Acceptance tests**
  - AC: `tests/sprint_13_acceptance.gd` — 7 test suites, all pass
  - AC: Multi-train purchase with distinct IDs
  - AC: Multi-route creation with correct train assignments
  - AC: Save/Load preserves trains, routes, and assignments
  - AC: HUD queries safe with 0, 1, 2 routes
  - AC: v1 backward compat still works
  - AC: Preview returns all expected fields

### Files Added
- `tests/sprint_13_acceptance.gd`

### Files Modified
- `src/trains/train_entity.gd` — added `instance_id`
- `src/routes/route_schedule.gd` — added `instance_id`, `assigned_train_instance_id`
- `src/game/route_toy_playable.gd` — ID generation, maps, counters, `get_path_estimate()` enhancement
- `src/save/save_serializer.gd` — two-pass deserialize, v1 compat, ID serialization
- `src/game/route_toy_hud.gd` — selected route cycling, dynamic city info, signal wiring
- `scenes/game/route_toy_hud.tscn` — added NextRouteButton, RouteCounterLabel, renamed market labels
- `src/ui/route_creation_panel.gd` — enhanced preview with capacity, revenue, cost, profit, warnings
- `scenes/ui/route_creation_panel.tscn` — added WarningsLabel

### Definition of Done
- [x] Player can build track, buy multiple trains, and create multiple routes
- [x] Route choices have visible economic consequences (preview + dynamic HUD)
- [x] Save/Load preserves multi-train/multi-route state including assignments
- [x] v1 saves still load correctly
- [x] HUD safely handles 0, 1, or N routes
- [x] All acceptance tests pass
- [x] No AI, events, contracts, station upgrades

---

## Sprint 14 — Economy Depth: Contracts + Station Upgrades + Profitability 🔒 LOCKED

**Goal:** Make the economy interesting before adding enemies.

### Phase Reference
PRD-02: E08 Contracts, E09 Station Upgrades, E10 Tech Auctions

### Tasks (Tentative)
- [-] **ED-01: Contracts and Reputation**
  - AC: Contract generation from city demand
  - AC: Accept/complete/fail flow with rewards/penalties
  - AC: Reputation variable affecting contract availability

- [-] **ED-02: Station Upgrades**
  - AC: Warehouse (increases stockpile limit)
  - AC: Loading Bay (reduces loading time)
  - AC: Maintenance Shed (reduces maintenance for based trains)

- [-] **ED-03: Demand saturation**
  - AC: Oversupply warnings in City Panel
  - AC: Price recovery behavior after demand shock

- [-] **ED-04: Technology Auction Shell**
  - AC: Scheduled technology auctions
  - AC: Player bidding and temporary patent bonus
  - AC: Patent expiry → public domain
  - AC: AI bidding stubbed only

### Definition of Done
- Player has short-term goals through contracts.
- Station upgrades create meaningful tradeoffs.
- Demand saturation discourages one-route exploitation.
- Tech auctions create spending decisions.

---

## Sprint 15 — Rival Pressure: British AI + Market Share + Track Ownership/Tolls 🔒 LOCKED

**Goal:** Add one visible competitor and make infrastructure strategic.

### Phase Reference
PRD-03: E11 AI Rival, E12 Market Share, E13 Ownership/Tolls

### Tasks (Tentative)
- [-] **RP-01: British AI Core**
  - AC: British East India Rail evaluates routes, builds track, buys trains
  - AC: AI uses same cost/revenue rules as player
  - AC: AI halts expansion on repeated losses

- [-] **RP-02: Market Share**
  - AC: Delivery ledger tracks all deliveries
  - AC: Market share by city and overall
  - AC: Visible in City Panel and HUD

- [-] **RP-03: Track Ownership and Tolls**
  - AC: Access modes: Open, Private, Contract
  - AC: Toll per km on open track
  - AC: Automatic treasury transfer on foreign track use
  - AC: Track Panel for setting access/toll

### Definition of Done
- British AI builds and operates at least one profitable route.
- Player can profit from rival use of owned track.
- Market share creates competitive feedback.

---

## Sprint 16 — Disruption Layer: Events + Maintenance + Crisis Handling 🔒 LOCKED

**Goal:** Add planning tension without random punishment.

### Phase Reference
PRD-05: E16 Event Manager, E17 Colonial Events, E14/E15 Maintenance

### Tasks (Tentative)
- [-] **DL-01: Event Manager**
  - AC: Warning → Active → Resolved event lifecycle
  - AC: Event notification UI and event log
  - AC: Events serialize to save files

- [-] **DL-02: Colonial Events**
  - AC: Monsoon Flood (river-adjacent damage)
  - AC: Labor Strike (loading slowdown)
  - AC: Port Boom (temporary export price boost)
  - AC: Track Inspection (fines for neglected track)

- [-] **DL-03: Junction Control and Track Maintenance**
  - AC: JunctionData for bridges/passes
  - AC: Track condition decay over time
  - AC: Repair cost and UI
  - AC: Low-condition speed penalty

### Definition of Done
- Events alter plans without feeling unfair.
- Major events warn before severe penalties.
- Each event has at least one counterplay option.
- Track maintenance creates infrastructure decisions.

---

## Sprint 17 — Campaign/Scenario Packaging + Polish 🔒 LOCKED

**Goal:** Package proven systems into a structured, coherent playable build.

### Phase Reference
PRD-06: E18 Campaign, PRD-09: E21 Game Modes, PRD-10: E22 Polish

### Tasks (Tentative)
- [-] **CP-01: Colonial Campaign**
  - AC: Bengal Railway Charter campaign with 5 acts
  - AC: Sequential objectives with progress tracking
  - AC: Newspaper briefings and victory screens

- [-] **CP-02: Faction Variety**
  - AC: British, French, Amdani faction selection
  - AC: Simple faction bonuses visible in gameplay
  - AC: AI personality modifiers

- [-] **CP-03: Scenario Mode**
  - AC: Predefined scenarios: Bengal Charter, Port Monopoly, Monsoon Crisis
  - AC: Objective and win/loss checks per scenario

- [-] **CP-04: UX, Art, Audio, and Export Polish**
  - AC: Consistent UI theme across all screens
  - AC: Better placeholder sprites and terrain
  - AC: Basic audio feedback and mute setting
  - AC: Desktop export presets
  - AC: 60-minute crash-free test

### Definition of Done
- Player can start Campaign, Scenario, or Sandbox.
- Campaign can be started and completed.
- Build exports and runs on desktop.
- New player understands map and UI without developer help.

---

## Deferred (Post-MVP)

These are intentionally kept out of the Colonial Bengal MVP. They may be added after Sprint 17 if the game proves fun and stable.

- WW1 era + transition (EraManager, military cargo, requisition)
- South India / West India regions
- Full multi-era campaign (Colonial → WW1 → Republic)
- Advanced sabotage and counter-intelligence
- Stock market system
- Multiplayer
- Full 8-faction roster
- Unique faction tech trees and train pools
- Commissioned final art pipeline
- Real-time weather shaders

---

## Known Issues (Project-Level)

| Issue | Impact | When to Fix |
|-------|--------|-------------|
| No final art pipeline | Placeholder visuals only | Sprint 17 (polish) |
| No audio system | Silent game | Sprint 17 (polish) |
| Save format may change | Breaks old saves between sprints | Acceptable during alpha |
| No multiplayer | Single player only | Post-launch if ever |
| Godot web export untested | May have performance issues | Before web release |

---

## Compressed Roadmap History

Sprints 01–11 remain individually documented above.
Sprints 12–28 were compressed into macro-sprints 12–17 on 2026-04-26 to focus on delivering a coherent MVP before expanding scope.
