# Rail Empire — Kimi K2.6 Execution Pack

Version: 0.1  
Engine: Godot 4.2+  
Language: GDScript  
Target: Desktop first, web export later  
Execution style: Depth-first, one strategic layer per milestone

---

## 1. Product Scope Contract

### Product promise
Rail Empire is an isometric 2D railway tycoon game set first in Colonial Bengal. The player builds track, buys trains, transports cargo, earns money, expands the rail network, and eventually competes with rival railway companies.

### Core loop
1. Inspect city supply and demand.
2. Build track between cities.
3. Buy and assign trains.
4. Move cargo and earn revenue.
5. Reinvest into better routes, trains, stations, or defenses.
6. Outperform rivals through route economics, infrastructure control, and crisis resilience.

### Scope guardrail
Kimi must not add new eras, regions, factions, game modes, or cargo breadth unless the sprint explicitly requests it. The project succeeds by making Bengal deep before making the game wide.

### Build order
Route toy → Colonial MVP → Economic depth → First rival → Network control → Events → Colonial campaign → Faction variety → WW1 expansion → Game modes → Polish.

### Explicit first-release limits
The first playable MVP is not the full multi-era game. It is Colonial Bengal only.

First playable MVP includes:
- 1 region: Bengal
- 4 cities: Kolkata, Dacca, Patna, Murshidabad
- 3 cargo types: Coal, Textiles, Grain
- 2 train types: Freight Engine, Mixed Engine
- 1 player faction
- No active rival AI until PRD-03
- No WW1 until PRD-08
- No Sandbox until PRD-09

---

## 2. Engineering Standards for Kimi

### General rules
- Use Godot 4.2+ and GDScript.
- Prefer simple readable code over clever abstractions.
- All gameplay data should be expressed as Resource classes or plain serializable dictionaries.
- Build minimal placeholder art using Godot nodes, Line2D, Polygon2D, ColorRect, Label, and StyleBoxFlat.
- Do not block progress on art assets.
- Keep systems testable without UI when possible.
- Add debug overlays for graph nodes, pathfinding paths, economy ticks, and train state.
- Each sprint must end with a playable or testable increment.

### Code organization
Use this structure unless an existing repo already has a better compatible structure:

```text
train-game/
├── project.godot
├── data/
├── scenes/
├── src/
│   ├── autoload/
│   ├── world/
│   ├── tracks/
│   ├── trains/
│   ├── economy/
│   ├── ai/
│   ├── events/
│   ├── ui/
│   └── resources/
└── tests/
```

### Minimum test approach
- Add pure GDScript unit-style tests for formulas and graph logic where possible.
- Add debug scenes for visual systems.
- If a full test runner is not configured, include deterministic debug commands and documented manual test steps.

### Sprint output format required from Kimi
At the end of every sprint, Kimi must output:
1. Files created or modified.
2. Systems implemented.
3. Manual test steps.
4. Known issues.
5. What not to implement yet.
6. Suggested next sprint.

---

## 3. PRD Index

| PRD | Name | Purpose | Release Gate |
|---|---|---|---|
| PRD-00 | Route Toy | Prove track + train + money loop | Prototype |
| PRD-01 | Colonial Bengal Core Loop | First real MVP | MVP |
| PRD-02 | Economic Depth | Make economy interesting before enemies | Alpha 1 |
| PRD-03 | First Rival Pressure | Add one AI rival | Alpha 2 |
| PRD-04 | Network Control | Ownership, tolls, junctions | Alpha 3 |
| PRD-05 | Events and Disruption | Monsoon, strike, port boom, inspection | Alpha 4 |
| PRD-06 | Colonial Campaign | 5-act Bengal campaign | Beta 1 |
| PRD-07 | Faction Variety | 2–3 playable/rival factions | Beta 2 |
| PRD-08 | WW1 Expansion | Wartime pressure on same map | Expansion 1 |
| PRD-09 | Game Modes | Scenario, Campaign, Sandbox packaging | Release candidate |
| PRD-10 | Art, Audio, Polish | Coherent presentation | Release candidate |

---

# 4. Product Requirements

## PRD-00 — Route Toy

### Goal
Prove that building track, watching a train move, delivering cargo, and seeing money increase feels good.

### In scope
- 2 cities
- 1 cargo type
- 1 train type
- Player treasury
- Basic track placement
- Basic train route
- Basic delivery transaction

### Out of scope
- AI
- Terrain costs beyond flat placeholder cost
- Events
- Save/load
- Campaign
- Multiple trains
- Multiple cargo types

### Success metrics
- Player can complete one profitable route in under 5 minutes.
- Train movement is readable at default zoom.
- Profit feedback is obvious.
- No debug-only actions are required to complete a delivery.

### Epics
- E01 Resource/Data Foundation
- E02 World Map and Camera Shell
- E03 TrackGraph and Track Placement
- E04 Train Movement
- E05 Basic Economy
- E06 Minimal UI

---

## PRD-01 — Colonial Bengal Core Loop

### Goal
Turn the route toy into a small but real tycoon loop with route choice, cargo choice, train choice, and construction cost tradeoffs.

### In scope
- Colonial era only
- Bengal region only
- 4 cities: Kolkata, Dacca, Patna, Murshidabad
- 3 cargo types: Coal, Textiles, Grain
- 2 trains: Freight Engine and Mixed Engine
- Terrain costs
- City supply/demand
- Dynamic pricing
- Route profitability display
- Basic save/load

### Out of scope
- Active rivals
- Technology auctions with AI bidding
- WW1
- Campaign acts
- Sandbox setup options

### Success metrics
- Player can run a 30-minute session with multiple routes.
- There are at least 3 meaningfully different route choices.
- Oversupplying a city changes route profitability.
- Save/load restores the main game state accurately.

### Epics
- E02 World Map and Camera
- E03 Track System
- E04 Train System
- E05 City Economy and Dynamic Pricing
- E06 Core UI
- E07 Save/Load

---

## PRD-02 — Economic Depth

### Goal
Make the economy interesting before adding enemies.

### In scope
- 5–6 cities
- 4 cargo types
- 3 trains
- City roles
- Demand saturation
- Contracts
- Station upgrades
- Technology auction shell

### Out of scope
- Full AI rivals
- Multi-faction campaign
- WW1
- Sabotage
- Stock market

### Success metrics
- Player has short-term goals through contracts.
- Station upgrade decisions affect route profitability.
- Demand saturation discourages one-route exploitation.
- Tech auctions create meaningful spending decisions.

### Epics
- E08 Contracts and Reputation
- E09 Station Upgrades
- E10 Technology Auctions
- E05 Economy Expansion

---

## PRD-03 — First Rival Pressure

### Goal
Add one visible, understandable AI competitor: British East India Rail.

### In scope
- British AI only
- AI treasury
- AI route evaluation
- AI track building
- AI train buying and routing
- Market share tracking

### Out of scope
- Multiple active AI personalities
- Sabotage
- Legal/diplomatic systems
- Full faction selection

### Success metrics
- AI builds at least one profitable route without cheating.
- Player understands what the AI is doing.
- Rival pressure affects player route decisions.

### Epics
- E11 British AI Rival
- E12 Market Share
- E10 AI Tech Auction Bidding Extension

---

## PRD-04 — Network Control

### Goal
Make infrastructure ownership strategically important.

### In scope
- Track ownership per segment
- Toll access
- Private access
- Basic access UI
- Junction/bridge bottleneck values
- Track maintenance burden

### Out of scope
- Complex contract negotiation
- Lawsuits
- Corporate acquisition
- Advanced sabotage

### Success metrics
- Player can profit from rival use of owned track.
- Player can choose between paying tolls or building alternate routes.
- Junction control creates strategic map value.

### Epics
- E13 Track Ownership and Tolls
- E14 Junction Control
- E15 Track Maintenance

---

## PRD-05 — Events and Disruption

### Goal
Add planning tension without random punishment.

### In scope
- Monsoon Flood
- Labor Strike
- Port Boom
- Track Inspection
- Event warnings
- Event log
- Counterplay actions

