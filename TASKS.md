# Rail Empire — Development Task Tracker

**Rule:** Each task must fit in one context window. If a task feels big, split it.

**How to use:**
- Before starting work, read the current sprint's open tasks.
- After completing a task, update this file immediately.
- Never hold task state in memory across turns.

---

## Sprint 00 — Repo Setup ✅ COMPLETE

- [x] Initialize Godot project (`project.godot`)
- [x] Create directory structure (`assets/`, `data/`, `src/`, `scenes/`)
- [x] Write `README.md`
- [x] Write `CONVENTIONS.md`
- [x] Write `BACKLOG.md`
- [x] Write `AGENTS.md`
- [x] Create placeholder autoloads (GameState, EventBus, EconomyManager)
- [x] Create placeholder `main.tscn`
- [x] Verify `godot --path . --headless` runs clean
- [x] Write production control pack (`scope_lock.md`, `kimi_execution_protocol.md`)
- [x] Write technical architecture spec (`technical_architecture.md`, `godot_project_setup.md`)
- [x] Write data schema (`data_schema.md`, `balance_model.md`)
- [x] Write UX flows (`ux_flows.md`, `tutorial_spec.md`)
- [x] Write QA and save specs (`qa_test_plan.md`, `save_schema.md`)
- [x] Write asset and debug specs (`asset_manifest.md`, `debug_tools.md`, `performance_budget.md`)
- [x] Write accessibility and risk docs (`accessibility_controls.md`, `risk_register.md`, `playtest_plan.md`, `release_plan.md`)
- [x] Write historical and narrative guides (`historical_cultural_review.md`, `narrative_style_guide.md`)
- [x] Write UI design package (Stitch prompts + Godot specs)

---

## Sprint 01 — Seed Data Validation ✅ COMPLETE

**Goal:** Data-driven foundation for everything that follows.

### Resource Classes
- [x] `src/resources/cargo_data.gd` — `CargoData` with `cargo_id`, `display_name`, `base_price`, `weight_per_unit`, `volume_per_unit`, `tags`, `icon`
- [x] `src/resources/train_data.gd` — `TrainData` with `train_id`, `display_name`, `purchase_cost`, `speed_km_per_hour`, `cargo_capacity_tons`, `maintenance_per_day`, `reliability`, `compatible_train_tags`, `sprite`
- [x] `src/resources/city_data.gd` — `CityData` with `city_id`, `display_name`, `role`, `map_position`, `population`, `cargo_profiles`
- [x] `src/resources/city_cargo_profile_data.gd` — `CityCargoProfileData` with `cargo_id`, `is_enabled`, `starting_stock`, `production_per_day`, `demand_per_day`, `min_stock`, `max_stock`, `target_stock`, `price_elasticity`, `import_priority`, `export_priority`
- [x] `src/resources/region_data.gd` — `RegionData` with `region_id`, `display_name`, `era_id`, `map_size`, `city_ids`, `terrain_profiles`
- [x] `src/resources/era_data.gd` — `EraData`
- [x] `src/resources/faction_data.gd` — `FactionData`
- [x] `src/resources/modifier_value_data.gd` — `ModifierValueData`
- [x] `src/resources/terrain_profile_entry_data.gd` — `TerrainProfileEntryData`

### Data Catalog & Validation
- [x] `src/resources/data_catalog.gd` — `DataCatalog` central loader
- [x] `src/resources/resource_validator.gd` — `ResourceValidator`
- [x] `src/debug/validate_seed_data.gd` — automated validation scene

### Seed `.tres` Files
- [x] `data/cargo/coal.tres`, `textiles.tres`, `grain.tres`
- [x] `data/trains/freight_engine.tres`, `mixed_engine.tres`
- [x] `data/cities/kolkata.tres`, `patna.tres`, `dacca.tres`, `murshidabad.tres`
- [x] `data/regions/bengal_presidency.tres`

### Acceptance
- [x] 9 Resource classes validated
- [x] 12 `.tres` files load without errors
- [x] Automated test scene passes

---

## Sprint 02 — World Map Shell ✅ COMPLETE

**Goal:** Playable isometric map with camera and city markers.

### Map System
- [x] `src/world/world_map.gd` — `WorldMap` with grid-to-world helpers
- [x] `src/world/terrain_drawer.gd` — `TerrainDrawer` (TileMapLayer placeholder)
- [x] `src/world/region_loader.gd` — `RegionLoader`
- [x] `scenes/world/world.tscn`

