# Rail Empire — Sprint 11 HUD Review

This document reviews the Route Toy HUD implemented in Sprint 11 against the official Stitch UI-02 designs ("Governor's Archive").

## 1. Matches to Stitch Design
- **Data Binding**: The HUD successfully reads from `RouteToyPlayable` cleanly without mutating state. It fetches Treasury, Date, Market pricing, and Route stats correctly.
- **Node Architecture**: Uses the recommended `CanvasLayer` root and `MarginContainer` > `VBoxContainer` / `HBoxContainer` structures.
- **Theme**: It correctly uses the `governor_archive.tres` theme for its core visual identity (parchment and ink).
- **Core Widgets**: All requested data elements are present (Profit stats, Route stats, Speed controls, City market watch).

## 2. Differences & Deviations
| Stitch Design | Sprint 11 Implementation | Status |
|---------------|--------------------------|--------|
| **City Price Watch**: Bottom-Left. | **Market Panel**: Anchored to Middle-Right. | Acceptable for MVP. |
| **Profit Widget**: Bottom-Right. | **Profit Widget**: Anchored to Bottom-Center. | Acceptable for MVP. |
| **Route Controls**: Distinct panel (off-center). | **Controls Widget**: Anchored Bottom-Left. | Acceptable for MVP. |
| **Dynamic Pricing Styling**: Colors for Shortage (Rust) & Oversupply (Indigo). | **Text Only**: Just text labels ("Shortage"), no color tinting. | Needs future adjustment. |
| **Profit Styling**: Green/Rust tints based on margin. | **Text Only**: Default black ink for all profit numbers. | Needs future adjustment. |
| **Debug Visuals**: Controls have a red debug `StyleBoxFlat`. | **Default Visuals**: Controls use the standard brass button theme. | Needs future adjustment. |

## 3. Readability & Thematic Consistency Issues
- **Missing Color Cues**: Because the dynamic pricing states and profit values don't have the script-level `add_theme_color_override` implemented, it is slightly harder to parse "at a glance" if a route is losing money or if a city is in shortage.
- **Theme Adherence**: The default Governor's Archive theme applies well, but the Prototype Route Control buttons look like official gameplay buttons because they lack the "Debug" red styling. This risks confusing playtesters about what is an actual game feature vs a prototype test tool.

## 4. Map Obscuration
- The HUD pushes elements to the edges (Top Bar, Middle-Right, Bottom-Center, Bottom-Left), keeping the exact center open for the world map and trains.
- **Risk**: The `RightPanel` (Market) might obscure important right-side map tiles if the resolution is scaled down, but at 1920x1080, the center viewport remains highly visible. This layout is acceptable for the Route Toy prototype.

## 5. Conclusion
**Verdict**: The Sprint 11 HUD is functionally excellent and perfectly respects the strict read-only boundary rule. 

**Next Actions (Future Polish)**:
- Add the `add_theme_color_override` script logic to `_update_trip_stats()` and `_update_city_info()` to tint profits and shortages.
- Apply a custom `StyleBoxFlat` to the `ControlsWidget` to visually separate it as a debug tool.
