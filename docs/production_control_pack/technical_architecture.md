# Rail Empire — Technical Architecture

Version: 0.1  
Scope: Engineering-level architecture spec for all systems defined in design.md §8.1–8.16.  
Authority: This document overrides ad-hoc wiring decisions. When in conflict, update this doc first.

---

## 1. Autoload Singletons

All singletons live in `src/autoload/`. They are loaded in the order declared in `project.godot`. No singleton may call another singleton in `_init()`; use `_ready()` or deferred calls.

| Singleton | File | Responsibility | Depends On |
|---|---|---|---|
| **EventBus** | `event_bus.gd` | Global signal bus. Decouples emitters from listeners. Stateless. | None |
| **GameState** | `game_state.gd` | Owns all serializable runtime state. Delegates to managers for domain logic. Provides `save()` / `load()` entry point. | EventBus |
| **TimeManager** | `time_manager.gd` | Tracks game date, speed, and emits `day_advanced`. Owns the daily tick timer. | EventBus, GameState |
| **EconomyManager** | `economy_manager.gd` | Runs daily economy tick sequence. Orchestrates city production, demand, pricing, maintenance, contracts, and events in strict order. | EventBus, GameState, TimeManager |
| **TrackManager** | `track_manager.gd` | Owns `TrackGraph` instance. Handles placement, ownership, tolls, condition, and pathfinding requests. | GameState, EventBus |
| **TrainManager** | `train_manager.gd` | Owns all `TrainState` dictionaries. Handles purchase, assignment, movement state machine, and arrival transactions. | GameState, EventBus, TrackManager |
| **CityManager** | `city_manager.gd` | Owns all `CityEconomyState` dictionaries. Handles production, consumption, pricing, and station upgrades. | GameState, EventBus |
| **ContractManager** | `contract_manager.gd` | Owns `ContractState` dictionaries. Tracks deadlines, delivery progress, completion, and failure. | GameState, EventBus, CityManager |
| **EventManager** | `event_manager.gd` | Owns active events, warning timers, and effect application. Rolls monthly for new events. | GameState, EventBus, TimeManager |
| **SaveManager** | `save_manager.gd` | File I/O only. Reads/writes JSON to `user://saves/`. Validates version. Does not own game logic. | GameState |
| **UIManager** | `ui_manager.gd` | Routes UI panel open/close requests. Prevents multiple modals. Does not own data. | EventBus |

### Load Order

```
EventBus → GameState → TimeManager → EconomyManager → TrackManager → TrainManager → CityManager → ContractManager → EventManager → SaveManager → UIManager
```

### Rule: Singletons do not store node references

Singletons store data (dictionaries, Resources, custom RefCounted objects). They never cache `Node` references to scene entities. If a singleton needs to notify a visual object, it emits a signal via `EventBus`; the scene node connects in `_ready()`.

---

## 2. Scene Hierarchy

```text
Main (Node)
└── World (Node2D) — script: world.gd
    ├── Camera2D (Camera2D) — "MainCamera"
    ├── TerrainLayer (TileMapLayer) — isometric terrain tiles
    ├── TrackLayer (Node2D) — holds TrackSegment sprites; script: track_renderer.gd
    ├── StationLayer (Node2D) — holds station upgrade visuals
    ├── CityMarkers (Node2D) — holds CityMarker nodes; added to group "city_group"
    ├── TrainLayer (Node2D) — holds TrainEntity nodes; added to group "train_group"
    └── EffectsLayer (Node2D) — particle effects, temporary visuals

    UIOverlay (CanvasLayer)
    ├── HUD (Control) — treasury, date, speed, objective, event ticker
    ├── BuildMenu (Panel) — track tool, cancel, train purchase, station upgrade
    ├── CityPanel (Panel) — city detail; hidden by default
    ├── TrainPanel (Panel) — train detail; hidden by default
    ├── RoutePreviewPanel (Panel) — route economics; hidden by default
    ├── ContractPanel (Panel) — active/available contracts; hidden by default
    ├── EventBanner (Control) — warning / active event overlay
    └── ModalBlocker (ColorRect) — blocks input during modals

    DebugOverlay (CanvasLayer) — debug builds only
```

