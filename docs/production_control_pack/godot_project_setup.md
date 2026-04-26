# Rail Empire — Godot Project Setup

Version: 0.1  
Engine: Godot 4.6.1 stable  
Scope: Exact conventions for scenes, scripts, inputs, layers, groups, and project configuration.  
Authority: Deviations require updating this document.

---

## 1. Engine Version

- **Required:** Godot 4.6.1 stable (official build)
- **Renderer:** `gl_compatibility` (set in `project.godot`)
- **Feature tag:** `4.6`
- **Do not** use beta, RC, or custom engine builds without team consensus.

---

## 2. Folder Naming Rules

All folder names are `snake_case`.

```
res://
├── assets/                 # Imported art, audio, fonts
│   ├── sprites/
│   ├── tilesets/
│   ├── audio/
│   └── fonts/
├── data/                   # .tres Resource instances
│   ├── cargo/
│   ├── trains/
│   ├── cities/
│   ├── contracts/
│   └── events/
├── docs/                   # Design and production docs
│   └── production_control_pack/
├── scenes/                 # Top-level and reusable scenes
│   ├── main.tscn
│   ├── world.tscn
│   └── ui/
├── src/                    # All scripts
│   ├── autoload/           # Singleton scripts (see §5)
│   ├── resources/          # Custom Resource class definitions
│   ├── tracks/
│   ├── trains/
│   ├── cities/
│   ├── contracts/
│   ├── events/
│   ├── ui/                 # UI panel scripts
│   └── utils/              # Helpers, math, serializers
└── shaders/                # .gdshader files
```

### Rules

- No spaces in folder names.
- No `src/scripts/` subfolder; scripts live next to their domain (`tracks/`, `trains/`, etc.).
- UI scripts go in `src/ui/` even if their scenes are in `scenes/ui/`.
- `autoload/` is the only exception: scripts live there, but there is no `scenes/autoload/`.

---

## 3. Scene Naming Rules

| Rule | Format | Example |
|---|---|---|
| Scene files | `snake_case.tscn` | `main.tscn`, `train_entity.tscn` |
| UI scene files | `snake_case.tscn` | `city_panel.tscn`, `hud.tscn` |
| One scene per functional unit | — | `train_entity.tscn` contains the train visual + movement script |
| Scene + script pairing | Same base name | `world.tscn` + `world.gd` (in `src/` or same folder if small) |

### Preferred Organization

- Keep `.tscn` files in `scenes/` or `scenes/ui/`.
- The attached `.gd` script may live in `src/<domain>/` if it is shared or large.
- If a scene is tightly coupled to one script and both are small, they may coexist in `scenes/`.

---

## 4. Script Naming Rules

| Element | Case | Example |
|---|---|---|
| Script files | `snake_case.gd` | `track_graph.gd`, `train_movement.gd` |
| `class_name` | `PascalCase` | `TrackGraph`, `TrainMovement` |
| Autoload scripts | `snake_case.gd` (file), `PascalCase` (class) | `game_state.gd` → `class_name GameState` |
| Utility scripts | `snake_case.gd` | `pathfinding_utils.gd` |
| Tool scripts | Prefix `tool_` if editor-only | `tool_map_importer.gd` |

### One Class Per File

Every `.gd` file declares exactly one `class_name`. No multiple classes in one file.

```gdscript
# src/tracks/track_graph.gd
class_name TrackGraph
extends RefCounted
```

---

## 5. Input Map

Defined in `project.godot` under `[input]`. All actions use `snake_case`.

### Current Actions (from project.godot)

| Action | Default Binding | Context |
|---|---|---|
| `camera_pan_up` | W | Map pan |
| `camera_pan_down` | S | Map pan |
| `camera_pan_left` | A | Map pan |
| `camera_pan_right` | D | Map pan |
| `camera_zoom_in` | Mouse Wheel Up | Map zoom |
| `camera_zoom_out` | Mouse Wheel Down | Map zoom |
| `click_select` | LMB | Select / build primary |
| `click_secondary` | RMB | Cancel / context menu |
| `game_speed_pause` | Space | Pause time |
| `game_speed_1x` | 1 | Normal speed |
| `game_speed_2x` | 2 | 2× speed |
| `game_speed_4x` | 3 | 4× speed |
| `save_game` | Ctrl+S | Manual save |
| `load_game` | Ctrl+O | Manual load |