### Out of scope
- WW2 air raids
- Cyber attacks
- Fuel sanctions
- Modern stock market crashes

### Success metrics
- Events alter plans without feeling unfair.
- Major events are announced before severe penalties.
- Each event has at least one counterplay option.

### Epics
- E16 Event Manager
- E17 Colonial Events
- E18 Event UI

---

## PRD-06 — Colonial Campaign

### Goal
Make Colonial Bengal feel like a complete game arc.

### In scope
- Campaign: Bengal Railway Charter
- 5 acts
- Sequential objectives
- Newspaper briefings
- Multiple win conditions
- Campaign save state

### Out of scope
- Colonial → WW1 transition
- Full Raj to Republic campaign
- Sandbox
- All eras

### Success metrics
- Player can complete a structured campaign.
- Each act emphasizes a different strategic layer.
- Multiple win paths are viable.

### Epics
- E19 Campaign Manager
- E20 Campaign Objectives
- E21 Briefings and Victory Screens

---

## PRD-07 — Faction Variety

### Goal
Make factions matter mechanically after the core game works.

### In scope
- Faction selection screen
- British, French, Amdani
- Simple faction bonuses
- AI personality modifiers

### Out of scope
- Full 8-faction roster
- Unique tech trees
- Unique train pools
- Era-specific faction mechanics

### Success metrics
- Different rival setups change strategy.
- Faction bonuses are visible but not overpowering.
- Same systems support player and AI factions.

### Epics
- E22 Faction Data and Selection
- E23 AI Personality Modifiers

---

## PRD-08 — WW1 Expansion

### Goal
Transform the same Bengal map under wartime rules.

### In scope
- Same Bengal map
- Era transition from Colonial to WW1
- Military cargo: Troops, Munitions, Medical Supplies, Coal
- Military contracts
- Government requisition
- Wartime demand shifts

### Out of scope
- WW2
- Air raids
- Global maps
- New regions
- New faction roster

### Success metrics
- Old networks remain useful but not automatically optimal.
- Wartime contracts create urgency.
- Era transition is understandable and dramatic.

### Epics
- E24 Era Manager
- E25 WW1 Economy Layer
- E26 Military Contracts
- E27 Requisition System

---

## PRD-09 — Game Modes

### Goal
Package proven systems into Scenario, Campaign, and Sandbox.

### In scope
- Scenario mode
- Campaign mode menu flow
- Sandbox setup with limited toggles
- Start conditions by mode

### Out of scope
- Online leaderboards unless already trivial
- Procedural world generation
- All eras/regions/factions unlocked at once

### Success metrics
- Player can start a scenario quickly.
- Campaign preserves progression.
- Sandbox reuses existing systems without special-case code.

### Epics
- E28 Mode Selection
- E29 Scenario Definitions
- E30 Sandbox Setup

---

## PRD-10 — Art, Audio, and Polish

### Goal
Make the game feel coherent and readable.

### In scope
- Godot-native UI styling
- Placeholder-to-polished terrain pass
- Track visual polish
- Train sprite pass
- Station visual states
- Event notification polish
- Basic SFX and music placeholders
- Export builds

### Out of scope
- Large bespoke art pipeline
- Full-era visual redraws
- Cinematics
- Multiplayer

### Success metrics
- New player can understand the map and UI without developer explanation.
- Visual hierarchy is clear at multiple zoom levels.
- Build exports run on desktop.

### Epics
- E31 Art Pipeline
- E32 UI Polish
- E33 Audio Feedback
- E34 Export and QA

---

# 5. Epics, User Stories, and Tasks

## E01 — Resource and Data Foundation

### Story E01-S01: Define core Resource classes
As a developer, I need typed Resource classes so game content can be data-driven.

Acceptance criteria:
- `CityData`, `CargoData`, `TrainData`, `RegionData`, `FactionData`, `EraData`, `ContractData`, and `EventData` exist.
- Each class exports fields needed by the first MVP.
- Resource classes do not contain heavy runtime logic.

Tasks:
- Create `src/resources/CargoData.gd` with name, base_price, icon, cargo_class, compatible_train_tags.
- Create `src/resources/TrainData.gd` with name, cost, speed, capacity, maintenance_per_day, allowed_cargo_classes.
- Create `src/resources/CityData.gd` with city_name, map_coord, role, produces, demands, population.
- Create `src/resources/RegionData.gd` with region_name, map_size, cities, terrain_seed or terrain_map.
- Create `src/resources/FactionData.gd` with name, color, starting_capital_multiplier, bonus_values, ai_personality.
- Create `src/resources/EraData.gd` with available_cargo, available_trains, event_pool, modifiers.
- Create placeholder `.tres` resources for PRD-00 and PRD-01.

### Story E01-S02: Add central constants and IDs
As a developer, I need stable IDs for cities, cargo, train types, owners, and terrain.

Acceptance criteria:
- IDs are deterministic strings.
- Runtime dictionaries serialize cleanly.
- No system relies only on display names.

Tasks:
- Create `src/autoload/Constants.gd`.
- Define owner IDs: `player`, `british`, `neutral`.
- Define terrain IDs: `plains`, `hills`, `river`, `forest`.
- Define cargo IDs: `coal`, `textiles`, `grain`.
- Define train IDs: `freight_engine`, `mixed_engine`.

---

## E02 — World Map and Camera

### Story E02-S01: Render an isometric map shell
As a player, I want a readable isometric map so I understand the play area.

Acceptance criteria:
- A map scene opens from main scene.
- Grid cells are visible in isometric projection.
- City markers appear at configured coordinates.
- Terrain cells can be assigned terrain types.

Tasks:
- Create `scenes/world.tscn`.
- Create `src/world/WorldMap.gd`.
- Implement grid-to-world and world-to-grid conversion helpers.
- Draw placeholder terrain tiles using `TileMap` or custom `Node2D` draw methods.
- Place city nodes from `RegionData`.
- Add debug labels for city names.

### Story E02-S02: Camera controls
As a player, I want to pan and zoom the map comfortably.

Acceptance criteria:
- WASD pans camera.
- Mouse drag pans camera.
- Mouse wheel zooms in/out.
- Zoom has min/max limits.
- Camera remains inside rough map bounds.

Tasks:
- Create `src/world/CameraController.gd`.
- Implement input actions in project settings.
- Add camera bounds from region map size.
- Add optional reset camera key.

---

## E03 — TrackGraph and Track Placement

### Story E03-S01: TrackGraph stores rail nodes and edges
As a developer, I need a graph representation so trains can pathfind on built track.

Acceptance criteria:
- Nodes are grid coordinates.
- Edges store start, end, length, owner, condition, toll, and terrain cost.
- Graph can add/remove/query edges.
- Graph serializes to JSON-friendly dictionaries.

Tasks:
- Create `src/tracks/TrackGraph.gd`.
- Implement `add_node(coord)`.
- Implement `add_edge(start_coord, end_coord, owner_id, cost_data)`.
- Implement `get_neighbors(coord)`.
- Implement `has_path(start, end)`.
- Implement `to_dict()` and `from_dict()`.
- Add debug tests for adding edges and querying neighbors.

### Story E03-S02: A* pathfinding on owned track
As a developer, I need trains to find routes through the rail network.

Acceptance criteria:
- Pathfinding returns ordered grid coordinates.
- No path returns an empty array.
- Edge cost can account for length and condition.
- Later toll and owner rules can be plugged in.

Tasks:
- Implement A* directly or wrap Godot `AStar2D`.
- Add `get_path(start_coord, end_coord, owner_id)`.
- Add path cost calculation.
- Add debug scene with 5–10 nodes and route visualization.

### Story E03-S03: Player can preview and confirm track
As a player, I want to preview track cost before building.

Acceptance criteria:
- Click a city or grid point to start building.
- Hover or click an end point to preview a segment.
- Cost is displayed before confirmation.
- Confirmation deducts treasury and creates graph edge.
- Insufficient funds blocks construction.