### Camera
- [x] `src/world/camera_controller.gd` — `CameraController` (WASD, drag pan, scroll zoom, bounds)

### Cities
- [x] `src/world/city_marker.gd` — `CityMarker` clickable `Area2D`
- [x] City labels and debug names
- [x] 4 cities placed from `RegionData`

### Acceptance
- [x] Main scene loads Bengal map
- [x] 4 cities visible and labeled
- [x] Pan and zoom work

---

## Sprint 03 — TrackGraph and Pathfinding ✅ COMPLETE

**Goal:** Rail graph with A* pathfinding.

### Graph
- [x] `src/tracks/track_graph.gd` — `TrackGraph` custom graph
- [x] `src/tracks/track_edge_data.gd` — `TrackEdgeData` Resource
- [x] `src/tracks/track_path_result.gd` — `TrackPathResult`

### Pathfinding
- [x] `src/tracks/train_pathfinder.gd` — `TrainPathfinder` custom A*
- [x] `add_node`, `add_edge`, `get_neighbors`, `has_path`
- [x] Path cost with `length_km` and `terrain_cost_multiplier`

### Tests
- [x] `src/debug/debug_track_graph.gd` — debug scene
- [x] 23 automated tests (add, remove, pathfinding, serialization)

### Acceptance
- [x] All 23 tests pass

---

## Sprint 04 — Track Placement and Rendering ✅ COMPLETE

**Goal:** Player can build visible track.

### Placement
- [x] `src/tracks/track_placer.gd` — `TrackPlacer` (start → end → preview → confirm)
- [x] `src/tracks/track_placement_preview.gd` — `TrackPlacementPreview`
- [x] Cost computation and treasury deduction
- [x] Insufficient funds blocking

### Rendering
- [x] `src/tracks/track_renderer.gd` — `TrackRenderer` (Line2D)
- [x] Built edges persist visually

### Tests
- [x] `src/debug/sprint_04_acceptance.gd` — 10 automated tests
- [x] `scenes/debug/sprint_04_acceptance.tscn`

### Acceptance
- [x] 10/10 tests pass

---

## Sprint 05 — Train Movement ✅ COMPLETE

**Goal:** Trains move along built track.

### Train Entity
- [x] `src/trains/train_entity.gd` — `TrainEntity` (`Node2D`)
- [x] `src/trains/train_movement.gd` — `TrainMovement` interpolation
- [x] `scenes/trains/train_entity.tscn`

### Pathfinding Integration
- [x] `TrainPathfinder` wired to `TrainEntity`
- [x] `set_route(start, end)` returns bool
- [x] Signals: `segment_started`, `segment_arrived`, `destination_arrived`

### Tests
- [x] `src/debug/sprint_05_acceptance.gd` — 10 automated tests
- [x] `scenes/debug/sprint_05_acceptance.tscn`

### Acceptance
- [x] 10/10 tests pass

---

## Sprint 06/07 — Cargo Transaction Loop ✅ COMPLETE

**Goal:** Complete Route Toy: load, deliver, sell, profit.

### Cargo System
- [x] `src/cargo/cargo_inventory.gd` — `CargoInventory`
- [x] `src/cargo/cargo_stack_state.gd` — `CargoStackState`
- [x] `src/trains/train_cargo.gd` — `TrainCargo` (capacity in tons)

### Economy Runtime
- [x] `src/stations/city_runtime_state.gd` — `CityRuntimeState`
- [x] `src/economy/treasury_state.gd` — `TreasuryState`

### Transactions
- [x] `src/economy/transaction.gd` — `Transaction.sell_cargo()` fixed-price
- [x] `src/stations/station_arrival_handler.gd` — `StationArrivalHandler`

### Debug Scenes
- [x] `src/debug/debug_cargo_transaction.gd`
- [x] `src/debug/debug_economy_route_loop.gd`
- [x] `src/debug/debug_train_movement.gd`
- [x] `src/debug/debug_track_placement.gd`

### Tests
- [x] `src/debug/sprint_06_07_acceptance.gd` — 19 automated tests
- [x] `scenes/debug/sprint_06_07_acceptance.tscn`
- [x] Coal route (Patna→Kolkata) verified end-to-end
- [x] Grain route (Murshidabad→Dacca) verified end-to-end

### Acceptance
- [x] 19/19 tests pass

