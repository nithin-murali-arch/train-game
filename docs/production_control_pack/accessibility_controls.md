# Accessibility and Controls Spec

## Controls

### Default Input Map

| Action | Default Binding | Context |
|--------|----------------|---------|
| Camera Pan Up | W / ↑ | Map navigation |
| Camera Pan Down | S / ↓ | Map navigation |
| Camera Pan Left | A / ← | Map navigation |
| Camera Pan Right | D / → | Map navigation |
| Camera Zoom In | Mouse Wheel Up | Map navigation |
| Camera Zoom Out | Mouse Wheel Down | Map navigation |
| Click Select | Left Mouse | Select city, train, track |
| Click Secondary | Right Mouse | Cancel build, context menu |
| Game Speed Pause | Space | Time control |
| Game Speed 1× | 1 | Time control |
| Game Speed 2× | 2 | Time control |
| Game Speed 4× | 3 | Time control |
| Save Game | Ctrl+S | System |
| Load Game | Ctrl+O | System |
| Build Confirm | Enter | Track placement |
| Build Cancel | Escape / Right Click | Track placement |
| Toggle HUD | Tab | UI |
| Screenshot | F12 | System |

### Remapping
- All actions support remapping via in-game controls menu
- Conflicts detected and prevented
- Reset to defaults button
- Per-profile saves

## Accessibility

### Visual

| Feature | Implementation | Priority |
|---------|---------------|----------|
| UI Scaling | 75%–200% font and panel scale | Must |
| Colorblind-safe ownership colors | Patterns + labels, not just color | Must |
| High-contrast route overlays | Toggle for track visibility | Should |
| Reduced motion | Disable camera shake, particle bursts | Should |
| Screen reader labels | All buttons and panels labeled | Could |

### Colorblind Safety

Ownership colors must be distinguishable by shape/label, not just hue:

| Faction | Primary Color | Pattern | Label |
|---------|--------------|---------|-------|
| Player | Blue | Solid | "Player" |
| British | Red | Striped | "British" |
| French | Green | Dotted | "French" |
| Amdani | Orange | Crosshatched | "Amdani" |

### Cognitive

| Feature | Implementation | Priority |
|---------|---------------|----------|
| Pause anytime | Space bar pauses all simulation | Must |
| Tooltips on everything | Hover delay 0.5s, dismiss on move | Must |
| Clear error messages | "Insufficient funds: need ₹5,000 more" not "Error" | Must |
| Speed controls always visible | Pause/1×/2×/4× pills in HUD | Must |
| Tutorial skippable | Skip button on every tutorial step | Must |
| Tutorial repeatable | Access from help menu | Should |

### Motor

| Feature | Implementation | Priority |
|---------|---------------|----------|
| Keyboard-only basics | Tab navigation, Enter confirm, Escape cancel | Should |
| Click-and-drag track | Alternative: click start, click end | Must |
| Adjustable scroll sensitivity | 0.5×–3× zoom speed | Could |

## Audio

| Feature | Implementation | Priority |
|---------|---------------|----------|
| Master volume | 0–100% slider | Must |
| SFX volume | Separate slider | Must |
| Music volume | Separate slider | Must |
| Mute on focus lost | Optional toggle | Should |

## Save/Accessibility

Accessibility preferences saved per profile:
- UI scale
- Colorblind mode
- Reduced motion
- Control remaps
- Volume levels