Tasks:
- Create `src/tracks/TrackPlacer.gd`.
- Add build mode toggle in minimal UI.
- Implement start/end selection.
- Implement terrain cost sampling.
- Implement preview line.
- Implement confirm/cancel actions.
- Emit `track_built` signal.

### Story E03-S04: TrackRenderer draws built track
As a player, I want built track to remain visible on the map.

Acceptance criteria:
- Built edges render as isometric lines.
- Player-owned track uses player color.
- Debug overlay can show nodes.
- Render updates after track build/load.

Tasks:
- Create `src/tracks/TrackRenderer.gd`.
- Draw Line2D segments from graph edges.
- Add owner color map.
- Add damaged/low condition style hooks.

---

## E04 — Train System

### Story E04-S01: Train entity moves along a graph path ✅ IMPLEMENTED
As a player, I want trains to visibly travel on built track.

Acceptance criteria:
- Train spawns at a city.
- Train receives a route path from `TrainPathfinder`.
- Train interpolates between graph coordinates.
- Train stops at destination.
- Train emits arrival signals.

Implemented:
- `src/trains/TrainEntity.gd` — `TrainEntity` (`Node2D` root)
- `src/trains/TrainMovement.gd` — `TrainMovement` child handling interpolation
- `src/trains/TrainPathfinder.gd` — `TrainPathfinder` wraps `TrackGraph` A*
- Path assignment: `train.set_route(start_grid, end_grid) -> bool`
- Movement speed from `TrainData.speed_km_per_hour`
- Signals: `segment_started(from, to)`, `segment_arrived(coord)`, `destination_arrived(coord)`
- Rotation follows path direction

Notes:
- No `TrainManager` yet. `RouteRunner` coordinates individual trains.

### Story E04-S02: Train cargo component ✅ IMPLEMENTED
As a player, I want trains to carry cargo with capacity limits.

Acceptance criteria:
- Train has cargo inventory with capacity limits.
- Capacity prevents overloading.
- Cargo can load/unload at cities.
- Cargo state serializes cleanly.

Implemented:
- `src/trains/TrainCargo.gd` — `TrainCargo` component
- Capacity enforced in **tons** (not units): `cargo_capacity_tons` from `TrainData`
- `load_cargo(cargo_id, available_quantity) -> int` (returns amount loaded)
- `unload_all_to(target_inventory: CargoInventory) -> int` (returns amount unloaded)
- `get_available_capacity_tons()` respects `CargoData.weight_per_unit`
- Uses `CargoInventory` and `CargoStackState` for stack-based tracking

Notes:
- Capacity is tons-based, so different cargo types with different weights fill capacity differently.

### Story E04-S03: Route automation with RouteRunner ✅ IMPLEMENTED
As a player, I want trains to run routes automatically: load, move, unload, sell, return, repeat.

Acceptance criteria:
- Route coordinates load→move→unload→sell→return cycle.
- Train loads highest available cargo at origin.
- Train travels to destination, unloads, sells dynamically.
- Train returns to origin and repeats.
- Empty origin waits and retries on next day.
- No path fails gracefully.

Implemented:
- `src/routes/route_runner.gd` — `RouteRunner` state machine
- States: `IDLE` → `LOADING_AT_ORIGIN` → `MOVING_TO_DESTINATION` → `UNLOADING_AT_DESTINATION` → `RETURNING_TO_ORIGIN` → repeat
- `setup(schedule, train, graph, origin_runtime, destination_runtime, ...)`
- `start_route()`, `stop_route()`, `reset_route()`
- On destination arrival: quotes dynamic price BEFORE unload, unloads, sells, deducts maintenance, records stats
- On return arrival: transitions back to `LOADING_AT_ORIGIN`
- `on_day_passed()` retries loading when origin stock was empty
- No path → `FAILED` state with `route_failed` signal
- Insufficient maintenance funds → `FAILED` (revenue already kept)

### Story E04-S04: Route schedule and profit stats ✅ IMPLEMENTED
As a player, I want route configuration and profit tracking so I can evaluate route performance.

Acceptance criteria:
- Route has origin, destination, cargo type, and loop settings.
- Profit stats track trips, revenue, operating cost, and net profit.
- Stats are per-route and queryable.

Implemented:
- `src/routes/route_schedule.gd` — `RouteSchedule`
  - `route_id`, `origin_city_id`, `destination_city_id`, `cargo_id`
  - `loop_enabled`, `return_empty`
- `src/economy/route_profit_stats.gd` — `RouteProfitStats`
  - `trips_completed`, `total_revenue`, `total_operating_cost`, `total_profit`
  - `last_trip_quantity`, `last_trip_revenue`, `last_trip_operating_cost`, `last_trip_profit`
  - `record_trip(quantity, revenue, operating_cost)`
- `RouteRunner` owns one `RouteSchedule` and one `RouteProfitStats`
- `trip_completed` signal emits stats after each trip

Deferred:
- Route assignment UI
- Route profitability preview panel
- Per-route profit breakdown in Train Panel

---

## E05 — Economy, Pricing, and Transactions

### Story E05-S01: Player treasury ✅ IMPLEMENTED
As a player, I need to see my cash change from costs and revenue.

Acceptance criteria:
- Treasury starts from scenario configuration.
- Track construction deducts money.
- Deliveries add revenue.
- Treasury rejects overdrafts.

Implemented:
- `src/economy/treasury_state.gd` — `TreasuryState`
- `can_afford(amount)`, `spend(amount) -> bool`, `add(amount) -> bool`
- Overdraft rejected: `spend()` returns false if balance < amount
- Starting balance: ₹20,000 (configured in `GameState`)

Deferred:
- Train purchase UI (no purchase flow yet)
- HUD treasury label (debug scenes only)

### Story E05-S02: City economy state ✅ IMPLEMENTED
As a player, I want cities to have supply/demand so routes matter.

Acceptance criteria:
- Each city tracks stock, production, and demand per cargo.
- Daily tick updates production and consumption.
- City economy state is visible in debug output.
- CityData remains immutable; only runtime state changes.

Implemented:
- `src/stations/city_runtime_state.gd` — `CityRuntimeState`
  - `setup_from_city_data(city_data, cargo_catalog)` initializes from `CityData`
  - `get_quantity(cargo_id)`, `add_cargo(cargo_id, qty)`, `remove_cargo(cargo_id, qty)`
  - Uses `CargoInventory` with large capacity (999999 tons for cities)
- `src/economy/economy_tick_system.gd` — `EconomyTickSystem`
  - `setup(city_runtime_states, city_data_by_id, cargo_catalog)`
  - `tick_day(day, month, year)` — connected to `SimulationClock.day_passed`
  - Per city: production adds to stock, then demand consumes (clamped to available), then clamp to `[0, max_stock]`
  - `CityData` is read-only; all mutations go to `CityRuntimeState`

Notes:
- No `CityEconomy.gd` singleton. Economy tick is a plain `Node` wired to the clock signal.

### Story E05-S03: Dynamic pricing ✅ IMPLEMENTED
As a player, I want prices to change with supply and demand.

Acceptance criteria:
- Price rises when city is short on cargo.
- Price falls when city is oversupplied.
- Price clamps between 0.5x and 2.0x base.
- Designers can tune each cargo/city pair.

Implemented:
- `src/economy/market_pricing.gd` — `MarketPricing` (static methods)
- Formula: `base_price × clamp(1 + shortage_ratio × price_elasticity, 0.5, 2.0)`
  - `shortage_ratio = (target_stock − current_stock) / target_stock`
  - `target_stock` from `CityCargoProfileData`
  - `price_elasticity` from `CityCargoProfileData` (default ~0.5)
- When `current_stock < target_stock`: price rises above base
- When `current_stock > target_stock`: price falls below base
- Clamp ensures price never goes below 0.5× or above 2.0× base

Design change from original plan:
- **Original formula:** `base × (1 + (demand−supply)/(demand+supply+1))`
- **Actual formula:** shortage-ratio with explicit `target_stock` and `price_elasticity`
- Reason: gives designers per-cargo, per-city control over price sensitivity and equilibrium point.

