# Rail Empire — Godot UI Implementation Notes

This document provides technical guidance for translating the Stitch "Governor's Archive" designs into Godot `Control` nodes.

## Universal UI Architecture
- **Themes**: All UI must be driven by `assets/theme/governor_archive.tres`. Do not override colors or fonts on individual nodes unless absolutely necessary (e.g. dynamic state changes).
- **Fonts**: Use `assets/fonts/heading_font.tres` for `Label` nodes acting as titles. Use `assets/fonts/body_font.tres` for everything else.
- **Layouts**: Never use absolute positioning. Use `MarginContainer` for padding, `VBoxContainer` / `HBoxContainer` for alignment, and `SizeFlags` (Expand/Fill) for responsive scaling at 1920x1080.

## UI-02 Slice: Route Toy HUD Implementation

### `route_toy_playable.tscn`
- **Ownership**: `RouteToyPlayable` owns runtime composition. This includes `TreasuryState`, `SimulationClock`, `RouteRunner`, and `CityRuntimeState` instances as its runtime state.

### `route_toy_hud.tscn`
- **Role**: `RouteToyHUD` binds to `RouteToyPlayable` and reads state through that scene. It displays state and sends user intent, but must not mutate `TreasuryState`, `CityRuntimeState`, `RouteRunner`, or `SimulationClock` internals directly.
- **Root Node**: `CanvasLayer` (layer 10).
- **Layout**: `MarginContainer` taking full rect (`anchors_preset = 15`), with margins set to 16px to create a screen safe zone.
- **Top Strip**: `VBoxContainer` containing an `HBoxContainer` for the top strip.
  - *Left Box*: `Label` nodes for Company Name and Treasury.
  - *Center Box*: Date `Label` and `HBoxContainer` with three `Button` nodes (1x, 2x, 4x).
  - *Right Box*: Route State `Label`.
- **Bottom Strip**: Add an `HBoxContainer` anchored to the bottom (`Control.PRESET_BOTTOM_WIDE`). Place the `CityPriceWatch` on the left, and `RouteProfitWidget` on the right.

### `route_profit_widget.tscn`
- **Root Node**: `PanelContainer` using the default theme style.
- **Layout**: `MarginContainer` > `VBoxContainer` for the title, followed by a `GridContainer` (2 columns) for the key-value data pairs.
- **Dynamic Styling**: Use script-controlled `add_theme_color_override` to turn the profit text `#BA1A1A` if negative, and a subtle green if positive.

### `city_price_watch.tscn`
- **Root Node**: `PanelContainer`.
- **Layout**: `VBoxContainer`.
- **Dynamic Pricing Labels**: A dedicated script function `_update_price_state(state: String)` should be used to swap the text string ("Shortage", "Balanced", "Oversupplied") and apply the muted rust or indigo color overrides dynamically.

### `route_control_overlay.tscn`
- **Root Node**: `PanelContainer` with a custom `StyleBoxFlat` override giving it a slight red/debug tint to clearly separate it from the Governor's Archive gameplay panels.
- **Layout**: `VBoxContainer` populated with standard `Button` nodes.

## Implementation Boundaries (Crucial)
**Do Not Implement**:
- Any UI components that allow creating new trains, building new tracks, or assigning new routes. The Route Toy HUD only *reads* from the existing prototype systems.
- Heavy `ScrollContainer` tables or complex data grids (save these for the full City Panel and Contracts Panel).
- Save/load logic (belongs to Sprint 12, not UI-02).