---

## Sprint 08/09/10 — Daily Economy, Dynamic Pricing, Route Scheduling, Profit Tracking ✅ COMPLETE

**Goal:** Economy lives. Prices move. Routes run themselves. Profit is tracked.

### Time System
- [x] `src/time/simulation_clock.gd` — `SimulationClock`
  - Accelerated calendar: 30 days/month, 12 months/year
  - Emits `day_passed(day, month, year)`
  - `days_per_real_second` configurable
  - `start()`, `pause()`, `resume()`, `advance_one_day()`

### Daily Economy Tick
- [x] `src/economy/economy_tick_system.gd` — `EconomyTickSystem`
  - Connected to `SimulationClock.day_passed`
  - Iterates cities, applies `production_per_day` then `demand_per_day`
  - Clamps stock to `[0, max_stock]`
  - `CityData` remains immutable; only `CityRuntimeState` changes

### Dynamic Pricing
- [x] `src/economy/market_pricing.gd` — `MarketPricing`
  - Formula: `base_price × clamp(1 + shortage_ratio × elasticity, 0.5, 2.0)`
  - `shortage_ratio = (target_stock − current_stock) / target_stock`
  - Uses `CityCargoProfileData.target_stock` and `price_elasticity`

### Dynamic Transaction
- [x] `Transaction.sell_cargo_dynamic()` — returns result dictionary
  - Quotes price BEFORE unloading cargo
  - Revenue = round(quantity × unit_price)
  - Returns `{success, cargo_id, quantity, unit_price, revenue, error}`

### Route Automation
- [x] `src/routes/route_schedule.gd` — `RouteSchedule`
  - `route_id`, `origin_city_id`, `destination_city_id`, `cargo_id`
  - `loop_enabled`, `return_empty`
- [x] `src/routes/route_runner.gd` — `RouteRunner`
  - State machine: IDLE → LOADING_AT_ORIGIN → MOVING_TO_DESTINATION → UNLOADING_AT_DESTINATION → RETURNING_TO_ORIGIN → repeat
  - On arrival: quotes price, unloads, sells dynamically, deducts maintenance, records stats
  - On return: transitions back to LOADING_AT_ORIGIN
  - Empty origin: stays at origin, retries on `day_passed` via `on_day_passed()`
  - No path: transitions to FAILED
  - Insufficient maintenance funds: transitions to FAILED (revenue kept)
- [x] `src/economy/route_profit_stats.gd` — `RouteProfitStats`
  - `trips_completed`, `total_revenue`, `total_operating_cost`, `total_profit`
  - `last_trip_quantity`, `last_trip_revenue`, `last_trip_operating_cost`, `last_trip_profit`

### Tests
- [x] `src/debug/sprint_08_09_10_acceptance.gd` — 23 automated tests
- [x] `scenes/debug/sprint_08_09_10_acceptance.tscn`

### Key Design Changes from Original Plan
- **No `TrainManager`.** `RouteRunner` owns per-train route coordination.
- **No `CityEconomy.gd`.** Economy tick is `EconomyTickSystem` (plain Node) + `CityRuntimeState`.
- **Pricing formula changed.** Original: `base × (1 + (demand−supply)/(demand+supply+1))`. Actual: shortage-ratio with designer-tunable `target_stock` and `price_elasticity` per profile.
- **Maintenance timing.** Revenue first, then maintenance. FAILED state preserves already-earned revenue.
- **Pre-unload pricing.** Price quoted before cargo enters destination inventory.

### Acceptance
- [x] 23/23 tests pass

---

## Sprint 11 — Route Toy Playable Scene + Minimal HUD ✅ COMPLETE

**Goal:** Create the first proper playable prototype scene by integrating the completed route/economy systems into one user-facing Route Toy scene.

### Playable Scene
- [x] `scenes/game/route_toy_playable.tscn`
- [x] `src/game/route_toy_playable.gd` — `RouteToyPlayable`
- [x] Compose `WorldMap`, `TrackGraph`, `TrackRenderer`, `TrainEntity`
- [x] Compose `SimulationClock`, `EconomyTickSystem`, `RouteRunner`
- [x] Pre-built Patna→Kolkata track
- [x] Freight Engine spawned at Patna
- [x] RouteRunner configured for coal loop (return_empty, loop_enabled)