### Z-Index Rules

| Layer | Z-Index | CanvasLayer |
|---|---|---|
| Terrain | 0 | — |
| Tracks | 1 | — |
| Stations | 2 | — |
| Cities | 3 | — |
| Trains | 4 | — |
| Effects | 5 | — |
| UI Overlay | — | 1 |
| Debug Overlay | — | 2 |

---

## 3. Signal Contracts

### 3.1 EventBus Signals (Global)

All cross-system communication goes through `EventBus` unless noted in the communication matrix (§9).

| Signal | Emitted By | Listened By | Purpose |
|---|---|---|---|
| `economy_tick(day: int)` | EconomyManager | CityManager, TrainManager, ContractManager, EventManager, UIManager | Start of daily update |
| `day_advanced(date_dict: Dictionary)` | TimeManager | EconomyManager, UIManager | Date changed |
| `game_speed_changed(speed: float)` | TimeManager | UIManager, TrainManager | Speed icon update, movement delta |
| `track_built(edge_id: String, cost: int)` | TrackManager | UIManager, World | Update treasury preview, play effect |
| `track_selected(edge_id: String)` | World/TrackLayer | UIManager | Show track info panel |
| `train_purchased(train_id: String)` | TrainManager | UIManager | Update train list |
| `train_delivered(train_id: String, revenue: int)` | TrainManager | UIManager, GameState | Profit display, net worth update |
| `train_arrived(train_id: String, city_id: String)` | TrainManager | CityManager, ContractManager | Load/unload, contract progress |
| `train_broke_down(train_id: String)` | TrainManager | UIManager | Alert banner |
| `city_clicked(city_id: String)` | CityMarker | UIManager, World | Open city panel, route preview origin |
| `city_prices_updated(city_id: String)` | CityManager | UIManager | Refresh city panel if open |
| `contract_available(contract_id: String)` | ContractManager | UIManager | Notification badge |
| `contract_completed(contract_id: String, reward: int)` | ContractManager | UIManager, GameState | Reward display |
| `contract_failed(contract_id: String, penalty: int)` | ContractManager | UIManager, GameState | Penalty display |
| `event_warning(event_id: String, days: int)` | EventManager | UIManager | Banner + ticker |
| `event_started(event_id: String)` | EventManager | CityManager, TrackManager, UIManager | Apply effects |
| `event_ended(event_id: String)` | EventManager | CityManager, TrackManager, UIManager | Remove effects |
| `treasury_changed(amount: int, reason: String)` | GameState | UIManager | HUD treasury update |
| `save_completed(success: bool, path: String)` | SaveManager | UIManager | Toast notification |
| `load_completed(success: bool)` | SaveManager | GameState, UIManager | Scene refresh or error dialog |

### 3.2 Local Signals (Intra-Scene)

Allowed only within the same scene branch. Do not connect across scenes.

| Signal | Scene | Emitter | Listener |
|---|---|---|---|
| `route_confirmed(city_ids: PackedStringArray)` | World | RoutePreview | TrainManager |
| `panel_closed()` | UIOverlay | Any panel | UIManager |
| `build_tool_selected(tool_id: String)` | BuildMenu | BuildMenu | World |

---

## 4. Save/Load Ownership

### Owner: GameState

`GameState` is the single entry point. It delegates serialization to each manager but owns the top-level schema and version.

### Serialization Flow

```
SaveManager.save_to_file(path)
  → GameState.serialize() → Dictionary
    → TrackManager.serialize_track_graph() → Dictionary
    → TrainManager.serialize_trains() → Array[Dictionary]
    → CityManager.serialize_cities() → Array[Dictionary]
    → ContractManager.serialize_contracts() → Array[Dictionary]
    → EventManager.serialize_events() → Array[Dictionary]
    → TimeManager.serialize_time() → Dictionary
  → JSON.stringify(data)
  → FileAccess.store_string()
```

### Load Flow

