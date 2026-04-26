# Stitch Prompt — Screen 1: Main Game HUD

## Context
Paste the master design system prompt first, then paste this.

## Prompt

Create the main in-game HUD screen for Rail Empire.

**Canvas:** 1920×1080 desktop game UI.

The center and background should be an isometric map of Colonial Bengal with visible terrain, rivers, city markers, and railway track segments. The UI should overlay the map without hiding too much of it.

## Required UI Elements

- **Top-left:** company name "Bengal Railway Company", treasury ₹52,400, reputation 12, market share 0%.
- **Top-center:** date "March 1857", game speed controls: pause, 1x, 2x, 4x.
- **Top-right:** active alerts area with one telegraph-style notification.
- **Left vertical toolbar:** Build Track, Buy Train, Routes, Contracts, Reports.
- **Bottom-left mini ledger panel** showing selected tool and shortcut hints.
- **Bottom-center contextual action bar** with "Confirm Build", "Cancel", and estimated cost.
- **Bottom-right compact route profitability widget** showing estimated revenue, operating cost, and break-even trips.
- **Right side collapsible event log tab.**

## Visual Style

Colonial railway ledger, parchment panels, dark ink text, brass accents, muted colors, thin ornamental borders. Keep it readable and strategic. No fantasy, no sci-fi, no mobile card-game look.

## Iteration Prompts (use after first draft)

- "Make it less generic — add subtle railway ledger details, parchment surfaces, brass separators, inked borders, and map-engineering cues. Keep all text highly readable."
- "Make it more Godot-friendly — simplify so it can be implemented in Godot 4 using Control nodes, Panels, StyleBoxFlat, Labels, TextureRects, Buttons, VBox/HBox containers, and simple icons. Avoid complex glassmorphism, heavy blur, tiny decorative flourishes."
- "Make it more game-like — prioritize treasury, date, selected tool, selected city/train, active objective, and next best action. Reduce decorative elements that do not support gameplay decisions."
- "Improve readability — increase contrast and spacing. Make table values, prices, cargo names, and action buttons readable at 1920×1080 during active gameplay. Avoid tiny labels. Make primary actions visually obvious."
- "Reduce mobile feel — convert from mobile/card UI into desktop PC strategy game interface. Use wider panels, denser but readable tables, keyboard shortcut hints, hover tooltips, compact buttons, and map-focused composition."