### Missing Actions (add before Phase 1)

| Action | Suggested Binding | Context |
|---|---|---|
| `cancel_build` | Escape or RMB | Exit current build tool |
| `toggle_route_preview` | Shift + LMB | Preview route without building |
| `delete_selection` | Delete or X | Remove selected train / track segment |
| `next_train` | Tab | Cycle selection to next train |
| `toggle_ui` | F10 | Hide/show HUD for screenshots |
| `debug_speed_8x` | 4 | Debug-only speed (not in release) |
| `debug_give_money` | F1 | Debug: add ₹10,000 (dev builds only) |
| `debug_force_event` | F2 | Debug: trigger random event (dev builds only) |

### How to Add an Action

1. Open **Project → Project Settings → Input Map**.
2. Add action name in `snake_case`.
3. Assign at least one `InputEvent`.
4. Update this document.
5. Reference in code via `Input.is_action_just_pressed("action_name")`.

---

## 6. Autoload List with Load Order

Defined in `project.godot` under `[autoload]`.

| Order | Singleton | Script Path | Load Priority |
|---|---|---|---|
| 1 | `EventBus` | `src/autoload/event_bus.gd` | Must be first; all others emit to it |
| 2 | `GameState` | `src/autoload/game_state.gd` | Initializes empty state dictionaries |
| 3 | `TimeManager` | `src/autoload/time_manager.gd` | Reads initial date from GameState |
| 4 | `EconomyManager` | `src/autoload/economy_manager.gd` | Connects to TimeManager signals |
| 5 | `TrackManager` | `src/autoload/track_manager.gd` | Creates empty TrackGraph |
| 6 | `TrainManager` | `src/autoload/train_manager.gd` | Empty train state dictionary |
| 7 | `CityManager` | `src/autoload/city_manager.gd` | Loads city data from `data/cities/` |
| 8 | `ContractManager` | `src/autoload/contract_manager.gd` | Loads contract templates |
| 9 | `EventManager` | `src/autoload/event_manager.gd` | Loads event templates |
| 10 | `SaveManager` | `src/autoload/save_manager.gd` | File system ready |
| 11 | `UIManager` | `src/autoload/ui_manager.gd` | UI coordination ready last |

### Load Order Rule

New autoloads must be inserted at the correct dependency position. If a new singleton depends on `GameState` and `EventBus`, place it after `GameState`. If it depends on domain managers, place it after the last dependency.

---

## 7. Collision Layers and Masks

### Render Layers (`2d_render/layer_*`)

Defined in `project.godot` under `[layer_names]`.

| Layer Index | Name | Contents |
|---|---|---|
| 1 | `terrain` | TileMapLayer terrain tiles |
| 2 | `tracks` | Track segment sprites / Line2D |
| 3 | `stations` | Station upgrade visuals |
| 4 | `trains` | TrainEntity sprites |
| 5 | `ui_overlay` | World-space UI elements (tooltips, selection boxes) |

### Physics Layers (`2d_physics/layer_*`)

| Layer Index | Name | Contents | Collision Mask |
|---|---|---|---|
| 1 | `world` | CityMarker Area2D, TrainEntity Area2D, track clickable areas | — |
| 2 | `ui` | UI-blocking input regions (modal blocker, menus) | — |

### Usage Rules

- City markers use `Area2D` on physics layer 1 for `mouse_entered` / `input_event`.
- Train entities use `Area2D` on physics layer 1 for selection and collision.
- The `ModalBlocker` ColorRect uses an invisible `Area2D` on physics layer 2 to consume clicks when a modal is open.
- No `CharacterBody2D` or `RigidBody2D` for trains unless explicitly required in a later phase.

---

## 8. TileMap Layer Usage

The `TerrainLayer` (`TileMapLayer` node under World) uses the following tile layers internally:

| TileMap Layer Index | Purpose | TileSet Atlas Coords |
|---|---|---|
| 0 | **Base Terrain** | Plains, Forest, Hills |
| 1 | **Water** | Rivers, Lakes |
| 2 | **Elevations** | Hill shading, cliffs |
| 3 | **Decorations** | Trees, rocks, crops (non-colliding) |

### Rules

