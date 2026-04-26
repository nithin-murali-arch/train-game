# Godot Spec — Train Purchase & Route Assignment

## Scene A: Train Purchase Panel

### Scene Hierarchy

```
CanvasLayer (TrainPurchaseUI)
├── DimOverlay (ColorRect, color=black, alpha=0.3)
└── CenterPanel (PanelContainer)
    ├── Header (HBoxContainer)
    │   ├── Title (Label) "Purchase Train"
    │   └── CloseBtn (Button)
    ├── TreasuryRow (HBoxContainer)
    │   ├── Label "Treasury:"
    │   └── TreasuryValue (Label) "₹52,400"
    ├── StationSelector (HBoxContainer)
    │   ├── Label "Home Station:"
    │   └── StationDropdown (OptionButton)
    ├── TrainCardsContainer (HBoxContainer)
    │   └── TrainCard (PanelContainer) × 2
    │       ├── CardHeader (Label) "Freight Engine"
    │       ├── TrainVisual (ColorRect, placeholder)
    │       ├── StatsGrid (GridContainer, cols=2)
    │       │   ├── Label "Cost"
    │       │   ├── Value "₹5,000"
    │       │   ├── Label "Capacity"
    │       │   ├── Value "200 tons"
    │       │   ├── Label "Speed"
    │       │   ├── Value "2 km/tick"
    │       │   ├── Label "Maintenance"
    │       │   └── Value "₹50/day"
    │       ├── Recommendation (Label)
    │       └── BuyBtn (Button)
    └── ComparisonTooltip (PanelContainer, hidden by default)
        └── ComparisonText (Label)
```

### TrainCard Style

```gdscript
var card_normal := StyleBoxFlat.new()
card_normal.bg_color = Color("#F5E6C8")
card_normal.border_width_all = 2
card_normal.border_color = Color("#2F1B14")
card_normal.corner_radius_all = 4

var card_hover := StyleBoxFlat.new()
card_hover.bg_color = Color("#E8D8B8")
card_hover.border_width_all = 2
card_hover.border_color = Color("#B8860B")
```

### TrainVisual Placeholder

- **Type:** ColorRect or TextureRect
- **Size:** 120×80
- **Color:** steel grey (#708090) for Freight, brass (#B8860B) for Mixed
- **Later:** Replace with actual locomotive sprite

### BuyBtn States

| State | Style | Behavior |
|-------|-------|----------|
| Affordable | Brass button | Clickable, emits `train_purchased` |
| Unaffordable | Greyed out | Disabled, tooltip shows "Need ₹X more" |
| Max trains reached | Greyed out | Disabled, tooltip shows "Max trains reached" |

---

## Scene B: Route Assignment Panel

### Scene Hierarchy

```
CanvasLayer (RouteAssignmentUI)
├── DimOverlay (ColorRect, color=black, alpha=0.3)
└── CenterPanel (PanelContainer)
    ├── Header (HBoxContainer)
    │   ├── Title (Label) "Assign Route"
    │   ├── TrainName (Label) "Freight Engine 01"
    │   └── CloseBtn (Button)
    ├── TrainStatus (HBoxContainer)
    │   ├── LocationLabel (Label) "Kolkata"
    │   ├── CargoLabel (Label) "Empty"
    │   ├── CapacityLabel (Label) "200 tons"
    │   └── MaintenanceLabel (Label) "₹50/day"
    ├── RouteBuilder (VBoxContainer)
    │   ├── StepRow (HBoxContainer)
    │   │   ├── StepLabel (Label) "1. Origin"
    │   │   └── OriginDropdown (OptionButton)
    │   ├── StepRow (HBoxContainer)
    │   │   ├── StepLabel (Label) "2. Cargo"
    │   │   └── CargoDropdown (OptionButton)
    │   ├── StepRow (HBoxContainer)
    │   │   ├── StepLabel (Label) "3. Destination"
    │   │   └── DestinationDropdown (OptionButton)
    │   └── StepRow (HBoxContainer)
    │       ├── StepLabel (Label) "4. Loop"
    │       └── LoopToggle (CheckButton)
    ├── ProfitEstimate (PanelContainer)
    │   ├── SectionTitle (Label) "Profit Estimate"
    │   ├── EstimateGrid (GridContainer, cols=2)
    │   │   ├── Label "Buy price at origin"
    │   │   ├── Value "₹8/ton"
    │   │   ├── Label "Sell price at dest"
    │   │   ├── Value "₹27/ton"
    │   │   ├── Label "Revenue per trip"
    │   │   ├── Value "₹5,400"
    │   │   ├── Label "Maintenance per trip"
    │   │   ├── Value "₹300"
    │   │   ├── Label "Net estimate"
    │   │   ├── Value "₹5,100" (green)
    │   │   ├── Label "Risk"
    │   │   └── Value "Kolkata may become oversupplied" (rust)
    │   └── WarningLabel (Label, hidden)
    └── ButtonRow (HBoxContainer)
        ├── StartRouteBtn (Button)
        ├── SaveScheduleBtn (Button)
        └── CancelBtn (Button)
```

### Dropdown Population

```gdscript
func _populate_origin_dropdown() -> void:
    OriginDropdown.clear()
    for city_id in TrackGraph.get_connected_cities(train.current_node):
        var city := CityDataManager.get_city(city_id)
        OriginDropdown.add_item(city.display_name, city_id)

func _populate_cargo_dropdown(origin_id: String) -> void:
    CargoDropdown.clear()
    var economy := EconomyManager.get_city_economy(origin_id)
    for cargo_id in economy.stock.keys():
        if economy.stock[cargo_id] > 0:
            var cargo := CargoDataManager.get_cargo(cargo_id)
            CargoDropdown.add_item(cargo.display_name, cargo_id)

func _populate_destination_dropdown(origin_id: String, cargo_id: String) -> void:
    DestinationDropdown.clear()
    for city_id in CityDataManager.get_all_cities():
        if city_id == origin_id:
            continue
        var economy := EconomyManager.get_city_economy(city_id)
        if economy.demanded_cargo.has(cargo_id):
            var city := CityDataManager.get_city(city_id)
            DestinationDropdown.add_item(city.display_name, city_id)
```

### Profit Estimate Updates

- Updates whenever any dropdown changes
- Uses `RouteProfitabilityCalculator` (shared with track building)
- Warning appears if:
  - Destination is oversupplied (stock > 2× demand)
  - No path exists between origin and destination
  - Train capacity exceeds available cargo at origin

### Map Overlay

- Route path highlighted in player color (indigo)
- Origin marker: pulsing circle
- Destination marker: target crosshair
- Train icon: shown at current location
- Line width: 3px, glow effect via duplicate line with lower alpha

### Signals

```gdscript
signal route_started(train_id: String, origin: String, destination: String, cargo: String, loop: bool)
signal schedule_saved(train_id: String, route_data: Dictionary)
signal panel_closed()
```