Tests:
- Shortage (stock=0, target=500) → price ≈ 1.5× base
- Oversupply (stock=1000, target=500) → price ≈ 0.5× base
- Balanced (stock=500, target=500) → price = 1.0× base

### Story E05-S04: Delivery transaction ✅ IMPLEMENTED
As a player, I want cargo delivery to generate revenue.

Acceptance criteria:
- Train unloads at destination.
- Revenue = quantity × destination price.
- Destination stock increases AFTER sale.
- Treasury increases.
- Last trip profit is stored.
- Price is quoted BEFORE unloading (pre-delivery demand).

Implemented:
- `src/economy/transaction.gd` — `Transaction`
  - `sell_cargo(cargo_id, quantity, destination_city, treasury, cargo_catalog) -> int` — fixed base price (backward compat)
  - `sell_cargo_dynamic(cargo_id, quantity, destination_city, destination_city_data, treasury, cargo_catalog) -> Dictionary`
    - Quotes price BEFORE unloading cargo
    - Returns `{success, cargo_id, quantity, unit_price, revenue, error}`
    - Revenue = `round(quantity × unit_price)`
- `src/routes/route_runner.gd` — `RouteRunner` handles the full arrival sequence:
  1. Quote dynamic price via `MarketPricing.get_sell_price()`
  2. Unload cargo into destination inventory
  3. Sell via `Transaction.sell_cargo_dynamic()`
  4. Deduct maintenance from treasury
  5. Record trip in `RouteProfitStats`

Key design decision:
- **Price quoted BEFORE unload.** Delivery is paid based on pre-delivery demand. Cargo enters stock AFTER sale. This prevents the player from accidentally depressing the price by their own delivery.

Deferred:
- Train Panel UI (debug output only)
- Origin load logic is in `RouteRunner._attempt_load()`, not a separate system

### Story E05-S05: Maintenance costs ✅ IMPLEMENTED
As a player, I need operating costs so route choices are meaningful.

Acceptance criteria:
- Train maintenance deducted per trip (not daily yet).
- Maintenance timing: revenue first, then cost.
- If maintenance cannot be paid, route fails but revenue is kept.

Implemented:
- Maintenance is `TrainData.maintenance_per_day` (₹50 for Freight Engine)
- Deducted in `RouteRunner._process_unloading()` after revenue is added
- `treasury.can_afford(maintenance)` check before spending
- If insufficient funds: route transitions to `FAILED`, but delivered cargo and revenue remain valid

Notes:
- Daily maintenance tick is NOT implemented yet. Currently maintenance is per-trip at destination.
- True daily maintenance will come with `EconomyManager` integration in a future sprint.

Deferred:
- Track maintenance (PRD-04)
- HUD event log for maintenance deductions

---

## E05-S06: Time system ✅ IMPLEMENTED
As a player, I want time to pass so the economy evolves.

Acceptance criteria:
- Game has an accelerated calendar.
- Days pass automatically at configurable speed.
- Economy ticks on each day.
- Date is queryable and displayable.

Implemented:
- `src/time/simulation_clock.gd` — `SimulationClock`
  - 30 days/month, 12 months/year
  - Starting date: 1/1/1857
  - `days_per_real_second` configurable (default 2.0)
  - `start()`, `pause()`, `resume()`, `advance_one_day()`
  - Emits `day_passed(day: int, month: int, year: int)`
  - `get_date_string()` → `"day/month/year"`
- Connected to `EconomyTickSystem.tick_day(day, month, year)`

Deferred:
- Game speed UI buttons (pause, 1×, 2×, 4×)
- HUD date display

---

## E06 — Core UI

### Story E06-S01: HUD ✅ IMPLEMENTED
As a player, I want core status visible at all times.

Acceptance criteria:
- Shows treasury.
- Shows current day/month/year.
- Shows game speed.
- Shows current selected tool.

Implemented:
- `scenes/game/route_toy_hud.tscn` + `src/game/route_toy_hud.gd` — `RouteToyHUD`
  - CanvasLayer with `governor_archive.tres` theme
  - Top-left: Company name, Treasury, Date
  - Top-center: Speed controls (Pause, 1×, 2×, 4×) + Advance Day
  - Top-right: Route status, Route name, Cargo type, Trips completed
  - Right panel: Kolkata coal price, Patna/Kolkata coal stock, Demand label
  - Bottom widget: Last trip revenue/cost/profit, Total revenue/cost/profit
  - Bottom-left controls: Start, Pause/Resume, Reset
- Signal-driven updates: `state_changed`, `trip_completed`, `route_failed` from `RouteRunner`
- Polled updates: treasury, date, city stock, price (in `_process`)
- No dependency on `GameState` signals; HUD binds directly to `RouteToyPlayable`

Deferred:
- `scenes/ui/hud.tscn` (general game HUD) — will come with full game mode integration
- Selected tool display (no build tools in Route Toy)
- City Panel, Train Panel, Build Menu (E06-S02 through S04)

### Story E06-S02: City Panel
As a player, I want to inspect city economy.

Acceptance criteria:
- Clicking a city opens panel.
- Panel shows role, stock, demand, production, and prices.
- Panel shows connected tracks later.

Tasks:
- Create `scenes/ui/city_panel.tscn`.
- Create `src/ui/CityPanel.gd`.
- Add clickable city markers.
- Populate economy rows from city runtime state.

### Story E06-S03: Train Panel
As a player, I want to inspect train cargo and profit.

Acceptance criteria:
- Clicking a train opens panel.
- Panel shows train type, route, speed, cargo, condition, last trip revenue and profit.

Tasks:
- Create `scenes/ui/train_panel.tscn`.
- Create `src/ui/TrainPanel.gd`.
- Add train click selection.
- Populate fields from train runtime state.

### Story E06-S04: Build Menu
As a player, I want simple controls for track and train actions.

Acceptance criteria:
- Track tool toggle exists.
- Buy train button exists.
- Route assignment UI exists, even if minimal.

Tasks:
- Create `scenes/ui/build_menu.tscn`.
- Create `src/ui/BuildMenu.gd`.
- Add signals to TrackPlacer and TrainManager.

---

## E07 — Save and Load

### Story E07-S01: Serialize runtime state
As a player, I want to save progress.

Acceptance criteria:
- Save captures treasury, date, tracks, trains, city economies, and active route assignments.
- Save is JSON-compatible.
- Save does not depend on live node references.

Tasks:
- Add `GameState.to_dict()`.
- Add `TrackGraph.to_dict()`.
- Add `TrainManager.to_dict()`.
- Add `EconomyManager.to_dict()`.
- Write save file to user path.

### Story E07-S02: Load runtime state
As a player, I want to restore progress.

Acceptance criteria:
- Load reconstructs tracks, trains, treasury, date, and city economies.
- Train paths resume or recompute.
- Missing resources fail gracefully with clear debug output.

Tasks:
- Add `from_dict()` methods.
- Add load menu or F9 hotkey.
- Add manual test save file.
- Add version field to save schema.

---

## E08 — Contracts and Reputation

### Story E08-S01: Contract generation
As a player, I want contracts to provide short-term objectives.

Acceptance criteria:
- Contracts specify cargo, destination, quantity, deadline, reward, and penalty.
- Contracts are generated from current city demand.
- Player can accept or ignore contracts.

Tasks:
- Create `src/economy/ContractManager.gd`.
- Create `ContractData.gd` and runtime contract object.
- Add simple contract generation rules.
- Add Contracts Panel.

### Story E08-S02: Contract progress and completion
As a player, I want deliveries to count toward contracts.

Acceptance criteria:
- Delivery updates accepted contract progress.
- Completing contract grants reward and reputation.
- Failing contract applies penalty and reputation loss.

Tasks:
- Hook Transaction system into ContractManager.
- Add contract deadline check on daily tick.
- Add progress display.
- Add reward/failure event log messages.

---

## E09 — Station Upgrades

### Story E09-S01: Upgrade model
As a player, I want stations to have upgrades that affect operations.