- Track placement reads terrain from layer 0 and water from layer 1 to compute `terrain_cost_multiplier`.
- City positions are fixed and not stored in the TileMap; they are `CityMarker` nodes.
- Do not place track tiles in the TileMap; tracks are rendered as sprites in `TrackLayer` (Node2D).
- Bridge visuals may use TileMap layer 1 overlays in later phases, but track logic remains in TrackGraph.

---

## 9. Groups

Groups are registered at runtime via `add_to_group()` or in the Inspector.

| Group Name | Added To | Purpose |
|---|---|---|
| `train_group` | `TrainEntity` nodes | Batch operations: pause movement, highlight player trains |
| `city_group` | `CityMarker` nodes | Iterate all cities for UI updates, map overlays |
| `track_group` | `TrackSegment` nodes | Batch hide/show, tint by ownership |
| `station_group` | Station upgrade visuals | Iterate stations for upgrade indicators |
| `ui_panel` | All UI panels (`CityPanel`, `TrainPanel`, etc.) | UIManager can close all with one call |
| `selectable` | CityMarker, TrainEntity, TrackSegment | Unified selection raycast target |
| `effect_particle` | `CPUParticles2D` nodes | Object pool reclamation |
| `persist` | Nodes that survive scene changes (none currently) | Future-proofing for multi-scene flows |

### Group API

```gdscript
# Add in _ready()
add_to_group("train_group")

# Query
var trains = get_tree().get_nodes_in_group("train_group")

# Bulk signal
get_tree().call_group("train_group", "set_movement_enabled", false)
```

---

## 10. Node Naming Conventions in Scenes

All node names in the scene tree use `PascalCase`. Names must be unique within their parent.

| Node Type | Example Name | Role |
|---|---|---|
| Root of scene | `World`, `CityPanel`, `TrainEntity` | Matches scene purpose |
| Camera | `MainCamera` | Only one active camera |
| TileMapLayer | `TerrainLayer` | Isometric terrain |
| Layer containers | `TrackLayer`, `TrainLayer`, `CityMarkers`, `StationLayer` | Holds domain objects |
| UI panels | `CityPanel`, `TrainPanel`, `RoutePreviewPanel` | Matches script class if any |
| HUD elements | `TreasuryLabel`, `DateLabel`, `SpeedButtonContainer` | Self-describing |
| Buttons | `BuildTrackButton`, `BuyTrainButton`, `PauseButton` | Action + widget type |
| Labels | `CityNameLabel`, `ProfitValueLabel` | Data + widget type |
| Containers | `BuildMenuContainer`, `ModalBlocker` | Layout role |
| Effects | `BuildEffectParticles`, `DeliverySparkParticles` | Effect type |
| Sprite2D | `TrainSprite`, `CityIcon` | Domain + visual type |

### Forbidden Patterns

- Do not use default Godot names like `Node2D`, `Panel`, `Button` without renaming.
- Do not use spaces or `snake_case` for node names.
- Do not duplicate names under the same parent.

---

## 11. Debug Shortcuts

Debug actions are defined in the input map (§5) and gated by `OS.is_debug_build()`.

| Shortcut | Action | Implementation Location |
|---|---|---|
| `4` | `debug_speed_8x` | TimeManager: sets speed to 8× if debug |
| `F1` | `debug_give_money` | GameState: adds ₹10,000 to player treasury |
| `F2` | `debug_force_event` | EventManager: triggers a random valid event immediately |
| `F3` | — | Toggle collision shape visibility (`DebugCollisionShapes`) |
| `F5` | — | Quick save to `user://debug_save.json` |
| `F9` | — | Quick load from `user://debug_save.json` |
| `F12` | — | Capture screenshot to `user://screenshots/` |

### Debug Overlay

In debug builds, `DebugOverlay` (CanvasLayer) displays:

- FPS and frame time
- Active train count
- Pathfinding cache hit rate
- Daily tick duration (ms)
- Current game date and real time

