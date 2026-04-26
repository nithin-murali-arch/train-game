# Godot Spec — Main Game HUD

## Scene Hierarchy

```
CanvasLayer (HUD)
├── TopBar (HBoxContainer)
│   ├── CompanyInfo (VBoxContainer)
│   │   ├── CompanyName (Label)
│   │   ├── TreasuryLabel (Label)
│   │   └── ReputationLabel (Label)
│   ├── DateTimeControls (VBoxContainer)
│   │   ├── DateLabel (Label)
│   │   └── SpeedControls (HBoxContainer)
│   │       ├── PauseBtn (Button)
│   │       ├── Speed1xBtn (Button)
│   │       ├── Speed2xBtn (Button)
│   │       └── Speed4xBtn (Button)
│   └── AlertArea (PanelContainer)
│       └── AlertLabel (Label)
├── LeftToolbar (VBoxContainer)
│   ├── BuildTrackBtn (Button)
│   ├── BuyTrainBtn (Button)
│   ├── RoutesBtn (Button)
│   ├── ContractsBtn (Button)
│   └── ReportsBtn (Button)
├── BottomBar (HBoxContainer)
│   ├── ToolHints (PanelContainer)
│   │   └── HintLabel (Label)
│   ├── ActionBar (HBoxContainer)
│   │   ├── ConfirmBtn (Button)
│   │   ├── CancelBtn (Button)
│   │   └── CostLabel (Label)
│   └── ProfitabilityWidget (PanelContainer)
│       ├── RevenueLabel (Label)
│       ├── CostLabel (Label)
│       └── BreakEvenLabel (Label)
└── RightEventLog (TabContainer)
    └── EventLogTab (ScrollContainer)
        └── EventLogList (VBoxContainer)
```

## Node Configuration

### TopBar
- **Type:** HBoxContainer
- **Layout:** Anchor Left=0, Top=0, Right=1, Bottom=0, Offset Bottom=80
- **Theme Override:** Separation = 20

### CompanyInfo
- **TreasuryLabel:** Text = "₹52,400", Font Size = 24, Color = brass
- **ReputationLabel:** Text = "Reputation: 12", Font Size = 14, Color = ink-secondary

### DateTimeControls
- **DateLabel:** Text = "March 1857", Font Size = 20, Align = Center
- **SpeedButtons:** Toggle mode, Pressed = Speed1xBtn

### AlertArea
- **StyleBoxFlat:** bg_color = parchment, border_width = 2, border_color = rust
- **AlertLabel:** Text color = ink-primary

### LeftToolbar
- **Layout:** Anchor Left=0, Top=0.15, Right=0, Bottom=0.85, Offset Right=60
- **Buttons:** Icon + text vertical, Size = 56×56

### BottomBar
- **Layout:** Anchor Left=0, Top=1, Right=1, Bottom=1, Offset Top=-100

### ActionBar
- **ConfirmBtn:** Text = "Confirm Build", Style = brass accent
- **CancelBtn:** Text = "Cancel", Style = rust accent
- **CostLabel:** Text = "₹7,000", Color = rust if unaffordable

### ProfitabilityWidget
- **StyleBoxFlat:** bg_color = parchment, border_width = 1, border_color = ink-secondary
- **Labels:** Right-aligned, mono font for numbers

### RightEventLog
- **Layout:** Anchor Left=1, Top=0.15, Right=1, Bottom=0.85, Offset Left=-250
- **Collapsed:** Offset Left = -240 (tab handle visible only)

## StyleBoxFlat Presets

```gdscript
# Parchment panel
var parchment_style := StyleBoxFlat.new()
parchment_style.bg_color = Color("#F5E6C8")
parchment_style.border_width_all = 1
parchment_style.border_color = Color("#2F1B14")
parchment_style.corner_radius_all = 2

# Brass button (normal)
var brass_button_normal := StyleBoxFlat.new()
brass_button_normal.bg_color = Color("#B8860B")
brass_button_normal.border_width_all = 2
brass_button_normal.border_color = Color("#D4AF37")
brass_button_normal.corner_radius_all = 3

# Brass button (pressed)
var brass_button_pressed := StyleBoxFlat.new()
brass_button_pressed.bg_color = Color("#8B6914")
brass_button_pressed.border_width_all = 2
brass_button_pressed.border_color = Color("#D4AF37")

# Rust button (cancel/danger)
var rust_button_normal := StyleBoxFlat.new()
rust_button_normal.bg_color = Color("#8B4513")
rust_button_normal.border_width_all = 2
rust_button_normal.border_color = Color("#A0522D")
```

## Theme Constants

```gdscript
const COLOR_PARCHMENT = Color("#F5E6C8")
const COLOR_SEPHIA_DARK = Color("#3D2B1F")
const COLOR_INK_PRIMARY = Color("#1A1A1A")
const COLOR_INK_SECONDARY = Color("#5C4A3A")
const COLOR_BRASS = Color("#B8860B")
const COLOR_BRASS_LIGHT = Color("#D4AF37")
const COLOR_INDIGO = Color("#4B0082")
const COLOR_RUST = Color("#8B4513")
const COLOR_RUST_LIGHT = Color("#A0522D")
```

## Input Integration

| Input Action | Handler |
|-------------|---------|
| `game_speed_pause` | Toggle pause |
| `game_speed_1x` | Set speed 1× |
| `game_speed_2x` | Set speed 2× |
| `game_speed_4x` | Set speed 4× |
| `click_select` | Select city/train/track |
| `click_secondary` | Cancel build / context menu |