Acceptance criteria:
- Each city station can have Warehouse, Loading Bay, and Maintenance Shed flags/levels.
- Upgrade costs money.
- Upgrade effects are visible in city/station panel.

Tasks:
- Add station runtime state to city.
- Implement upgrade purchase API.
- Add UI buttons in City Panel.
- Add upgrade icons or text tags.

### Story E09-S02: Upgrade effects
As a player, I want upgrades to change route performance.

Acceptance criteria:
- Warehouse increases stockpile/storage limit.
- Loading Bay reduces station loading time.
- Maintenance Shed reduces maintenance for trains based there.

Tasks:
- Add storage cap check.
- Add loading delay in TrainMovement or station stop logic.
- Apply maintenance modifier if route origin has shed.

---

## E10 — Technology Auctions

### Story E10-S01: Technology data and auction trigger
As a player, I want random technology auctions to create big investment choices.

Acceptance criteria:
- Technology has ID, name, category, bonus, starting bid, patent duration.
- Scheduled auction triggers every 2 in-game years.
- Random annual auction has configurable chance.

Tasks:
- Create `src/resources/TechnologyData.gd`.
- Create `src/autoload/TechnologyAuctionManager.gd`.
- Create sample techs: Superheater Design, Riveted Bridges, Standardized Parts, Hydraulic Cranes.
- Hook yearly check to EconomyManager date tick.

### Story E10-S02: Player bidding and patent bonus
As a player, I want to bid and gain temporary exclusive bonuses.

Acceptance criteria:
- Player can place bid if treasury sufficient.
- Highest bid wins when auction closes.
- Winning bidder pays bid.
- Patent applies bonus only to winner.
- Patent expires and becomes public domain.

Tasks:
- Create Auction Panel.
- Implement current bid, timer, bidder ID.
- Implement bonus registry.
- Apply speed/cost/load modifiers through central bonus lookup.
- Implement patent expiry.

### Story E10-S03: AI bidding extension
As a player, I want rivals to compete for technology after AI exists.

Acceptance criteria:
- AI decides bid based on treasury, personality, and tech relevance.
- AI does not bid before PRD-03 rival exists.

Tasks:
- Add interface only in PRD-02.
- Implement active AI bidding in PRD-03.

---

## E11 — British AI Rival

### Story E11-S01: AI route analysis
As a player, I want a rival that identifies profitable routes.

Acceptance criteria:
- AI evaluates city pairs using supply/demand price difference and construction cost.
- AI chooses a route with positive expected ROI.
- AI logs its chosen route for debugging.

Tasks:
- Create `src/ai/BaronAI.gd`.
- Add `analyze_routes()`.
- Add profitability heuristic.
- Add debug overlay/list of AI candidate routes.

### Story E11-S02: AI expansion and operation
As a player, I want the rival to build and operate trains.

Acceptance criteria:
- AI builds track using same graph system.
- AI spends treasury.
- AI buys train and assigns route.
- AI earns/losses money through same transaction system.

Tasks:
- Add AI faction treasury to FactionManager.
- Add AI build action using TrackGraph.
- Add AI train creation through TrainManager.
- Add same economy hooks for AI-owned trains.

### Story E11-S03: AI halt on losses
As a player, I want AI to feel rational, not suicidal.

Acceptance criteria:
- AI tracks route profit history.
- AI pauses expansion after repeated losses.
- AI may reroute or retire bad route.

Tasks:
- Add route performance tracker.
- Add AI state machine: Analyze → Expand → Operate → React.
- Implement pause/resume thresholds.

---

## E12 — Market Share

### Story E12-S01: Track cargo deliveries by faction
As a player, I want to know who dominates a city.

Acceptance criteria:
- Every delivery records faction, city, cargo, and quantity.
- City market share is calculated from recent or total deliveries.
- Overall market share is available.

Tasks:
- Add delivery ledger to EconomyManager or MarketShareManager.
- Add market share calculation per city.
- Add overall market share calculation.

### Story E12-S02: Display market share
As a player, I want visible competition information.

Acceptance criteria:
- City Panel shows market share by faction.
- HUD shows overall market share.
- Debug display shows recent delivery totals.

Tasks:
- Add UI rows/bars in City Panel.
- Add HUD market share label.
- Add colors from FactionData.

---

## E13 — Track Ownership and Tolls

### Story E13-S01: Track owner and access rules
As a player, I want to control how others use my track.

Acceptance criteria:
- Each edge has owner_id.
- Each edge has access mode: open, private, contract.
- Pathfinding respects access mode.

Tasks:
- Extend TrackGraph edge data.
- Add access mode constants.
- Update pathfinding to filter inaccessible edges.
- Add owner/access display in debug overlay.

### Story E13-S02: Toll payments
As a player, I want rivals to pay for using my infrastructure.

Acceptance criteria:
- Edge has toll per km.
- Train traveling foreign open edge transfers money from train owner to track owner.
- Toll appears in route profit/loss.

Tasks:
- Add toll cost calculation during train movement.
- Add treasury transfer method in FactionManager.
- Add toll events to transaction log.
- Add toll rows in Train Panel trip breakdown.

### Story E13-S03: Track access UI
As a player, I want to set access on owned segments.

Acceptance criteria:
- Selecting a track segment opens a Track Panel.
- Owner can set Open/Private.
- Owner can set toll amount within sane limits.

Tasks:
- Add track selection hit test.
- Create `TrackPanel.gd`.
- Bind access and toll controls.

---

## E14 — Junction Control

### Story E14-S01: Define key junctions
As a player, I want bottlenecks like bridges to matter.

Acceptance criteria:
- RegionData can define junction points.
- Junctions have name, type, value, and controlled approaches.
- Hovering junction shows strategic value.

Tasks:
- Create `JunctionData.gd`.
- Add junctions to Bengal region.
- Add visual markers.
- Add hover tooltip.

### Story E14-S02: Monopoly bonus
As a player, I want controlling city approaches to matter.

Acceptance criteria:
- Owning all active track approaches to a city grants a small bonus.
- Bonus is visible in City Panel.
- Bonus cannot stack abusively.

Tasks:
- Implement city approach owner check.
- Add monopoly status to city runtime.
- Apply price or reputation bonus.
- Add UI display.

---

## E15 — Track Maintenance

### Story E15-S01: Track condition and decay
As a player, I want overbuilding to have upkeep consequences.

Acceptance criteria:
- Track condition starts at 100%.
- Condition decays slowly over time.
- Low condition slows trains and raises failure risk.

Tasks:
- Add daily/weekly track condition tick.
- Add condition effect to path/travel speed.
- Add low condition visual style.

### Story E15-S02: Track repair
As a player, I want to repair important infrastructure.

Acceptance criteria:
- Player can repair selected segment.
- Repair costs money based on length and damage.
- Repair restores condition.

Tasks:
- Add repair button to Track Panel.
- Implement repair cost formula.
- Add bulk repair debug/action later only if needed.

---

## E16 — Event Manager

### Story E16-S01: Schedule and trigger events
As a player, I want events to occur in ways I can understand.

Acceptance criteria:
- EventManager supports scheduled, random, and campaign-triggered events.
- Events have warning, active, and resolved states.
- Active events serialize to save file.

Tasks:
- Create `src/autoload/EventManager.gd`.
- Create event runtime object.
- Add daily/monthly tick hooks.
- Add event log entries.

### Story E16-S02: Event notification UI
As a player, I want clear warnings and active event status.

Acceptance criteria:
- Warning banner appears before major events.
- Active events appear in HUD ticker.
- Event details show effect and counterplay.

Tasks:
- Create `EventNotification.gd`.
- Create Event Log Panel.
- Add countdown timers.

---

## E17 — Colonial Events

### Story E17-S01: Monsoon Flood
Acceptance criteria:
- Warning one month before monsoon.
- River-adjacent tracks have damage risk.
- Damaged tracks slow trains.
- Bridge upgrade prevents damage.

Tasks:
- Tag river-adjacent edges.
- Implement monsoon roll.
- Apply damage/speed reduction.
- Add bridge upgrade hook.