Toggle with `` ` `` (backtick) or `Shift+F1`.

---

## 12. Export Targets

| Platform | Status | Notes |
|---|---|---|
| Windows (x86_64) | Primary | First-class target |
| macOS (x86_64 + Apple Silicon) | Primary | Universal binary preferred |
| Linux (x86_64) | Secondary | Tested on Ubuntu 22.04+ |
| Web (HTML5) | Future | Deferred until after Phase 6; requires GLES2 fallback testing |
| Mobile | Out of scope | UI not designed for touch-first |

### Export Presets

Create the following presets in **Project → Export**:

1. `Windows Desktop`
   - Export path: `builds/windows/RailEmpire.exe`
   - Embed PCK: yes

2. `macOS`
   - Export path: `builds/macos/RailEmpire.zip`
   - Application identifier: `com.studio.railempire`

3. `Linux/X11`
   - Export path: `builds/linux/RailEmpire.x86_64`

### Build Rules

- Export from a clean commit.
- Include `project.godot`, `src/`, `scenes/`, `assets/`, `data/`, but exclude `docs/` and `.planning/`.
- Version string in export must match `project.godot` `config/version`.

---

## 13. Import Settings Defaults

Set these in **Project → Project Settings → Import Defaults** or via `.godot/imported/` metadata.

| Asset Type | Default Setting | Rationale |
|---|---|---|
| **2D Pixel Art Sprites** | `Filter: Nearest`, `Mipmaps: Disabled` | Crisp pixel edges |
| **2D HD Sprites** | `Filter: Linear`, `Mipmaps: On` | Smooth scaling for UI |
| **Isometric Tiles** | `Filter: Nearest`, `Texture Repeat: Disabled` | Tile edges must align |
| **Audio (SFX)** | `Import as: WAV (force 16-bit)`, `Loop: Disabled` | Low-latency playback |
| **Audio (Music)** | `Import as: Ogg Vorbis`, `Loop: Enabled` | Streaming, compressed |
| **Fonts** | `Import as: Font Data (Dynamic)`, `Oversampling: 2` | Sharp UI text |

### Texture Atlas Policy

- Atlas small UI icons (`assets/sprites/ui/`) into a single `Texture2DArray` or `AtlasTexture` once count exceeds 20.
- Do not atlas large terrain tiles; they are drawn via TileMap.

---

## 14. How to Add New Autoloads

### Process

1. **Create the script** in `src/autoload/<name>.gd`.
   - Use `class_name` in `PascalCase` matching the file name (e.g., `AchievementManager` in `achievement_manager.gd`).
   - Extend `Node` unless you have a reason to extend something else.

2. **Implement lifecycle safely:**
   ```gdscript
   extends Node
   class_name AchievementManager

   func _ready() -> void:
       # Safe to reference other singletons here
       EventBus.economy_tick.connect(_on_economy_tick)
   ```

3. **Register in `project.godot`:**
   - Open **Project → Project Settings → Autoload**.
   - Add the script path: `*res://src/autoload/achievement_manager.gd`.
   - Name must match `class_name`: `AchievementManager`.
   - Move it to the correct load order position using the arrow buttons.

4. **Update this document:**
   - Add to the autoload table in §6.
   - Update the load order diagram.
   - Update the communication matrix in `technical_architecture.md` §8.

5. **Commit with message:**
   ```
   feat: add AchievementManager autoload
   ```

### Checklist

- [ ] Script uses `class_name`.
- [ ] Script does not call other singletons in `_init()`.
- [ ] Script is placed in `src/autoload/`.
- [ ] Entry added to `project.godot` Autoload tab.
- [ ] Load order respects dependencies.
- [ ] Both architecture docs updated.
- [ ] No duplicate autoload names.

---

## 15. Project Settings Reference

Key non-default values from `project.godot`:

```ini
[application]
config/name="Rail Empire"
config/version="0.1.0"
config/features=PackedStringArray("4.6", "GL Compatibility")
run/main_scene="res://scenes/main.tscn"

[display]
window/size/viewport_width=1920
window/size/viewport_height=1080
window/size/mode=2                    ; Maximized
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"

[rendering]
renderer/rendering_method="gl_compatibility"
textures/canvas_textures/default_texture_filter=0   ; Nearest (pixel art)

[debug]
gdscript/warnings/unused_variable=0
gdscript/warnings/unused_signal=0
```

### Do Not Change Without Discussion

- `renderer/rendering_method` — GL Compatibility is required for web fallback.
- `window/stretch/mode` — `canvas_items` ensures UI scales correctly.
- `textures/canvas_textures/default_texture_filter` — `0` (Nearest) is the art direction baseline.