### Minimal HUD
- [x] `scenes/game/route_toy_hud.tscn` — CanvasLayer with governor_archive theme
- [x] `src/game/route_toy_hud.gd` — `RouteToyHUD`
- [x] Treasury display (top-left)
- [x] Date display (top-left)
- [x] Speed controls: pause, 1×, 2×, 4× (top-center)
- [x] Route status (top-right)
- [x] Current Kolkata coal price (right panel)
- [x] Patna coal stock (right panel)
- [x] Kolkata coal stock (right panel)
- [x] Demand label: Shortage/Balanced/Oversupplied (right panel)
- [x] Trips completed (top-right)
- [x] Last trip revenue / operating cost / profit (bottom widget)
- [x] Total revenue / operating cost / profit (bottom widget)

### Route Control Overlay
- [x] Start route button
- [x] Pause/resume button
- [x] Reset simulation button
- [x] Advance one day button

### Validation
- [x] Train completes at least 3 deliveries (verified in 20s headless run)
- [x] HUD values update correctly (signal-driven + polled)
- [x] Reset returns all state to initial values
- [x] All Sprint 01–10 regression tests still pass (no script errors on load)

---

## Sprint 12 — MVP Productization: Save/Load + Menus + Stabilization ✅ COMPLETE

**Goal:** Turn the Route Toy into a recoverable MVP.

- [x] `SaveGameData` — versioned JSON save schema (v1)
- [x] `SaveSerializer` — to_dict / from_dict for all runtime state
- [x] `SaveLoadService` — file I/O at `user://saves/route_toy_save.json`
- [x] Save: clock, treasury, city stocks, track graph, train cargo, route schedule, route stats
- [x] Load: restore all runtime state, safe runner state restore
- [x] F5 save, F9 load (input in RouteToyPlayable)
- [x] HUD toast feedback
- [x] PrototypeStartMenu → route_toy_playable.tscn
- [x] MainMenu LoadGameButton enabled if save exists
- [x] Fix console errors (signal duplicate guard)
- [x] Debug save/load acceptance test passes
- [x] 30-minute playtest session

---

## Sprint 13 — Player Agency: Track Cost + Train Purchase + Route Creation UI + Hardening ✅ COMPLETE

**Goal:** Let the player make meaningful build and buy decisions.

### Sprint 13 Surface
- [x] Empty start (no pre-built track, no pre-spawned train)
- [x] Track placement UI with treasury cost (₹500/km), city snapping
- [x] Train purchase UI (Freight Engine, Mixed Engine) with city spawn
- [x] Route creation UI (assign train, origin, destination, cargo, loop, return_empty)
- [x] Route auto-start on creation
- [x] Save/Load v2 with `trains[]`/`routes[]` arrays
- [x] Reset simulation
- [x] HUD buttons for all player actions

### Sprint 13 Hardening
- [x] **Stable instance IDs:** `TrainEntity.instance_id` (`train_001`), `RouteSchedule.instance_id` (`route_001`) + `assigned_train_instance_id`
- [x] **ID maps in RouteToyPlayable:** `train_by_instance_id`, `route_by_instance_id` with collision-safe counters
- [x] **Save/Load two-pass deserialize:** trains first → build map → routes second with train lookup by `assigned_train_instance_id`
- [x] **v1 backward compatibility:** missing IDs auto-generate `train_migrated_###` / `route_migrated_###`; missing assignment falls back to first train with warning
- [x] **HUD selected route:** `_selected_route_index` with cycle button, route counter label ("Route X / N")
- [x] **Dynamic HUD city info:** labels show selected route's origin/destination/cargo instead of hardcoded Patna/Kolkata/Coal
- [x] **Enhanced route creation preview:** capacity, revenue estimate, maintenance cost, net profit, warnings (low stock, shortage, oversupply)
- [x] **Acceptance tests:** `tests/sprint_13_acceptance.gd` — 7 test suites covering multi-train, multi-route, save/load, HUD safety, v1 compat, preview fields

---

## Sprint 14 — Economy Depth: Contracts + Station Upgrades + Profitability ✅ COMPLETE

**Goal:** Make the economy interesting before adding enemies.

