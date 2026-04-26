# Godot Spec — Contracts Panel

## Scene Hierarchy

```
CanvasLayer (ContractsUI)
├── MainPanel (PanelContainer)
│   ├── Header (HBoxContainer)
│   │   ├── Title (Label) "Contracts"
│   │   ├── FilterTabs (HBoxContainer)
│   │   │   ├── AvailableTab (Button, toggle)
│   │   │   ├── ActiveTab (Button, toggle)
│   │   │   ├── CompletedTab (Button, toggle)
│   │   │   └── FailedTab (Button, toggle)
│   │   └── CloseBtn (Button)
│   ├── SplitView (HBoxContainer)
│   │   ├── ContractList (ScrollContainer, expand)
│   │   │   └── ContractListContent (VBoxContainer)
│   │   │       └── ContractCard (PanelContainer) × N
│   │   │           ├── CardHeader (HBoxContainer)
│   │   │           │   ├── ContractName (Label)
│   │   │           │   └── DeadlineBadge (PanelContainer)
│   │   │           │       └── DeadlineLabel (Label)
│   │   │           ├── CardBody (VBoxContainer)
│   │   │           │   ├── CargoRow (HBoxContainer)
│   │   │           │   │   ├── CargoIcon (TextureRect)
│   │   │           │   │   ├── CargoText (Label)
│   │   │           │   │   └── QuantityLabel (Label)
│   │   │           │   ├── DestinationRow (HBoxContainer)
│   │   │           │   │   ├── LocationIcon (TextureRect)
│   │   │           │   │   └── DestinationLabel (Label)
│   │   │           │   └── RewardRow (HBoxContainer)
│   │   │           │       ├── MoneyReward (Label)
│   │   │           │       └── RepReward (Label)
│   │   │           └── CardFooter (HBoxContainer)
│   │   │               ├── PenaltyLabel (Label)
│   │   │               └── ActionBtn (Button)
│   │   └── DetailPanel (PanelContainer, min 300px)
│   │       ├── DetailHeader (Label)
│   │       ├── DetailMap (TextureRect, placeholder)
│   │       ├── DetailStats (GridContainer, cols=2)
│   │       │   ├── Label "Cargo"
│   │       │   ├── Value "200 tons Coal"
│   │       │   ├── Label "Destination"
│   │       │   ├── Value "Kolkata"
│   │       │   ├── Label "Deadline"
│   │       │   ├── Value "60 days"
│   │       │   ├── Label "Reward"
│   │       │   ├── Value "₹5,000"
│   │       │   ├── Label "Reputation"
│   │       │   ├── Value "+10"
│   │       │   ├── Label "Penalty"
│   │       │   └── Value "₹1,000, -15 rep"
│   │       ├── SuggestedRoute (Label)
│   │       └── DetailActions (HBoxContainer)
│   │           ├── AcceptBtn (Button)
│   │           └── DeclineBtn (Button)
│   └── Footer (HBoxContainer)
│       └── ContractCountLabel (Label)
```

## Node Configuration

### MainPanel
- **Layout:** Anchor Left=0.1, Top=0.1, Right=0.9, Bottom=0.9
- **StyleBoxFlat:** bg_color = parchment, border_width = 2, border_color = brass
- **Min Size:** 1000×600

### FilterTabs
- **Style:** Tab-like buttons with brass underline when active
- **Active:** border_width_bottom = 3, border_color = brass
- **Inactive:** border_width_bottom = 1, border_color = ink-secondary

### ContractCard
- **StyleBoxFlat:** bg_color = #F5E6C8, border_width = 1, border_color = #2F1B14
- **Hover:** bg_color = #E8D8B8
- **Selected:** border_width = 2, border_color = brass, bg_color = #EDE0CC
- **Margin:** 8px all sides
- **Separation:** 12px between cards

### DeadlineBadge
- **Urgent (< 7 days):** bg_color = rust, text = white
- **Soon (< 30 days):** bg_color = brass, text = black
- **Normal:** bg_color = sepia-dark, text = white
- **Corner Radius:** 10 (pill)

### ActionBtn States

| Contract State | Button Text | Style |
|---------------|-------------|-------|
| Available | "Accept" | Brass button |
| Active | "View Progress" | Indigo button |
| Completed | "Claimed" | Grey, disabled |
| Failed | "Failed" | Rust, disabled |

### DetailPanel
- **StyleBoxFlat:** bg_color = #EDE0CC, border_width_left = 2, border_color = brass
- **Visibility:** Hidden when no contract selected

### DetailMap Placeholder
- **Size:** 200×150
- **Color:** sepia-dark with city marker dots
- **Later:** Replace with actual minimap render

## Data Binding

```gdscript
func _populate_contract_list(filter: String) -> void:
    _clear_list()
    var contracts := ContractManager.get_contracts_by_status(filter)
    for contract in contracts:
        _add_contract_card(contract)
    ContractCountLabel.text = "%d contracts" % contracts.size()

func _on_contract_selected(contract_id: String) -> void:
    var contract := ContractManager.get_contract(contract_id)
    DetailPanel.visible = true
    
    # Header
    DetailHeader.text = contract.display_name
    
    # Stats
    DetailStats.get_node("CargoValue").text = "%d tons %s" % [contract.quantity, contract.cargo_name]
    DetailStats.get_node("DestinationValue").text = contract.destination_name
    DetailStats.get_node("DeadlineValue").text = "%d days" % contract.days_remaining
    DetailStats.get_node("RewardValue").text = "₹%d" % contract.reward
    DetailStats.get_node("RepValue").text = "+%d" % contract.reputation_reward
    DetailStats.get_node("PenaltyValue").text = "₹%d, %d rep" % [contract.failure_penalty, contract.reputation_penalty]
    
    # Suggested route
    var suggested := RouteFinder.find_best_route_for_contract(contract)
    SuggestedRoute.text = "Suggested: %s" % suggested.description
```

## Sorting

Default sort order:
1. Urgent deadlines first
2. Higher reward second
3. Lower difficulty third

Player can click column headers to re-sort.

## Signals

```gdscript
signal contract_accepted(contract_id: String)
signal contract_declined(contract_id: String)
signal contract_selected(contract_id: String)
signal panel_closed()
```

## Empty States

| Filter | Empty Message |
|--------|--------------|
| Available | "No contracts available. Check back next month." |
| Active | "No active contracts. Accept one from the Available tab." |
| Completed | "No completed contracts yet." |
| Failed | "No failed contracts. Keep it up." |

Empty state style: Centered text, ink-secondary color, small icon above text.
