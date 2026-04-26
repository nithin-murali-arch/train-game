# Rail Empire — Debug Tools and Cheat Console

**Version:** 0.1  
**Engine:** Godot 4.2+  
**Applies to:** Debug / Developer builds only  
**Excluded from:** Release, Steam, itch.io, web production builds

---

## 1. Access Methods

### 1.1 F12 Debug Menu (Primary)
- Press `F12` during gameplay to open the Debug Overlay.
- Overlay is a `CanvasLayer` with a `PanelContainer` rooted at the bottom-left of the screen (does not block map clicks).
- Menu is toggleable; pressing `F12` again hides it.
- Visibility is gated by `OS.is_debug_build()` or a feature tag check: `OS.has_feature("debug_tools")`.

### 1.2 Dev Console (Secondary)
- Press `` ` `` (backtick) or `~` to open a Quake-style console overlay.
- Console accepts typed commands with autocomplete (`Tab`).
- Command history persists per session (`Up`/`Down` arrows).
- Console shares the same feature-gate as the F12 menu.

### 1.3 Cheat Codes (Emergency / Playtest)
- For builds where keyboard access is limited (e.g., playtesters on controller), a sequence of UI clicks can unlock debug mode:
  1. Click Treasury display 5 times rapidly.
  2. Click Date display 3 times.
  3. A confirmation toast appears: *"Debug tools enabled for this session."*
- This is controlled by a script on `HUD` that increments counters and checks timing windows.

---

## 2. Debug UI Panel Layout

```
┌─────────────────────────────┐
│  🐛 DEBUG TOOLS              │
├─────────────────────────────┤
│  [Money +10K] [+100K]       │
│  [Spawn Train] [Complete RT]│
│  [+1 Day] [+1 Month] [+1 Yr]│
│  [Fast 8×] [Fast 16×]       │
│  [God Mode] [Reset Econ]    │
│  ─────────────────────────  │
│  [TrackGraph] [Route Viz]   │
│  [Prices] [AI Debug]        │
│  [Events] [Damage] [Repair] │
│  [Print Save]               │
└─────────────────────────────┘
```

All buttons are `Button` nodes with tooltips. Hotkeys are shown in brackets where applicable.

---

## 3. Command Reference

### 3.1 Economy Cheats

| Command / Button | Console Syntax | Effect | Hotkey |
|---|---|---|---|
| **Add Money +₹10,000** | `money 10000` | Increases player treasury by ₹10,000. Bypasses all checks. | `M` |
| **Add Money +₹100,000** | `money 100000` | Increases player treasury by ₹100,000. | `Shift+M` |
| **Reset Economy** | `reset_economy` | Resets all city stock, demand, and prices to default starting values. Does not affect tracks or trains. | — |
| **God Mode** | `god_mode toggle` | When ON: all construction, train purchase, and maintenance costs are ₹0. Toll revenue to player is doubled. Toggle state is printed to console. | `G` |

### 3.2 Time Control

| Command / Button | Console Syntax | Effect | Hotkey |
|---|---|---|---|
| **Advance 1 Day** | `advance_day 1` | Triggers one economy tick, one maintenance tick, one contract tick. Trains move proportionally. | `]` |
| **Advance 1 Month** | `advance_day 30` | Triggers 30 daily ticks in sequence. Events may fire mid-sequence. | `Shift+]` |
| **Advance 1 Year** | `advance_day 365` | Triggers 365 daily ticks. Use sparingly; may cause event spam. | `Ctrl+]` |
| **Fast Simulation 8×** | `speed 8` | Sets game speed to 8×. Overrides normal max of 4×. | `8` |
| **Fast Simulation 16×** | `speed 16` | Sets game speed to 16×. May drop frames; useful for AI stress tests. | `Shift+8` |
| **Normal Speed** | `speed 1` | Returns to 1×. | `1` |

### 3.3 Train & Route Cheats

| Command / Button | Console Syntax | Effect | Hotkey |
|---|---|---|---|
| **Spawn Train at City** | `spawn_train <train_data_id> <city_id>` | Instantly creates a train at the specified city. Defaults to `freight_engine` at player start city if args omitted. | `T` |
| **Complete Current Route Instantly** | `instant_deliver <train_id>` | Teleports the selected (or specified) train to its destination, executes unload/sell/load, and records profit. | `Shift+T` |
| **Damage Selected Track** | `damage_track <edge_id> <amount>` | Reduces condition of the selected track edge by `amount` (0.0–1.0). Defaults to 0.5 if amount omitted. Visual damaged overlay appears immediately. | `D` |
| **Repair All Tracks** | `repair_all` | Sets condition to 1.0 on all track edges owned by player. Removes damaged overlays. | `R` |

### 3.4 Visualization Overlays

| Command / Button | Console Syntax | Effect | Hotkey |
|---|---|---|---|
| **Show TrackGraph Nodes/Edges** | `viz trackgraph toggle` | Draws debug `Line2D` overlays: green dots for nodes, white lines for edges. Edge labels show ID, length, owner, condition. | `F1` |
| **Show Route Path Visualization** | `viz route <train_id> toggle` | Highlights the full assigned route of a train as a thick cyan `Line2D` with directional arrows. | `F2` |
| **Show City Prices Table** | `viz prices toggle` | Opens an in-world debug panel next to each city displaying current stock and price for all cargo. Updates every tick. | `F3` |
| **Show AI Target Route and Score** | `viz ai toggle` | Draws the British AI’s current target route as a red dashed line. Prints route score formula breakdown to console. | `F4` |

### 3.5 Event & State Debug

| Command / Button | Console Syntax | Effect | Hotkey |
|---|---|---|---|
| **Trigger Any Event** | `event_trigger <event_id>` | Immediately fires the specified event (e.g., `event_trigger monsoon_flood`). Skips warning period. | `E` |
| **List Active Events** | `event_list` | Prints all active events with days remaining and affected cities to console. | — |
| **Print Save State to Console** | `print_save` | Serializes the entire runtime state (TrackGraph, trains, cities, treasury, date) to a pretty-printed JSON string in the console. Does not write to disk. | `P` |
| **Print Save State to File** | `dump_save <filename>` | Writes the same JSON to `user://debug_saves/<filename>.json`. Useful for bug reproduction. | `Shift+P` |

