# Rail Empire — Stitch Screen Catalog

*(Note: PNG exports are unavailable via MCP automation, but all screens listed here have been fully generated within the Stitch workspace and are ready for visual review.)*

## IMPLEMENTED IN SPRINT 11 — REVIEW / ALIGNMENT ONLY

### 1. Route Toy HUD
- **Stitch status:** Generated
- **Godot implementation status:** IMPLEMENTED / NEEDS REVIEW
- **Purpose:** Minimal playable HUD for the Route Toy prototype.
- **Primary data sources:** `TreasuryState`, `RouteProfitStats`, `SimulationClock`, `RouteRunner`.
- **Key UI components:** Top-bar strips (Treasury, Date, Speed, Route State), embedded Profit Widget, embedded Price Watch.
- **Godot Control node recommendation:** `CanvasLayer` > `MarginContainer` > `HBoxContainer` / `VBoxContainer` combinations.
- **Open design risks:** Covering too much of the screen during gameplay; scaling issues at different resolutions.

### 2. Route Profit Widget
- **Stitch status:** Generated
- **Godot implementation status:** IMPLEMENTED / NEEDS REVIEW
- **Purpose:** Reusable ledger-style component showing active trip financials.
- **Primary data sources:** `RouteProfitStats`.
- **Key UI components:** Compact rows, brass headers, subtle green/rust profit tints.
- **Godot Control node recommendation:** `PanelContainer` > `GridContainer`.
- **Open design risks:** Long cargo names breaking the grid layout.

### 3. Compact City Price Watch
- **Stitch status:** Generated
- **Godot implementation status:** IMPLEMENTED / NEEDS REVIEW
- **Purpose:** Track local pricing states directly on the HUD without opening City Panels.
- **Primary data sources:** `CityRuntimeState`, `MarketPricing`.
- **Key UI components:** Dynamic pricing state labels (Shortage, Oversupplied).
- **Godot Control node recommendation:** `PanelContainer` > `VBoxContainer`.
- **Open design risks:** Too much noise if we expand to more cities; needs tight spacing.

### 4. Prototype Route Control Overlay
- **Stitch status:** Generated
- **Godot implementation status:** IMPLEMENTED / NEEDS REVIEW
- **Purpose:** Debug panel to control the prototype route.
- **Primary data sources:** Debug commands mapped to `RouteRunner` and `SimulationClock`.
- **Key UI components:** Big, distinct debug buttons (Start, Pause, Reset, Advance).
- **Godot Control node recommendation:** `PanelContainer` positioned off-center, strongly styled to avoid confusion with gameplay UI.
- **Open design risks:** None, as this is strictly a debug/prototype overlay.

---

## DESIGN ONLY

### 5. City Panel v2
- **Stitch status:** Generated
- **Godot implementation status:** DESIGN ONLY
- **Purpose:** Full city breakdown showing target vs runtime stock and pricing.
- **Primary data sources:** `CityData`, `CityRuntimeState`, `MarketPricing`.
- **Key UI components:** Slide-in panel, Grid container for goods, dynamic labels.
- **Godot Control node recommendation:** `PanelContainer` (anchored right) > `ScrollContainer` > `GridContainer`.
- **Open design risks:** Extensibility for later eras when more goods are unlocked.

### 6. Train Panel v2
- **Stitch status:** Generated
- **Godot implementation status:** DESIGN ONLY
- **Purpose:** Train inspection showing loadout and detailed route loop flags.
- **Primary data sources:** `CargoInventory`, `RouteSchedule`.
- **Key UI components:** Inspection card, toggle checkboxes for loop/return empty.
- **Godot Control node recommendation:** Floating `PanelContainer`.
- **Open design risks:** Overlapping with the Route Toy HUD if kept open.

### 7. Route Management Panel v1
- **Stitch status:** Generated
- **Godot implementation status:** DESIGN ONLY
- **Purpose:** Full player-facing route creation UI.
- **Primary data sources:** Player input, `RouteSchedule` factory.
- **Key UI components:** Origin/Destination dropdowns, projection tables.
- **Godot Control node recommendation:** Center `PanelContainer` modal.
- **Open design risks:** Complexity in selecting valid tracks/stations.

### 8. Debug & Validation Screen
- **Stitch status:** Generated
- **Godot implementation status:** DESIGN ONLY
- **Purpose:** Raw data tracking for testing.
- **Primary data sources:** Raw singleton dumps.
- **Key UI components:** Monospace text logs.
- **Godot Control node recommendation:** Fullscreen `ScrollContainer` > `RichTextLabel`.
- **Open design risks:** Text wrapping and performance with huge logs.

---

## FUTURE IMPLEMENTATION

### 9. Track Build Flow
- **Stitch status:** Generated
- **Godot implementation status:** FUTURE IMPLEMENTATION
- **Purpose:** Tile placement and cost projections.
- **Primary data sources:** `EconomyTickSystem`, TileMap.

### 10. Train Purchase Modal
- **Stitch status:** Generated
- **Godot implementation status:** FUTURE IMPLEMENTATION
- **Purpose:** Buying new locomotives.
- **Primary data sources:** `TreasuryState`, Train data assets.

### 11. Route Assignment UI
- **Stitch status:** Generated
- **Godot implementation status:** FUTURE IMPLEMENTATION
- **Purpose:** Assigning purchased trains to routes.

### 12. Contracts Panel
- **Stitch status:** Generated
- **Godot implementation status:** FUTURE IMPLEMENTATION
- **Purpose:** Accepting external delivery requests.

### 13. Station Upgrades
- **Stitch status:** Generated
- **Godot implementation status:** FUTURE IMPLEMENTATION
- **Purpose:** Expanding city station capacities.

### 14. Technology Auction
- **Stitch status:** Generated
- **Godot implementation status:** FUTURE IMPLEMENTATION
- **Purpose:** Bidding on new tech trees.

### 15. Rival Overview
- **Stitch status:** Generated
- **Godot implementation status:** FUTURE IMPLEMENTATION
- **Purpose:** Checking AI competitor stats.

### 16. Event Notification / 17. Event Log
- **Stitch status:** Generated
- **Godot implementation status:** FUTURE IMPLEMENTATION
- **Purpose:** Tracking historical pop-ups.

### 18. Campaign Act Briefing / 19. Scenario Selection
- **Stitch status:** Generated
- **Godot implementation status:** FUTURE IMPLEMENTATION
- **Purpose:** Meta-progression menus.

### 20. Save/Load / 21. Victory/Defeat
- **Stitch status:** Generated
- **Godot implementation status:** FUTURE IMPLEMENTATION
- **Purpose:** Game state management and endgame screens.
