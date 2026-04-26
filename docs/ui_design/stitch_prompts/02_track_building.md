# Stitch Prompt — Screen 2: Track Building Flow

## Context
Paste the master design system prompt first, then paste this.

## Prompt

Design the track-building interaction screen for Rail Empire.

**Canvas:** 1920×1080.

Show an isometric map with Kolkata selected as the start city and Patna as the target city. A preview railway line should connect them.

## Required UI

- Track preview line should be valid in green/indigo, with cost markers along the route.
- **Terrain cost breakdown tooltip near the cursor:**
  - Plains: 8 km × ₹500 = ₹4,000
  - River Bridge: 1 × ₹3,000 = ₹3,000
  - Total: ₹7,000
- **Bottom confirmation panel:**
  - Route: Kolkata → Patna
  - Estimated construction cost: ₹7,000
  - Estimated revenue per coal trip: ₹4,000
  - Break-even: 2 trips
  - Buttons: Confirm Build, Adjust Route, Cancel
- Treasury should update preview: ₹52,400 → ₹45,400.
- Show invalid terrain areas subtly in red/brown.

## Design Goal

The player must understand before clicking whether the track is affordable and profitable. Make the route preview feel like a railway engineer's planning overlay on a map.

## Iteration Prompts (use after first draft)

- "Make it less generic — add subtle railway ledger details, parchment surfaces, brass separators, inked borders, and map-engineering cues. Keep all text highly readable."
- "Make it more Godot-friendly — simplify so it can be implemented in Godot 4 using Control nodes, Panels, StyleBoxFlat, Labels, TextureRects, Buttons, VBox/HBox containers, and simple icons."
- "Improve readability — increase contrast and spacing. Make costs, prices, and action buttons readable at 1920×1080. Avoid tiny labels. Make primary actions visually obvious."