---

## 4. Build Inclusion Rules

### 4.1 Debug Builds
- **Condition:** `OS.is_debug_build() == true` (launched from editor or exported with "Export With Debug").
- **Includes:** F12 menu, dev console, cheat click-sequence, all commands.
- **Visual Indicator:** A small "DEBUG" watermark in the bottom-right corner of the screen (opacity 0.3) so playtesters and streamers know cheats are available.

### 4.2 Release Builds
- **Condition:** `OS.is_debug_build() == false` and no `--debug-tools` command-line flag.
- **Excludes:** All debug UIs, console, and cheat sequences.
- **Code Removal:** Debug scripts are present in source but their `_ready()` gates exit early. The `DebugMenu` scene is not added to the main scene tree in release.

### 4.3 Playtest Builds (Special Case)
- Exported release builds intended for external playtesters can be compiled with a custom feature tag: `debug_tools`.
- Enable by adding `debug_tools` to the export preset features or launching with `--feature debug_tools`.
- This exposes the F12 menu and cheat sequence **without** the editor overhead.

---

## 5. Implementation Notes

### 5.1 Autoload
Create a `DebugManager` autoload (`src/autoload/debug_manager.gd`):

```gdscript
class_name DebugManager
extends Node

var god_mode_active: bool = false
var viz_trackgraph: bool = false
var viz_prices: bool = false
var viz_ai: bool = false

func _ready() -> void:
    if not OS.is_debug_build() and not OS.has_feature("debug_tools"):
        set_process_input(false)
        return
    # Register commands...

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("toggle_debug_menu"):
        DebugOverlay.toggle()
    if event.is_action_pressed("toggle_debug_console"):
        DebugConsole.toggle()
```

### 5.2 Console Parser
Use a simple split parser:

```gdscript
func _execute_command(line: String) -> void:
    var parts := line.strip_edges().split(" ")
    var cmd := parts[0]
    var args := parts.slice(1)
    match cmd:
        "money": _cheat_money(args)
        "spawn_train": _cheat_spawn_train(args)
        # ... etc
```

### 5.3 Save Dump Safety
- The `print_save` command must **not** include OS-sensitive data.
- Redact any file paths or user info.
- The JSON should be copy-pasteable into a bug report.

### 5.4 Network Safety
- Even if multiplayer is added later (deferred), debug commands must never execute over RPC.
- `DebugManager` runs locally only.

---

## 6. Acceptance Criteria

- [ ] Pressing `F12` opens/closes the debug panel in debug builds.
- [ ] Pressing `` ` `` opens the console in debug builds.
- [ ] `money 10000` increases treasury by exactly ₹10,000.
- [ ] `spawn_train` creates a train that behaves identically to a purchased train.
- [ ] `viz trackgraph toggle` renders all nodes and edges without crashing at 1,000 segments.
- [ ] `viz ai toggle` shows a red dashed line for the AI’s current target.
- [ ] `god_mode toggle` makes the next track build free.
- [ ] Release build shows no debug UI, console, or watermark.
- [ ] Cheat click-sequence (5× treasury + 3× date) enables debug tools in playtest builds.
