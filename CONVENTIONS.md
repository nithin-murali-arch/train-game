# Rail Empire — Coding Conventions

Godot 4.6+ | GDScript | Isometric 2D Railway Tycoon

---

## 1. Naming Conventions

| Element | Case | Example |
|---------|------|---------|
| Files (scripts) | snake_case | `train_movement.gd` |
| Files (scenes) | snake_case | `main.tscn` |
| Files (resources) | snake_case | `coal.tres` |
| Classes | PascalCase | `class_name TrackGraph` |
| Constants | UPPER_SNAKE_CASE | `const MAX_ZOOM := 4.0` |
| Variables | snake_case | `var track_cost: int` |
| Private variables | _leading_underscore | `var _internal_state: Dictionary` |
| Functions | snake_case | `func build_track()` |
| Private functions | _leading_underscore | `func _calculate_cost()` |
| Signals | snake_case | `signal track_built(edge_id)` |
| Enums | PascalCase + UPPER | `enum GameSpeed { PAUSE, SLOW, NORMAL, FAST }` |
| Autoload singletons | PascalCase | `GameState`, `EventBus`, `EconomyManager` |
| Nodes in scene | PascalCase | `TrackRenderer`, `CityPanel` |

---

## 2. File Organization

### Scene + Script Pairing
Every scene `.tscn` has a matching `.gd` script with the same base name.

```
scenes/
  world.tscn
  world.gd         # attached script
```

### One Class Per File
Each `.gd` file defines one class with `class_name`.

```gdscript
# src/tracks/track_graph.gd
class_name TrackGraph
extends RefCounted
```

### Autoload Singletons
Place in `src/autoload/`. Use PascalCase filename matching the class.

```
src/autoload/
  game_state.gd      # class_name GameState
  event_bus.gd       # class_name EventBus
  economy_manager.gd # class_name EconomyManager
```

### Resource Definitions
Place in `src/resources/`. These define custom `Resource` subclasses.

```
src/resources/
  cargo_data.gd
  train_data.gd
  city_data.gd
```

### Data Instances
Place in `data/`. These are `.tres` instances of Resource classes.

```
data/cargo/
  coal.tres
  textiles.tres
```

---

## 3. GDScript Style

### Type Hints
Always use static typing for function signatures, exported variables, and constants.

```gdscript
@export var speed_km_per_hour: float = 2.0
@export var cargo_capacity_tons: int = 200

func calculate_profit(revenue: int, cost: int) -> int:
    return revenue - cost
```

Optional for local variables when the type is obvious.

```gdscript
var distance = start.distance_to(end)  # obvious from context
```

### Exports
Use `@export` for all tunable parameters. This keeps data designable without code changes.

```gdscript
@export var base_price: int = 15
@export var demand_multiplier: float = 1.0
@export var icon: Texture2D
```

### String Formatting
Use `%` for simple formatting, `str()` for concatenation when readable.

```gdscript
var msg := "Built track %s → %s for ₹%d" % [from, to, cost]
var label := str(city_name, ": ₹", price)
```

### Dictionary Access
Use `.get()` with defaults for safe dictionary access.

```gdscript
var price := city_prices.get("coal", 15)
```

---

## 4. Signals and Event Bus

### Local Signals
Use signals within a class for tightly coupled notifications.

```gdscript
signal track_built(edge_id: String, cost: int)
signal train_arrived(train_id: String, city_id: String)
```

### Global Events
Use the `EventBus` autoload for cross-system communication.

```gdscript
# src/autoload/event_bus.gd
class_name EventBus
extends Node

signal economy_tick(day: int)
signal train_delivered(train_id: String, revenue: int)
signal city_clicked(city_id: String)
signal track_selected(edge_id: String)
signal game_speed_changed(speed: float)
```

Emitting:
```gdscript
EventBus.economy_tick.emit(current_day)
```

Listening:
```gdscript
func _ready() -> void:
    EventBus.economy_tick.connect(_on_economy_tick)

func _on_economy_tick(day: int) -> void:
    update_prices(day)
```

