# Godot Spec — Track Building Flow

## Scene Hierarchy

```
CanvasLayer (TrackBuildingUI)
├── MapOverlay (Node2D)
│   ├── PreviewLine (Line2D)
│   ├── CostMarkers (Node2D)
│   │   └── CostMarker (Label) × N
│   └── InvalidOverlay (Polygon2D)
├── CursorTooltip (PanelContainer)
│   ├── TerrainList (VBoxContainer)
│   │   ├── TerrainRow (HBoxContainer) × N
│   │   │   ├── TerrainName (Label)
│   │   │   ├── Distance (Label)
│   │   │   ├── Rate (Label)
│   │   │   └── Subtotal (Label)
│   │   └── TotalRow (HBoxContainer)
│   │       ├── TotalLabel (Label)
│   │       └── TotalValue (Label)
│   └── TreasuryPreview (Label)
└── BottomConfirmationPanel (PanelContainer)
    ├── RouteInfo (VBoxContainer)
    │   ├── RouteLabel (Label)
    │   ├── ConstructionCost (Label)
    │   ├── RevenueEstimate (Label)
    │   └── BreakEvenLabel (Label)
    └── ButtonRow (HBoxContainer)
        ├── ConfirmBtn (Button)
        ├── AdjustBtn (Button)
        └── CancelBtn (Button)
```

## Node Configuration

### PreviewLine (Line2D)
- **Default:** Width = 4, Color = indigo
- **Invalid:** Color = rust, Dash pattern = [8, 4]
- **Z-index:** 10 (above terrain, below trains)

### CostMarkers
- **Type:** Label nodes positioned along the line
- **Text:** "₹4,000", Font Size = 12
- **Background:** StyleBoxFlat, bg_color = parchment, corner_radius = 2

### InvalidOverlay
- **Type:** Polygon2D
- **Color:** rust with 30% opacity
- **Shape:** Covers invalid terrain tiles

### CursorTooltip
- **Follows:** Mouse cursor with offset (20, 20)
- **Visibility:** Only when hovering valid build area
- **StyleBoxFlat:** bg_color = parchment, border_width = 1, border_color = ink-primary

### TerrainRow Layout
```
HBoxContainer
├── Label "Plains" (expand, min 80px)
├── Label "8 km" (expand, min 60px)
├── Label "× ₹500" (expand, min 70px)
└── Label "= ₹4,000" (expand, min 80px, align right)
```

### BottomConfirmationPanel
- **Layout:** Anchor Left=0.2, Top=1, Right=0.8, Bottom=1, Offset Top=-140
- **StyleBoxFlat:** bg_color = sepia-dark, border_width_top = 3, border_color = brass

### TreasuryPreview
- **Text:** "Treasury: ₹52,400 → ₹45,400"
- **Color:** White if affordable, rust if over budget

## State Machine

```gdscript
enum BuildState {
    IDLE,           # No build active
    SELECT_ORIGIN,  # Waiting for origin click
    SELECT_TARGET,  # Showing preview, waiting for target click
    CONFIRM,        # Showing confirmation panel
    BUILDING        # Animation/cost deduction
}
```

## Validation Rules

| Check | Valid | Invalid |
|-------|-------|---------|
| Treasury >= cost | Green preview | Red preview, disabled confirm |
| Path exists on map | Solid line | Dashed line |
| No overlapping track | Normal | Rust overlay + "Track exists" |
| Within map bounds | Normal | Red border + "Out of bounds" |

## Signals

```gdscript
signal build_preview_started(origin_city_id: String)
signal build_preview_updated(target_city_id: String, cost: int, valid: bool)
signal build_confirmed(origin_city_id: String, target_city_id: String, cost: int)
signal build_cancelled()
```

## Implementation Notes

- Preview line updates every frame while in SELECT_TARGET state
- Cost tooltip follows mouse but stays within screen bounds
- Confirmation panel only appears after second click (target selected)
- Treasury preview turns red and shows "Insufficient Funds" if cost > treasury
- Adjust Route returns to SELECT_TARGET without resetting origin