### Story E17-S02: Labor Strike
Acceptance criteria:
- Strike affects one city.
- Loading speed reduced.
- Player can pay settlement.
- Strike resolves after 3–7 days.

Tasks:
- Implement city event effect modifier.
- Add settlement UI.
- Add random duration.

### Story E17-S03: Port Boom
Acceptance criteria:
- Port boom boosts export cargo prices.
- Countdown visible.
- Ends automatically.

Tasks:
- Add port city modifier.
- Apply cargo price bonus.
- Add active event display.

### Story E17-S04: Track Inspection
Acceptance criteria:
- Periodic inspection checks condition.
- Low-condition tracks trigger fines/warnings.
- Repairing beforehand avoids penalties.

Tasks:
- Add inspection scheduler.
- Check all player-owned segments.
- Apply fines and reputation changes.

---

## E18 — Campaign Manager

### Story E18-S01: Campaign act framework
As a player, I want campaign objectives to progress sequentially.

Acceptance criteria:
- Campaign has act index.
- Each act has objectives and completion checks.
- Completing act unlocks next act.

Tasks:
- Create `CampaignData.gd`.
- Create `CampaignManager.gd`.
- Define Bengal Railway Charter acts.
- Hook objective checks to relevant signals.

### Story E18-S02: Campaign objectives
Acceptance criteria:
- Objective types: connect cities, reach net worth, deliver cargo, market share, survive event, maintain reputation.
- Objective progress is visible.

Tasks:
- Implement objective base class/dictionary evaluator.
- Add UI objective list.
- Add progress update events.

### Story E18-S03: Briefings and victory
Acceptance criteria:
- Act completion shows newspaper-style briefing.
- Campaign victory screen appears on win.
- Any valid win condition can complete campaign.

Tasks:
- Create briefing UI.
- Add act title/body text resources.
- Add victory screen.

---

## E19 — Faction Variety

### Story E19-S01: Faction selection
Acceptance criteria:
- Player selects British, French, or Amdani before campaign/scenario.
- Selected faction determines color, starting capital multiplier, and bonus values.

Tasks:
- Create Faction Selection scene.
- Add three faction resources.
- Apply selected faction to GameState.

### Story E19-S02: Faction bonuses
Acceptance criteria:
- British: starting capital bonus.
- French: passenger/luxury revenue bonus.
- Amdani: construction cost reduction.
- Bonuses are visible in UI.

Tasks:
- Add bonus lookup service.
- Apply construction bonus.
- Apply revenue bonus.
- Add tooltip/list in faction screen.

### Story E19-S03: AI personality modifiers
Acceptance criteria:
- Aggressive AI expands faster.
- Coastal/luxury AI weights port/passenger routes.
- Freight AI weights bulk cargo.

Tasks:
- Extend AI route scoring with personality weights.
- Add debug display of scoring factors.

---

## E20 — Era and WW1 Expansion

### Story E20-S01: Era Manager
Acceptance criteria:
- Current era is loaded from EraData.
- Available cargo/trains/events come from current era.
- Era changes update modifiers and UI theme hooks.

Tasks:
- Create `EraManager.gd`.
- Create `colonial.tres` and `ww1.tres`.
- Add current era to save state.
- Add era indicator to HUD.

### Story E20-S02: Colonial to WW1 transition
Acceptance criteria:
- Completing Colonial campaign can trigger WW1.
- Tracks, stations, reputation carry over.
- Treasury carries over at configured percentage.
- Newspaper transition screen appears.

Tasks:
- Add transition method in CampaignManager/EraManager.
- Transform cargo availability.
- Apply demand shifts.
- Add UI transition.

### Story E20-S03: Military contracts
Acceptance criteria:
- Military contracts require Troops, Munitions, Medical Supplies, or Coal.
- Rewards are premium.
- Deadlines are stricter.
- Failure has reputation/fine penalty.

Tasks:
- Extend ContractManager for military category.
- Add military cargo resources.
- Add wartime contract generator.

### Story E20-S04: Requisition system
Acceptance criteria:
- Government can temporarily open rival track for urgent military contract.
- Track owner receives compensation.
- Requisition has duration and reason.

Tasks:
- Add requisition state to track edges.
- Update pathfinding access rules.
- Add compensation transaction.
- Add event/notification.

---

## E21 — Game Modes

### Story E21-S01: Scenario mode
Acceptance criteria:
- Player can select a scenario.
- Scenario loads region, era, starting money, factions, objectives, and event settings.
- Scenario win/loss conditions work.

Tasks:
- Create `ScenarioData.gd`.
- Create scenario selection menu.
- Implement Bengal Charter, Port Monopoly, Monsoon Crisis, WW1 Supply Line.

### Story E21-S02: Sandbox mode
Acceptance criteria:
- Player can choose faction, era, starting capital, AI difficulty, and event frequency.
- Sandbox starts without campaign objectives.

Tasks:
- Create Sandbox setup scene.
- Add limited toggles.
- Create scenario-like runtime config from sandbox options.

---

## E22 — Art, Audio, and Polish

### Story E22-S01: Placeholder-to-readable art pass
Acceptance criteria:
- Terrain types are distinct.
- Tracks are readable at all zoom levels.
- Cities and trains are visually distinct.
- Owner colors are consistent.

Tasks:
- Add palette constants.
- Improve terrain drawing.
- Add city icon variants by role.
- Add train placeholder sprite variants.

### Story E22-S02: UI polish
Acceptance criteria:
- UI panels have consistent style.
- Important numbers are formatted consistently.
- Warnings are legible.
- Buttons have disabled states.

Tasks:
- Create shared Theme resource.
- Add rupee/ton/day formatting helpers.
- Add tooltips.
- Add confirmation dialogs for expensive actions.

### Story E22-S03: Audio feedback
Acceptance criteria:
- Delivery, build, purchase, error, event warning, and act-complete actions have audio feedback.
- Audio can be muted.

Tasks:
- Add AudioManager.
- Add placeholder SFX.
- Add settings toggle.

### Story E22-S04: Export and QA
Acceptance criteria:
- Desktop export presets exist.
- Game can start, play, save, load, and quit.
- Crash-free 60-minute test pass.

Tasks:
- Configure export presets.
- Add smoke test checklist.
- Fix critical bugs.
- Add README run instructions.

---

# 6. Sprint Plan for Kimi K2.6

Assumption: 1 sprint = one focused agent run or one development week. If Kimi is being used in a single long session, execute one sprint at a time anyway. Do not ask it to build the whole game in one pass.

## Sprint 00 — Repo Audit and Scope Lock

Goal: Prepare the project for controlled implementation.

Inputs for Kimi:
- Latest PRD text.
- Existing repository if any.
- Godot 4.2+ requirement.

Tasks:
- Inspect repo structure.
- Create missing folders.
- Add or update README with scope guardrails.
- Add project conventions document.
- Create initial backlog file if not present.

Definition of done:
- Repo has stable structure.
- README explains how to run project.
- No gameplay feature implementation yet unless needed for project setup.

Kimi prompt:
```text
You are implementing Rail Empire in Godot 4.2+ with GDScript. This sprint is setup only. Inspect the repo, create the folder structure, add README and engineering conventions, and do not implement gameplay yet. Preserve depth-first scope: Route Toy first, Colonial Bengal second, no WW1 or multi-faction work yet. End with files changed, manual test steps, and known issues.
```

---

## Sprint 01 — Seed Data Validation ✅ COMPLETE

Goal: Create data-driven foundation.

Epics: E01

What was built:
- 9 Resource classes: `CargoData`, `TrainData`, `CityData`, `CityCargoProfileData`, `RegionData`, `FactionData`, `EraData`, `ModifierValueData`, `TerrainProfileEntryData`
- `DataCatalog` central loader and `ResourceValidator`
- 12 seed `.tres` files for Bengal Presidency
- Automated validation scene (`validate_seed_data.tscn`)

Definition of done:
- Godot opens without script errors.
- All resources load and validate.
- Data includes Kolkata, Patna, Dacca, Murshidabad, Coal, Textiles, Grain, Freight Engine, Mixed Engine.