### Disconnect Signals
Always disconnect signals in `_exit_tree()` or when removing listeners.

```gdscript
func _exit_tree() -> void:
    EventBus.economy_tick.disconnect(_on_economy_tick)
```

---

## 5. Scene Structure

### Node Naming
Use PascalCase for node names in scenes. Reflects the node's role.

```
WorldMap (Node2D)
  Camera2D (Camera2D)
  TerrainLayer (TileMapLayer)
  TrackLayer (Node2D)
  CityMarkers (Node2D)
  TrainLayer (Node2D)
  UIOverlay (CanvasLayer)
    HUD (Control)
    CityPanel (Panel)
```

### Scene Composition
Prefer composition over deep inheritance. Use child nodes with scripts.

```gdscript
# train_entity.gd
class_name TrainEntity
extends Node2D

@onready var movement: TrainMovement = $Movement
@onready var cargo: TrainCargo = $Cargo
@onready var pathfinder: TrainPathfinder = $Pathfinder
```

---

## 6. Game State and Save/Load

### Serializable State
All runtime gameplay state lives in plain data or dedicated managers. Never store critical state only in scene node paths.

```gdscript
# Good: state in serializable dictionary
var _train_states: Dictionary = {}  # train_id -> TrainState

# Bad: state only in nodes
var _trains := get_tree().get_nodes_in_group("trains")  # not save-safe
```

### Save Format
Use JSON for save files. Keep structure flat and versioned.

```gdscript
const SAVE_VERSION := "0.1"

func save_to_file(path: String) -> void:
    var data := {
        "version": SAVE_VERSION,
        "date": _current_date.to_dictionary(),
        "treasury": _treasury,
        "track_graph": _track_graph.to_dictionary(),
        "trains": _serialize_trains(),
        "cities": _serialize_cities(),
    }
    var json := JSON.stringify(data, "\t")
    FileAccess.open(path, FileAccess.WRITE).store_string(json)
```

---

## 7. Error Handling

### Assertions
Use `assert()` for programmer errors that should never happen in production.

```gdscript
func get_city(city_id: String) -> CityData:
    assert(_cities.has(city_id), "City not found: " + city_id)
    return _cities[city_id]
```

### Defensive Defaults
Use `.get()` and early returns for player-facing or data-driven code.

```gdscript
func get_price(city_id: String, cargo_id: String) -> int:
    var city := _city_economies.get(city_id)
    if city == null:
        push_error("Unknown city: " + city_id)
        return 0
    return city.current_prices.get(cargo_id, 0)
```

---

## 8. Comments

### Why, Not What
Comments explain intent, not restate code.

```gdscript
# Good: explains business rule
# Oversupply penalty: prices crash when stock > 2× demand
var oversupply_factor := min(stock / (demand * 2.0), 1.0)

# Bad: restates the obvious
# Set x to 5
var x := 5
```

### Doc Comments
Use `##` for tooltips and documentation.

```gdscript
## Emitted when a train completes delivery and revenue is calculated.
signal train_delivered(train_id: String, revenue: int)

## Calculates dynamic price based on supply/demand ratio.
## Returns clamped value between 0.5× and 2.0× base price.
func calculate_price(base: int, supply: int, demand: int) -> int:
```

---

## 9. Performance Rules

- Use `Object pools` for frequently created/destroyed nodes (trains, effects).
- Use `Dictionary` lookups over arrays for ID-based access.
- Cache `@onready` references to child nodes.
- Use `CanvasLayer` for UI, not `Node2D` at high Z-index.
- Batch TileMap updates; don't set cells one by one in loops.
- Use `CPUParticles2D` for simple effects before GPU particles.

---

## 10. Sprint Boundaries

- **Do not** add features from future sprints because the structure is ready.
- **Do not** hardcode world data inside UI scripts.
- **Do not** block development on final art. Use geometric placeholders.
- **Do** keep all data-driven content in `Resource` classes or serializable dictionaries.
- **Do** end every sprint with manual test steps.
- **Do** report files changed, manual tests, known issues, and next-sprint readiness.
