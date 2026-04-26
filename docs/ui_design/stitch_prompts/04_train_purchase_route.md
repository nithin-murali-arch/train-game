# Stitch Prompt — Screen 4: Train Purchase & Route Assignment

## Context
Paste the master design system prompt first, then paste this.

## Prompt

Design the Train Purchase panel and Route Assignment panel for Rail Empire.

**Canvas:** 1920×1080. The left side shows the isometric map blurred/dimmed slightly. The panel is centered or right-aligned as a large purchase ledger.

## Part A: Train Purchase

**Title:** Purchase Train

**Required train cards:**

1. **Freight Engine**
   - Cost: ₹5,000
   - Capacity: 200 tons
   - Speed: 2 km/tick
   - Maintenance: ₹50/day
   - Best for: Coal, Grain
   - Button: Buy Freight Engine

2. **Mixed Engine**
   - Cost: ₹10,000
   - Capacity: 100 tons
   - Speed: 4 km/tick
   - Maintenance: ₹80/day
   - Best for: Textiles, fast routes
   - Button: Buy Mixed Engine

Each card should show a small isometric steam locomotive sprite placeholder, stats, and a short recommendation.

**Include:**
- Treasury: ₹52,400
- Selected home station dropdown: Kolkata, Patna, Dacca, Murshidabad
- Comparison tooltip: Freight has better profit for bulk cargo, Mixed has faster turnaround.

## Part B: Route Assignment

**Title:** Assign Route — Freight Engine 01

Show the map in the background with railway tracks between Kolkata and Patna.

**Sections:**
- Current Location: Kolkata
- Cargo: Empty
- Capacity: 200 tons
- Maintenance: ₹50/day

**Route Builder:**
- Step 1: Origin dropdown — Patna
- Step 2: Cargo dropdown — Coal
- Step 3: Destination dropdown — Kolkata
- Step 4: Loop route toggle — On

**Profit Estimate:**
- Buy/load price at Patna: ₹8/ton
- Sell price at Kolkata: ₹27/ton
- Revenue per trip: ₹5,400
- Maintenance per round trip: ₹300
- Net estimate: ₹5,100
- Risk: Kolkata may become oversupplied

**Buttons:** Start Route, Save Schedule, Cancel

**Map overlay:** Highlight Patna → Kolkata path in player color. Show train icon at Kolkata.

## Visual Style

Colonial rail catalog, brass labels, technical blueprint accents, premium strategy UI.

## Iteration Prompts (use after first draft)

- "Make it less generic — add subtle railway ledger details, parchment surfaces, brass separators, inked borders."
- "Make it more Godot-friendly — simplify so it can be implemented in Godot 4 using Control nodes, Panels, StyleBoxFlat, Labels, TextureRects, Buttons, VBox/HBox containers, and simple icons."
- "Improve readability — increase contrast and spacing. Make stats, prices, and action buttons readable."