---

## Sprint 02 — Isometric World Map and Camera ✅ COMPLETE

Goal: Render playable map shell.

Epics: E02

What was built:
- `WorldMap` with `TerrainDrawer` (TileMapLayer placeholder tiles)
- `CameraController` (WASD pan, drag pan, scroll zoom, bounds clamp)
- `CityMarker` clickable `Area2D` nodes with labels
- `RegionLoader` loads Bengal Presidency with 4 cities
- Grid-to-world and world-to-grid conversion helpers

Definition of done:
- Main scene loads Bengal map.
- Player can pan and zoom.
- Four city markers are visible and labeled.

---

## Sprint 03 — TrackGraph and Pathfinding ✅ COMPLETE

Goal: Implement rail graph independent of UI.

Epics: E03-S01, E03-S02

What was built:
- `TrackGraph` custom graph with `TrackEdgeData` Resource
- `TrackPathResult` for pathfinding outcomes
- `TrainPathfinder` custom A* implementation
- `add_node`, `add_edge`, `get_neighbors`, `has_path`, serialization
- 23 automated tests in debug scene

Definition of done:
- Debug graph finds paths between sample coordinates.
- Graph serializes and restores.
- All unit tests pass.

---

## Sprint 04 — Track Placement and Rendering ✅ COMPLETE

Goal: Let the player build visible track.

Epics: E03-S03, E03-S04, E05-S01 partial

What was built:
- `TrackPlacer` (click origin → click target → preview → confirm)
- `TrackPlacementPreview` with cost display
- `TrackRenderer` draws built edges with Line2D
- Treasury deduction on build, insufficient funds blocking
- 10 automated acceptance tests

Definition of done:
- Player can build track between two grid points.
- Track cost deducts from treasury.
- Built track remains visible.
- 10/10 acceptance tests pass.

---

## Sprint 05 — Train Entity and Movement ✅ COMPLETE

Goal: Make trains move along built track.

Epics: E04-S01

What was built:
- `TrainEntity` scene (`Node2D` + `TrainMovement` child)
- `TrainMovement` path interpolation along graph coordinates
- `TrainPathfinder` wraps `TrackGraph` A* for trains
- `set_route(start, end)` returns bool
- Signals: `segment_started`, `segment_arrived`, `destination_arrived`
- Rotation follows path direction

Not built yet:
- `TrainManager` (deferred to future sprint)
- Train purchase UI
- Multiple train ownership UI

Definition of done:
- Train follows built track from origin to destination.
- Train stops at destination.
- Movement is readable at default zoom.
- 10/10 acceptance tests pass.

---

## Sprint 06/07 — Cargo Transaction Loop ✅ COMPLETE

Goal: Complete Route Toy: cargo load, delivery, sale, return.

Epics: E04-S02, E05-S04

What was built:
- `CargoInventory` and `CargoStackState` for quantity tracking
- `TrainCargo` component with ton-based capacity limits
- `CityRuntimeState` per-city economy runtime
- `TreasuryState` with `can_afford`, `spend`, `add`, overdraft rejection
- `Transaction.sell_cargo()` fixed-price sale
- `StationArrivalHandler` coordinates load/unload/sale at city arrival
- Coal route (Patna→Kolkata) and Grain route (Murshidabad→Dacca) verified end-to-end

Definition of done:
- Train loads cargo at origin.
- Train unloads and sells at destination.
- Treasury increases on delivery.
- City stock updates.
- 19/19 acceptance tests pass.

---

## Sprint 08/09/10 — Daily Economy, Dynamic Pricing, Route Scheduling, Profit Tracking ✅ COMPLETE

Goal: Make the economy live. Prices move. Routes run themselves. Profit is tracked.

Epics: E05-S02, E05-S03, E05-S04, E05-S05, E05-S06, E04-S03, E04-S04

What was built:
- `SimulationClock` — accelerated calendar with `day_passed(day, month, year)` signal
- `EconomyTickSystem` — daily production + demand per city, clamped to `[0, max_stock]`
- `MarketPricing` — dynamic sell price based on shortage ratio from `target_stock`
  - Formula: `base_price × clamp(1 + shortage_ratio × elasticity, 0.5, 2.0)`
- `Transaction.sell_cargo_dynamic()` — quotes price BEFORE unload, returns result dict
- `RouteSchedule` — runtime route instructions
- `RouteRunner` — state machine: IDLE → LOADING → MOVING → UNLOADING → RETURNING → repeat
  - Pre-unload pricing, dynamic sale, maintenance deduction, stats recording
  - Empty origin retries on `day_passed`
  - FAILED state on no path or insufficient maintenance funds
- `RouteProfitStats` — per-route trips, revenue, operating cost, net profit

Key design changes from original plan:
- No `TrainManager`. `RouteRunner` coordinates individual trains.
- No `CityEconomy.gd`. Economy tick is `EconomyTickSystem` (plain Node).
- Pricing formula changed from `base × (1 + (demand−supply)/(demand+supply+1))` to shortage-ratio with `target_stock` and `price_elasticity`.
- Maintenance is per-trip at destination (not daily yet).

Definition of done:
- Clock advances days autonomously.
- Cities produce and consume daily.
- Prices respond to stock levels.
- RouteRunner automates full load→move→unload→sell→return cycle.
- Per-route profit stats tracked.
- Empty origin retries on day tick.
- No path fails gracefully.
- 23/23 acceptance tests pass.

---

## Sprint 11 — Route Toy Playable Scene + Minimal HUD ✅ COMPLETE

Goal: Create the first proper playable prototype scene by integrating the completed route/economy systems into one user-facing Route Toy scene.

Epics: E04, E05, E06

Files created:
- `scenes/game/route_toy_playable.tscn` — Main playable scene (Node2D root)
- `scenes/game/route_toy_hud.tscn` — HUD CanvasLayer with governor_archive theme
- `src/game/route_toy_playable.gd` — `RouteToyPlayable` composition script
- `src/game/route_toy_hud.gd` — `RouteToyHUD` UI logic and signal wiring

Tasks completed:
- Compose `WorldMap`, `TrackGraph`, `TrackRenderer`, `TrainEntity`, `SimulationClock`, `EconomyTickSystem`, `RouteRunner`
- Pre-build Patna→Kolkata track, spawn Freight Engine at Patna, configure RouteRunner for coal loop
- Build minimal HUD: treasury, date, speed controls (pause, 1×, 2×, 4×), route status, city stock/price, profit stats
- Build route control overlay: start, pause/resume, reset, advance one day
- RouteRunner signals: `state_changed`, `trip_completed`, `route_failed`
- Auto-start clock and route on `_ready()`
- Reset fully reinitializes: CityRuntimeState, TreasuryState, SimulationClock, RouteRunner, train position

Validation:
- Train completes 3+ deliveries in 20-second headless run (verified: Patna→Kolkata→Patna→Kolkata loop)
- HUD values update via signals + polling
- Reset returns all state to initial values
- All Sprint 01–10 regression tests still pass (no script errors on load)

Definition of done:
- [x] Player can launch scene and see the core loop running.
- [x] Player can control pause/speed/reset.
- [x] Player can read economy feedback through HUD.
- [x] No save/load, AI, events, campaign, contracts, station upgrades.

Kimi prompt (completed):
```text
Create the first playable Route Toy prototype for Rail Empire. Build scenes/game/route_toy_playable.tscn and src/game/route_toy_playable.gd that composes WorldMap, TrackGraph, TrackRenderer, TrainEntity, SimulationClock, EconomyTickSystem, and RouteRunner into a single playable scene. Pre-build Patna→Kolkata track. Spawn Freight Engine at Patna. Configure RouteRunner for coal loop. Build a minimal HUD showing treasury, date, speed controls, route status, Patna/Kolkata coal stock, Kolkata coal price, trips completed, last trip revenue/cost/profit, and total profit. Add route control buttons: start, pause/resume, reset, advance one day. Validate the train completes at least 3 deliveries, HUD values update, reset returns state to initial, and all Sprint 01–10 regression tests still pass. Do not implement save/load, AI, events, campaign, contracts, station upgrades, or full UI panels.
```