### Systems Delivered
- [x] **ContractData** — `src/resources/contract_data.gd`
- [x] **ContractRuntimeState** — `src/contracts/contract_runtime_state.gd`
- [x] **ContractManager** — `src/contracts/contract_manager.gd` (generation, acceptance, progress, expiry, rewards)
- [x] **Reputation** — `RouteToyPlayable.reputation` + HUD display + save/load
- [x] **Contracts Panel UI** — `src/ui/contracts_panel.gd` + `scenes/ui/contracts_panel.tscn`
- [x] **Contract delivery integration** — `trip_completed` → `ContractManager.record_delivery()` → completion/expiry
- [x] **StationUpgradeState** — `src/stations/station_upgrade_state.gd`
- [x] **Station Upgrade Panel UI** — `src/ui/station_upgrade_panel.gd` + `scenes/ui/station_upgrade_panel.tscn`
- [x] **Maintenance Shed effect** — 10%/20%/30% discount passed to `RouteRunner` via `Callable`
- [x] **Demand saturation warnings** — verified in route preview + acceptance test
- [x] **Price recovery** — natural recovery via `EconomyTickSystem` verified
- [x] **Save/Load v3** — `CURRENT_VERSION = 3`, v1/v2 backward compat

### Post-Completion Fix: Absolute Day Counting
- **Problem:** `SimulationClock.current_day` resets to 1 after day 30, so `deadline_day = current_day + 30` produced `deadline_day = 50` and never expired.
- **Fix:** Added `_to_absolute_day(day, month, year) = ((year - 1857) * 360) + ((month - 1) * 30) + day`. Contract deadlines, refresh intervals, and save/load v3 all use absolute days.
- **Backward compat:** v1/v2 saves derive safe defaults from calendar fields.
- Commit: `4034cdd`

### Test Results
- Sprint 14 acceptance: **58 PASS, 0 FAIL** (17 test suites)
- Sprint 13 regression: **47 PASS, 0 FAIL**

### Known Limitations
- Contract matching is destination+cargo only
- Warehouse/Loading Bay effects are display-only for Sprint 14
- Reputation is display-only (no gating yet)

---

## Sprint 15 — Rival Pressure: British AI + Market Share + Track Ownership/Tolls ✅ COMPLETE

**Goal:** Add one visible competitor and make infrastructure strategic.

### Systems Delivered
- [x] **FactionManager** — `src/factions/faction_manager.gd` — player + British treasuries
- [x] **DeliveryLedger** — `src/economy/delivery_ledger.gd` — records all deliveries with metadata
- [x] **MarketShareSystem** — `src/economy/market_share_system.gd` — city/overall share from ledger
- [x] **BaronAI** — `src/ai/baron_ai.gd` — state machine: ANALYZE → BUILD_TRACK → BUY_TRAIN → CREATE_ROUTE → OPERATE → PAUSE_ON_LOSS
- [x] **British AI integration** — builds Patna→Kolkata track, buys freight engine, creates coal route
- [x] **TrackGraph access control** — `find_path()` respects `access_mode` + `faction_id`
- [x] **Toll system** — `calculate_path_toll()` + RouteRunner deducts/adds tolls via FactionManager
- [x] **Private track blocking** — foreign private edges excluded from pathfinding
- [x] **RouteRunner faction support** — `_faction_id`, `_faction_manager`, `_delivery_ledger` params
- [x] **Track Panel UI** — `src/ui/track_panel.gd` + `scenes/ui/track_panel.tscn`
- [x] **HUD updates** — British treasury, market share, AI state, track button
- [x] **Save/Load v4** — `CURRENT_VERSION = 4`, persists faction, ledger, AI state; v1/v2/v3 backward compat

### Test Results
- Sprint 15 acceptance: **52 PASS, 0 FAIL** (17 test suites)
- Sprint 14 regression: **58 PASS, 0 FAIL**
- Sprint 13 regression: **47 PASS, 0 FAIL**

### Known Limitations
- BaronAI uses hardcoded first route (Patna→Kolkata coal) for determinism
- Only one AI route for Sprint 15
- Track panel not fully wired to HUD click-to-select (opens via button)
- "restricted" access mode stored but not enforced
- Market share is quantity-based (not revenue-based)

---

## Sprint 16 — Disruption Layer: Events + Maintenance + Crisis Handling ✅ COMPLETE

**Goal:** Add planning tension without random punishment.