```
SaveManager.load_from_file(path)
  → JSON.parse_string()
  → GameState.deserialize(data)
    → Validate "version" field
    → TimeManager.deserialize_time(data.date, data.speed)
    → TrackManager.deserialize_track_graph(data.track_graph)
    → CityManager.deserialize_cities(data.cities)
    → TrainManager.deserialize_trains(data.trains)
    → ContractManager.deserialize_contracts(data.contracts)
    → EventManager.deserialize_events(data.events)
    → GameState.treasury = data.treasury
    → EventBus.load_completed.emit(true)
```

### Save Schema (JSON Top-Level)

```json
{
  "version": "0.1",
  "timestamp_iso": "1857-04-12",
  "phase_id": "colonial_bengal",
  "game_speed": 1.0,
  "treasury": { "player": 20000, "rival_british_east_india": 15000 },
  "track_graph": { "nodes": {}, "edges": {} },
  "trains": [],
  "cities": [],
  "contracts": [],
  "technologies": [],
  "events": [],
  "campaign_progress": {}
}
```

### Rule: No Node Paths in Save Data

All references use stable IDs (`city_id`, `train_id`, `edge_id`). On load, managers reconstruct their dictionaries, and the `World` scene rebuilds visual nodes by querying managers.

---

## 5. Tick Order (Daily Update Sequence)

`EconomyManager` drives the sequence. It is triggered by `TimeManager` once per game day. Each step is synchronous and must complete before the next begins.

```
EconomyManager._on_day_advanced(day)
│
├─ 1. Advance date
│   └─ TimeManager.advance_day() → emits day_advanced
│
├─ 2. Update city production
│   └─ CityManager.produce_cargo() → adds to stock per city
│
├─ 3. Update city demand
│   └─ CityManager.consume_demand() → subtracts from stock, records unmet demand
│
├─ 4. Update prices
│   └─ CityManager.update_prices() → recalculates per cargo using supply/demand formula
│      → emits city_prices_updated for each changed city
│
├─ 5. Deduct train maintenance
│   └─ TrainManager.deduct_maintenance() → subtracts per-train daily cost from treasury
│      → emits treasury_changed
│
├─ 6. Process active contracts
│   └─ ContractManager.tick_contracts() → decrement days_remaining, check completion/failure
│      → emits contract_completed or contract_failed
│
├─ 7. Process event timers
│   └─ EventManager.tick_events() → decrement active event durations, roll monthly for new events
│      → emits event_started or event_ended
│
└─ 8. Notify UI
    └─ EconomyManager emits economy_tick(day)
       → UIManager refreshes HUD panels if visible
```

### Timing Guarantees

- City stock changes from production/demand are visible to the price update in the same tick.
- Maintenance deduction uses the pre-tick train count (no mid-tick purchases).
- Contract deadlines check against the new date after advance.
- Event rolls happen after all economy changes so events can react to state.

---

## 6. Manager Responsibilities Table

| Manager | Owns State | Reads From | Writes To | Never Does |
|---|---|---|---|---|
| **GameState** | Treasury, reputation, campaign progress | All managers (for save) | Treasury (via transaction helper) | Render UI, run pathfinding |
| **TimeManager** | Date, speed, paused flag | GameState (initial date) | Emits day_advanced | Modify economy data |
| **EconomyManager** | None (orchestrator) | All domain managers | Emits economy_tick | Own domain state directly |
| **TrackManager** | `TrackGraph` (nodes, edges) | TerrainLayer (for cost) | Edge ownership, condition, tolls | Modify city stock |
| **TrainManager** | `train_states: Dictionary` | TrackManager (path), CityManager (cargo) | Train position, cargo, revenue | Modify track graph structure |
| **CityManager** | `city_economies: Dictionary` | EventManager (modifiers) | Stock, demand, prices, upgrades | Modify train states |
| **ContractManager** | `contract_states: Dictionary` | CityManager, TrainManager | Contract progress, status | Modify prices directly |
| **EventManager** | `active_events: Array` | GameState (date), CityManager | Emits effect signals | Modify UI nodes |
| **SaveManager** | None | GameState | Filesystem | Hold game logic |
| **UIManager** | Panel visibility stack | EventBus | Emits panel actions | Modify game state |