---

## Sprint 12 — MVP Productization: Save/Load + Menus + Stabilization ✅ COMPLETE

Goal: Turn the Route Toy into a recoverable MVP. Player can launch from menu, play, save, load, and continue without breaking the economy loop.

Epics: E07 Save/Load, E06 Core UI

Files added:
- src/save/save_game_data.gd — versioned JSON save schema (v1)
- src/save/save_serializer.gd — to_dict / from_dict for all runtime classes
- src/save/save_load_service.gd — file I/O at user://saves/route_toy_save.json
- src/debug/debug_save_load.gd — automated save/load acceptance test
- scenes/debug/debug_save_load.tscn

Files modified:
- src/game/route_toy_playable.gd — _input() for F5/F9, save_game(), load_game(), toast
- src/game/route_toy_hud.gd — toast display (show_toast(), _update_toast())
- src/routes/route_runner.gd — signal duplicate guard, set_state_by_name(), inject_runtime_refs()
- src/menus/PrototypeStartMenu.gd — launch route_toy_playable.tscn
- src/menus/MainMenu.gd — LoadGameButton enabled if SaveLoadService.has_save()

Tasks completed:
- Save schema v1: clock, treasury, city stocks, track graph, train cargo, route schedule, route stats
- Safe load: restores all state, resets runner to IDLE/FAILED (no mid-transition restore)
- Menu launch: PrototypeStartMenu → Route Toy, MainMenu → load if save exists
- Stabilization: signal duplicate connection guard fixed
- Debug test: 2 trips → save → load → verify treasury/trips/profit match → PASS

Known limitations:
- Mid-segment train position not saved; restores to nearest graph node
- Single-slot save only
- No auto-save
- Continue from MainMenu uses deferred load after scene change

Definition of done:
- [x] Manual save/load works.
- [x] Loaded game matches saved state.
- [x] Menu can launch Route Toy scene.
- [x] No console errors during normal play.
- [x] Sprint 01–11 regression clean.

Kimi prompt (completed):
Implement PRD-01 save/load. Serialize GameState, TrackGraph, RouteRunner state, CityRuntimeState for all cities, treasury, date, and train cargo to JSON. Add manual save/load hotkeys and simple menu buttons. Recompute paths safely on load. Then stabilize the MVP with bug fixes only. Do not add new features beyond save/load.

---

## Sprint 13 — Player Agency: Track Cost + Train Purchase + Route Creation UI 🔒 LOCKED

Goal: Let the player make meaningful build and buy decisions.

Epics: E03 Track Placement, E04 Train System

Tasks:
- Track placement UI (origin → destination → preview → confirm).
- Track cost deduction from treasury.
- Train purchase UI (Freight Engine, Mixed Engine).
- Train spawn at selected city.
- Route creation UI (assign train to origin/destination/cargo).
- Route profitability preview.
- Multiple simultaneous routes.

Definition of done:
- Player can build track, buy trains, and create routes.
- Route choices have visible economic consequences.
- No AI, events, contracts, station upgrades.

Kimi prompt:
Implement player agency: track placement, train purchase, and route creation UI. Player clicks origin city, clicks destination, sees preview line and cost, confirms to build. Track cost deducts from treasury. Train purchase UI lets player buy Freight/Mixed engines at selected cities. Route creation UI assigns a train to origin/destination/cargo with profitability preview. Support multiple simultaneous routes. Do not add AI, contracts, or events.

---

## Sprint 14 — Economy Depth: Contracts + Station Upgrades + Profitability 🔒 LOCKED

Goal: Make the economy interesting before adding enemies.

Epics: E08 Contracts, E09 Station Upgrades, E10 Tech Auctions

Tasks:
- ContractManager, ContractData, accept/complete/fail flow.
- Reputation variable.
- Contracts Panel UI.
- Warehouse, Loading Bay, Maintenance Shed upgrades.
- Demand saturation warnings.
- Price recovery behavior.
- Technology Auction shell (player-only bidding, patent expiry).

Definition of done:
- Player has short-term goals through contracts.
- Station upgrades create meaningful tradeoffs.
- Demand saturation discourages one-route exploitation.
- Tech auctions create spending decisions.

Kimi prompt:
Implement economy depth: contracts, station upgrades, and tech auctions. Create ContractManager with generation from city demand, accept/complete/fail flow, deadlines, rewards, fines, and reputation. Add Warehouse, Loading Bay, and Maintenance Shed to city station runtime state. Add oversupply warnings and price recovery. Create Technology Auction shell with player-only bidding, temporary patent bonus, and expiry to public domain. Stub AI bidding. Do not add AI rival behavior yet.

---

## Sprint 15 — Rival Pressure: British AI + Market Share + Track Ownership/Tolls 🔒 LOCKED

Goal: Add one visible competitor and make infrastructure strategic.

Epics: E11 AI Rival, E12 Market Share, E13 Ownership/Tolls

Tasks:
- FactionManager for player/British treasuries.
- BaronAI state machine: Analyze → Expand → Operate → React.
- British AI route evaluation, track building, train buying.
- Delivery ledger and market share by city/overall.
- Access modes (Open/Private/Contract), toll per km.
- Track Panel for setting access/toll.

Definition of done:
- British AI builds and operates at least one profitable route.
- Player can profit from rival use of owned track.
- Market share creates competitive feedback.

Kimi prompt:
Implement rival pressure: British AI, market share, and track ownership. Add FactionManager with player and British treasuries. Implement BaronAI state machine that evaluates routes, builds track, buys trains, and earns money through the same transaction system. Add delivery ledger and market share display. Implement track access modes (Open/Private/Contract), toll per km, and automatic treasury transfer. Add Track Panel. Do not add more factions yet.

---

## Sprint 16 — Disruption Layer: Events + Maintenance + Crisis Handling 🔒 LOCKED

Goal: Add planning tension without random punishment.

Epics: E16 Event Manager, E17 Colonial Events, E14/E15 Maintenance

Tasks:
- EventManager with warning/active/resolved lifecycle.
- Event notification UI and event log.
- Monsoon Flood, Labor Strike, Port Boom, Track Inspection events.
- JunctionData for bridges/passes.
- Track condition decay, repair cost/UI, low-condition speed penalty.

Definition of done:
- Events alter plans without feeling unfair.
- Major events warn before severe penalties.
- Each event has at least one counterplay option.
- Track maintenance creates infrastructure decisions.

Kimi prompt:
Implement disruption layer: events and maintenance. Add EventManager with warning/active/resolved states that serialize to save files. Implement Monsoon Flood (river-adjacent damage), Labor Strike (loading slowdown), Port Boom (price boost), and Track Inspection (fines). Add event notification UI and event log. Add JunctionData, track condition decay, repair costs, and low-condition speed penalty. Do not add sabotage, air raids, or WW1 events.

---

## Sprint 17 — Campaign/Scenario Packaging + Polish 🔒 LOCKED

Goal: Package proven systems into a structured, coherent playable build.

Epics: E18 Campaign, E19 Factions, E21 Game Modes, E22 Polish

Tasks:
- CampaignData, CampaignManager, Bengal Railway Charter (5 acts).
- Objective panel, briefing screens, victory screen.
- Faction selection (British, French, Amdani) with simple bonuses.
- Scenario mode (Bengal Charter, Port Monopoly, Monsoon Crisis).
- UI theme polish, better placeholder sprites, basic audio feedback.
- Desktop export presets, 60-minute crash-free test.

Definition of done:
- Player can start Campaign, Scenario, or Sandbox.
- Campaign can be started and completed.
- Build exports and runs on desktop.
- New player understands map and UI without developer help.

Kimi prompt:
Package the game into a coherent build. Implement Colonial campaign (Bengal Railway Charter, 5 acts, objectives, briefings, victory). Add limited faction variety (British, French, Amdani). Add Scenario mode. Polish UI theme, placeholder sprites, and basic audio. Configure desktop export. Run 60-minute crash-free test. Do not add new gameplay systems.
