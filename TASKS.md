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

## Sprint 14 — Economy Depth: Contracts + Station Upgrades + Profitability 🔒 LOCKED

**Goal:** Make the economy interesting before adding enemies.

- [ ] `ContractData` and `ContractManager`
- [ ] Contract generation, accept, complete, fail
- [ ] Reputation variable
- [ ] Contracts Panel UI
- [ ] Warehouse upgrade
- [ ] Loading Bay upgrade
- [ ] Maintenance Shed upgrade
- [ ] Demand saturation warnings
- [ ] Price recovery behavior
- [ ] Technology Auction shell (player-only)

---

## Sprint 15 — Rival Pressure: British AI + Market Share + Track Ownership/Tolls 🔒 LOCKED

**Goal:** Add one visible competitor and make infrastructure strategic.

- [ ] `FactionManager` for player/British treasuries
- [ ] `BaronAI` state machine: Analyze → Expand → Operate → React
- [ ] British AI route evaluation and track building
- [ ] British AI train buying and routing
- [ ] Delivery ledger
- [ ] Market share by city and overall
- [ ] Access modes: Open, Private, Contract
- [ ] Toll per km and automatic treasury transfer
- [ ] Track Panel for setting access/toll

---

## Sprint 16 — Disruption Layer: Events + Maintenance + Crisis Handling 🔒 LOCKED

**Goal:** Add planning tension without random punishment.

- [ ] `EventManager` with warning/active/resolved states
- [ ] Event notification UI and event log
- [ ] Monsoon Flood event
- [ ] Labor Strike event
- [ ] Port Boom event
- [ ] Track Inspection event
- [ ] `JunctionData` for bridges/passes
- [ ] Track condition decay
- [ ] Repair cost and UI
- [ ] Low-condition speed penalty

---

## Sprint 17 — Campaign/Scenario Packaging + Polish 🔒 LOCKED

**Goal:** Package proven systems into a coherent playable build.

- [ ] `CampaignData` and `CampaignManager`
- [ ] Bengal Railway Charter campaign (5 acts)
- [ ] Objective panel and briefing screens
- [ ] Faction selection (British, French, Amdani)
- [ ] Scenario mode (Bengal Charter, Port Monopoly, Monsoon Crisis)
- [ ] UI theme polish across all screens
- [ ] Better placeholder sprites and terrain
- [ ] Basic audio feedback and mute setting
- [ ] Desktop export presets
- [ ] 60-minute crash-free test

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