---

## 7. Data Flow Diagram

### Player Action: Build Track

```
Player clicks BuildMenu → "track_tool"
  → World._input() detects click on grid
    → World requests TrackManager.preview_edge(from, to)
      → TrackManager queries TerrainLayer for terrain_cost_multiplier
      → TrackManager returns preview data: { cost, length_km, terrain }
    → World shows RoutePreviewPanel with preview data

Player confirms build
  → World calls TrackManager.build_edge(from, to)
    → TrackManager validates funds via GameState.can_afford(cost)
    → GameState.deduct_funds(cost) → treasury_changed emitted
    → TrackGraph adds node + edge
    → TrackManager emits track_built
  → World spawns TrackSegment visual in TrackLayer
  → UIManager updates HUD treasury
```

### Player Action: Buy Train & Assign Route

```
Player clicks "Buy Train" in BuildMenu
  → UIManager opens TrainPurchasePanel
  → Player selects TrainData resource
  → UIManager calls TrainManager.purchase_train(train_data_id, owner_faction_id)
    → TrainManager validates funds via GameState
    → GameState.deduct_funds(cost)
    → TrainManager creates TrainState dictionary, assigns ID
    → TrainManager emits train_purchased
  → World spawns TrainEntity in TrainLayer, adds to group "train_group"

Player assigns route (city A → city B)
  → UIManager calls TrainManager.assign_route(train_id, ["city_a", "city_b"])
    → TrainManager requests TrackManager.find_path("city_a", "city_b")
      → TrackManager runs A* on TrackGraph (with cache)
      → Returns path_node_ids or empty if unreachable
    → TrainManager sets TrainState.path_node_ids, state = WaitingForPath/Traveling
  → TrainEntity._process() interpolates along path_node_ids world positions
```

### System Action: Train Arrival

```
TrainEntity reaches destination node
  → TrainEntity calls TrainManager.arrive_at_city(train_id, city_id)
    → TrainManager computes revenue using CityManager.get_price(city_id, cargo)
    → TrainManager calls GameState.add_funds(revenue)
    → TrainManager calls CityManager.add_stock(city_id, cargo_type, quantity)
    → TrainManager calls ContractManager.record_delivery(faction_id, cargo, quantity, city_id)
    → TrainManager updates TrainState.last_trip_revenue / cost / profit
    → TrainManager emits train_arrived, train_delivered, treasury_changed
  → CityPanel refreshes if open
  → ContractPanel refreshes if open
  → TrainPanel refreshes if open
```

---

## 8. Allowed Class Communication Matrix

Rows = can call into columns. "Signal" means via EventBus only.

|  | EventBus | GameState | TimeMgr | EconMgr | TrackMgr | TrainMgr | CityMgr | ContractMgr | EventMgr | SaveMgr | UIManager | World |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **EventBus** | — | — | — | — | — | — | — | — | — | — | — | — |
| **GameState** | Signal | — | Read | Signal | Read | Read | Read | Read | Read | Call | — | — |
| **TimeManager** | Signal | Read | — | Signal | — | — | — | — | — | — | — | — |
| **EconomyManager** | Signal | Call | Read | — | Call | Call | Call | Call | Call | — | — | — |
| **TrackManager** | Signal | Read/Write | — | — | — | Call | Read | — | Read | — | — | — |
| **TrainManager** | Signal | Read/Write | — | — | Call | — | Call | Call | — | — | — | — |
| **CityManager** | Signal | Read/Write | — | — | — | — | — | — | Read | — | — | — |
| **ContractManager** | Signal | Read/Write | — | — | — | — | Read | — | — | — | — | — |
| **EventManager** | Signal | Read/Write | Read | — | Call | Call | Call | — | — | — | — | — |
| **SaveManager** | Signal | Call | — | — | — | — | — | — | — | — | — | — |
| **UIManager** | Signal | — | — | — | — | — | — | — | — | — | — | Call |
| **World** | Signal | — | — | — | Call | Call | Call | — | — | — | — | — |
| **UI Panels** | Signal | — | — | — | — | — | — | — | — | — | Call | — |

