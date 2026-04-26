# Godot Spec — City Panel

## Scene Hierarchy

```
CanvasLayer (CityPanelUI)
└── PanelContainer (CityPanel)
    ├── Header (VBoxContainer)
    │   ├── CityName (Label)
    │   ├── CityRole (Label)
    │   └── CloseBtn (Button)
    ├── ScrollContainer (Body)
    │   └── Content (VBoxContainer)
    │       ├── SummaryGrid (GridContainer, cols=2)
    │       │   ├── Label "Population"
    │       │   ├── ValueLabel "Large"
    │       │   ├── Label "Connected Tracks"
    │       │   ├── ValueLabel "2"
    │       │   ├── Label "Station Level"
    │       │   ├── ValueLabel "Basic"
    │       │   ├── Label "Owner Influence"
    │       │   └── ValueLabel "Player 100%"
    │       ├── SectionHeader (Label) "Supply and Demand"
    │       ├── SupplyDemandTable (VBoxContainer)
    │       │   └── TableRow (HBoxContainer) × N
    │       │       ├── CargoIcon (TextureRect, 24×24)
    │       │       ├── CargoName (Label, min 80px)
    │       │       ├── StockLabel (Label, min 70px)
    │       │       ├── DailyChangeLabel (Label, min 80px)
    │       │       ├── DemandLabel (Label, min 60px)
    │       │       ├── PriceLabel (Label, min 70px)
    │       │       └── TrendIcon (Label, min 40px)
    │       ├── SectionHeader (Label) "Special Effects"
    │       ├── EffectsList (VBoxContainer)
    │       │   └── EffectRow (HBoxContainer)
    │       │       ├── EffectIcon (TextureRect)
    │       │       └── EffectText (Label)
    │       ├── SectionHeader (Label) "Actions"
    │       ├── ActionButtons (VBoxContainer)
    │       │   ├── BuildUpgradeBtn (Button)
    │       │   ├── AssignRouteBtn (Button)
    │       │   ├── ViewContractsBtn (Button)
    │       │   └── CenterCameraBtn (Button)
    │       └── WarningChip (PanelContainer)
    │           └── WarningLabel (Label)
    └── Footer (HBoxContainer)
        └── CityIdLabel (Label)
```

## Node Configuration

### CityPanel
- **Layout:** Anchor Left=1, Top=0, Right=1, Bottom=1, Offset Left=-400
- **StyleBoxFlat:** bg_color = parchment, border_width_left = 3, border_color = brass
- **Min Width:** 380px
- **Animation:** Slide in from right (0.2s)

### CityName
- **Font:** Noto Serif, Size = 28, Color = ink-primary
- **Text:** "Kolkata"

### CityRole
- **Font:** Noto Sans, Size = 14, Color = ink-secondary
- **Text:** "Port Metropolis"
- **StyleBoxFlat:** bg_color = sepia-dark, corner_radius = 2

### CloseBtn
- **Text:** "×"
- **Size:** 32×32
- **Style:** Minimal, hover = rust tint

### SummaryGrid
- **Columns:** 2
- **Separation:** Horizontal = 16, Vertical = 8
- **Labels:** Right-aligned, bold for keys
- **Values:** Left-aligned, mono font for numbers

### TableRow
- **Separation:** 8px
- **Background:** Alternate rows get subtle tint (bg_color = #F0E0C0)
- **Hover:** Highlight row (bg_color = #E8D8B8)

### CargoIcon
- **Size:** 24×24
- **Texture:** Procedural colored square (coal=black, textiles=green, grain=gold)
- **Later:** Replace with actual icons

### TrendIcon
- **Rising:** "↑" in green
- **Stable:** "→" in grey
- **Falling:** "↓" in red

### ActionButtons
- **Button Style:** Full-width, brass border, parchment bg
- **Hover:** bg_color = #E8D8B8
- **Pressed:** bg_color = #D4C8A8

### WarningChip
- **StyleBoxFlat:** bg_color = rust with 20% opacity, border_color = rust
- **Corner Radius:** 12 (pill shape)
- **Padding:** 8px horizontal, 4px vertical
- **Text:** "Coal shortage: high-profit delivery opportunity"
- **Font Size:** 13, Color = rust

## Data Binding

```gdscript
func open(city_id: String) -> void:
    var city := CityDataManager.get_city(city_id)
    var economy := EconomyManager.get_city_economy(city_id)
    
    CityName.text = city.display_name
    CityRole.text = city.role
    
    # Summary
    SummaryGrid.get_node("PopulationValue").text = _format_population(city.population)
    SummaryGrid.get_node("TracksValue").text = str(TrackGraph.get_connected_edges(city_id).size())
    SummaryGrid.get_node("StationValue").text = economy.get_station_level_string()
    SummaryGrid.get_node("InfluenceValue").text = _format_influence(economy.market_share)
    
    # Supply/Demand table
    _clear_table()
    for cargo_id in economy.stock.keys():
        _add_cargo_row(cargo_id, economy)
    
    # Warnings
    _update_warnings(economy)
    
    # Show
    visible = true
    _animate_open()
```

## Responsive Behavior

| Screen Width | Panel Width | Behavior |
|-------------|-------------|----------|
| ≥1920 | 400px | Full panel |
| ≥1600 | 380px | Slightly compressed |
| ≥1366 | 360px | Compact mode (hide icons, smaller text) |
| <1366 | 340px | Minimal mode (stack table vertically) |

## Signals

```gdscript
signal panel_opened(city_id: String)
signal panel_closed()
signal build_upgrade_requested(city_id: String)
signal assign_route_requested(city_id: String)
signal view_contracts_requested(city_id: String)
signal center_camera_requested(city_id: String)
```