### Systems Delivered
- [x] **EventRuntimeState** — `src/events/event_runtime_state.gd`
- [x] **EventManager** — `src/events/event_manager.gd` (warning/active/resolved lifecycle, deterministic RNG)
- [x] **Monsoon Flood** — blocks track edge for 10 days, 5-day warning
- [x] **Labor Strike** — 50% loading penalty at affected city, 3-day warning
- [x] **Port Boom** — doubles production/demand at port city, positive event
- [x] **Track Inspection** — 7-day warning, fines for condition < 0.5
- [x] **Track condition decay** — `TrackGraph.tick_condition_decay()`
- [x] **Track Repair** — `src/tracks/track_repair.gd` (cost = (1.0 - condition) * length * 200)
- [x] **Event Log Panel UI** — `src/ui/event_log_panel.gd` + `scenes/ui/event_log_panel.tscn`
- [x] **Save/Load v5** — `CURRENT_VERSION = 5`, persists events, track condition; v1-v4 backward compat

### Test Results
- Sprint 16 acceptance: **33 PASS, 0 FAIL** (12 test suites)
- Sprint 15 regression: **52 PASS, 0 FAIL**
- Sprint 14 regression: **58 PASS, 0 FAIL**
- Sprint 13 regression: **47 PASS, 0 FAIL**

### Known Limitations
- Low-condition speed penalty deferred (condition + repair system is sufficient for MVP)
- Event frequency not yet tuned (deterministic for tests)

---

## Sprint 17 — Campaign/Scenario Packaging + Polish ✅ COMPLETE

**Goal:** Package proven systems into a coherent playable build.

### Systems Delivered
- [x] **CampaignData** — `src/campaign/campaign_data.gd` + `CampaignActData` inner class
- [x] **CampaignObjective** — `src/campaign/campaign_objective.gd` (9 objective types)
- [x] **CampaignManager** — `src/campaign/campaign_manager.gd` (act advancement, victory/loss)
- [x] **Bengal Railway Charter** — `src/campaign/bengal_railway_charter.gd` (5 acts, progressive objectives)
- [x] **Scenarios** — `src/campaign/scenarios.gd` (Bengal Charter, Port Monopoly, Monsoon Crisis)
- [x] **Faction bonuses** — `src/factions/available_factions.gd` + `faction_bonus_data.gd`
  - British: +₹10k starting capital (₹60k total)
  - French: +2 reputation per contract
  - Amdani: 15% track and station cost discount
- [x] **ObjectivePanel** — `src/ui/objective_panel.gd` + `scenes/ui/objective_panel.tscn`
- [x] **BriefingPanel** — `src/ui/briefing_panel.gd` + `scenes/ui/briefing_panel.tscn`
- [x] **FactionSelectPanel** — `src/ui/faction_select_panel.gd` + `scenes/ui/faction_select_panel.tscn`
- [x] **ScenarioSelectPanel** — `src/ui/scenario_select_panel.gd` + `scenes/ui/scenario_select_panel.tscn`
- [x] **Menu integration** — MainMenu → Sandbox / Campaign / Scenario via GameState autoload
- [x] **AudioManager** — `src/audio/audio_manager.gd` (runtime-generated click/confirm/error/cash/train sounds + mute)
- [x] **Export presets** — macOS, Windows, Linux desktop targets
- [x] **Save/Load v6** — `CURRENT_VERSION = 6`, persists campaign, scenario, faction, objective progress; v1-v5 backward compat
- [x] **Procedural Blender assets** — `tools/generate_assets.py` (terrain tiles, train sprites, city markers, track segments, cargo icons)

### Test Results
- Sprint 17 acceptance: **36 PASS, 0 FAIL** (16 test suites)
- Sprint 16 regression: **33 PASS, 0 FAIL**
- Sprint 15 regression: **52 PASS, 0 FAIL**
- Sprint 14 regression: **58 PASS, 0 FAIL**
- Sprint 13 regression: **47 PASS, 0 FAIL**

### Post-Completion Fix
- **AudioManager parse error:** `is_muted` was both a variable and a function. Removed the redundant function.
- **Test script loading:** Godot headless mode requires `--editor --quit` pre-scan for `class_name` resolution. Documented in test runner workflow.

### Known Limitations
- UI theme polish is functional but not final-art quality
- 60-minute crash-free playtest not yet performed
- Scenario win/loss conditions are checked but not yet surfaced as end-game screens

---

## Deferred (Post-MVP)

- WW1 era + transition
- South India / West India regions
- Full multi-era campaign
- Advanced sabotage
- Stock market
- Multiplayer
- Full 8-faction roster
- Unique faction tech trees and train pools
- Commissioned final art