### Rules

1. **No circular manager calls.** If two managers need bilateral data, one owns it and the other reads via getter or EventBus signal.
2. **UI never writes game state directly.** UI calls manager methods or emits UI-action signals that managers listen to.
3. **World is the visual coordinator.** It reads from managers to spawn/update/remove nodes. It does not own gameplay state.
4. **EventBus is read-only for listeners.** Never mutate state inside an EventBus callback. Queue state changes for the next frame if needed.

---

## 9. Data-Only Classes vs. Behavior Classes

### Data-Only Classes (Resources, Dictionaries, RefCounted)

These are serializable, contain no `_process`, and never hold node references.

| Class/Type | Kind | Purpose |
|---|---|---|
| `TrackGraph` | `RefCounted` | Adjacency lists for nodes and edges. Pure data structure with query methods. |
| `TrackNodeState` | `Dictionary` | Static properties of a graph node (grid, world, city link, junction). |
| `TrackEdgeState` | `Dictionary` | Static properties of a graph edge (length, cost, owner, condition, toll). |
| `TrainData` | `Resource` | Template data for a train type (speed, capacity, cost, maintenance, sprite). |
| `TrainState` | `Dictionary` | Runtime mutable state of a specific train (position, cargo, route, condition, last trip). |
| `CargoData` | `Resource` | Template data for a cargo type (base price, tags, era). |
| `CityData` | `Resource` | Template data for a city (role, population, produced/demanded cargo). |
| `CityEconomyState` | `Dictionary` | Runtime mutable economy of a city (stock, demand, prices, market share, upgrades). |
| `ContractData` | `Resource` | Template data for a contract (quantity, deadline, reward, penalty). |
| `ContractState` | `Dictionary` | Runtime mutable contract progress (status, delivered, days remaining, owner). |
| `EventData` | `Resource` | Template data for an event (effects, duration, warning). |
| `EventInstance` | `Dictionary` | Runtime active event (event_id, days_remaining, affected_city_ids). |
| `FactionState` | `Dictionary` | Runtime faction data (treasury, reputation, owned techs). |

### Behavior Classes (Nodes, Scripts with Process)

These live in scenes, have lifecycle callbacks, and may render or handle input.

| Class | Extends | Scene Location | Responsibility |
|---|---|---|---|
| `World` | `Node2D` | `scenes/world.tscn` | Coordinates all visual layers. Handles input routing. |
| `CameraController` | `Camera2D` | Child of World | Pan, zoom, bounds clamping. Reads `camera_pan_*` / `camera_zoom_*` input. |
| `TrackRenderer` | `Node2D` | Child of World (TrackLayer) | Draws track segments. Syncs with TrackGraph changes via signals. |
| `CityMarker` | `Node2D` | Child of World (CityMarkers) | Click detection, tooltip, visual state. Added to group `city_group`. |
| `TrainEntity` | `Node2D` | Child of World (TrainLayer) | Interpolates along path. Emits arrival to TrainManager. Added to group `train_group`. |
| `HUD` | `Control` | Child of UIOverlay | Displays treasury, date, speed. Listens to EventBus. |
| `CityPanel` | `Panel` | Child of UIOverlay | Displays city economy. Queries CityManager on open. |
| `TrainPanel` | `Panel` | Child of UIOverlay | Displays train stats. Queries TrainManager on open. |
| `RoutePreviewPanel` | `Panel` | Child of UIOverlay | Displays route economics. Populated by TrackManager preview data. |

---

## 10. Pathfinding Cache Strategy

### Pathfinding Owner: TrackManager

TrackManager exposes:

```gdscript
func find_path(from_node_id: String, to_node_id: String, faction_id: String) -> PackedStringArray
```

### Algorithm

- Use A* with Euclidean heuristic on grid coordinates.
- Cost per edge = `length_km × terrain_cost_multiplier × condition_penalty + toll_penalty_if_non_owner`
- Exclude edges where `access_mode == "private"` and `owner_faction_id != faction_id`.

### Cache Layers

| Cache | Key | Invalidation | TTL |
|---|---|---|---|
| **Per-faction path cache** | `"from_to_faction"` | Any edge added/removed/ownership changed/damaged | Immediate |
| **City-to-city warm cache** | `"city_a_city_b_faction"` | Same as above, but rebuilt lazily | One game day |
| **Neighbor adjacency list** | Node ID | TrackGraph structural change | Immediate |

### Implementation

```gdscript
var _path_cache: Dictionary = {}  # "from_to_faction" -> PackedStringArray

func _invalidate_path_cache() -> void:
    _path_cache.clear()
    EventBus.track_graph_changed.emit()
```

Every `build_edge`, `remove_edge`, `set_edge_owner`, `set_edge_condition`, or `set_edge_access_mode` calls `_invalidate_path_cache()`.

### Performance Budget

- Pathfinding must complete in <2 ms for a 200-edge graph on desktop.
- If graph exceeds 500 edges, consider caching city-to-city paths only and falling back to uncached for arbitrary nodes.

---

## 11. Performance-Critical Sections

| System | Risk | Mitigation |
|---|---|---|
| **Train movement** | Many trains × `_process()` interpolation | Use `Node2D.position` lerp, not physics. Skip hidden trains (off-screen culling). Batch position updates: update every Nth train per frame if count > 50. |
| **TileMap terrain queries** | Called during track placement and pathfinding cost | Cache terrain cost lookup table (`Dictionary[Vector2i, float]`) in TrackManager. Rebuild only on map load or terrain modification. |
| **City price updates** | Daily loop over all cities × all cargo | Precompute cargo lists per city. Use `for` loops, not `get_children()`. Update prices in place; do not allocate new dictionaries unless values changed. |
| **Track rendering** | Rebuilding many Line2D/Sprite2D nodes on large networks | Use `MultiMeshInstance2D` or `TileMapLayer` for track segments once art is final. During development, pool segment nodes (object pool in TrackRenderer). |
| **Save file I/O** | Large JSON stringify on big networks | Save asynchronously where possible. Use `Thread` for stringify on debug builds. Keep save frequency low (manual + auto every 5 minutes). |
| **EventBus signal spam** | Daily tick emits many signals | Coalesce UI refresh signals. UIManager updates panels only if visible; HUD updates use a single `economy_tick` listener rather than per-metric signals. |
| **Contract tick** | Daily iteration over all contracts | Store active contracts in a separate `Array` from available/completed. Tick only active ones. |
| **City marker hover** | Raycast every frame | Use `Area2D` with `mouse_entered`/`mouse_exited` signals. Do not manual distance checks in `_input`. |

### Object Pools

- `TrainEntity` pool in World: reuse nodes when trains are sold or removed.
- `TrackSegment` pool in TrackRenderer: reuse visual nodes when track is modified.
- `CPUParticles2D` pool in EffectsLayer: reuse for build effects, delivery effects.

### Frame Budget Targets

| Context | Target |
|---|---|
| Daily tick (all systems) | <5 ms |
| Train movement update (all trains) | <3 ms |
| Pathfinding (cached) | <0.5 ms |
| Pathfinding (uncached, city-to-city) | <2 ms |
| UI refresh (all visible panels) | <1 ms |

---

## 12. Decision Log

| Decision | Rationale |
|---|---|
| JSON over binary for saves | Human-debuggable during alpha. Migrate to binary or compressed JSON post-Phase 6 if save files exceed 2 MB. |
| A* over Godot Navigation | TrackGraph is sparse, custom, and ownership-aware. NavigationServer does not support per-agent edge costs or private track exclusion easily. |
| Dictionary state over Nodes | Scene nodes are destroyed/recreated on load. Dictionaries are trivially serializable and support save-before-quit. |
| EconomyManager orchestrates tick | Prevents race conditions between city production, demand, and pricing. Centralized order is easier to audit than distributed timers. |
| EventBus for UI updates | Decouples simulation from rendering. Allows pausing UI updates without pausing simulation logic. |
