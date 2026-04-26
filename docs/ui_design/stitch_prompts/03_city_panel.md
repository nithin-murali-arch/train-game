# Stitch Prompt — Screen 3: City Panel

## Context
Paste the master design system prompt first, then paste this.

## Prompt

Design the City Panel for Rail Empire.

**Canvas:** 1920×1080 with isometric map in background. A right-side panel is open for the selected city: Kolkata.

## Panel Title

**Kolkata**  
Role: Port Metropolis

## Required Sections

### 1. City Summary
- Population: Large
- Connected Tracks: 2
- Station Level: Basic
- Owner Influence: Player 100%

### 2. Supply and Demand Table

Columns: Cargo | Stock | Daily Change | Demand | Current Price | Trend

Rows:
- Coal | 40 tons | -80/day | High | ₹27/ton | rising
- Textiles | 620 tons | +50/day | Medium | ₹18/ton | stable
- Grain | 90 tons | -35/day | Medium | ₹12/ton | rising

### 3. Special City Effects
- Port export bonus: +20% on Textiles during Port Boom
- High passenger demand: locked for later

### 4. Available Actions
- Build Station Upgrade
- Assign Train Route
- View Contracts
- Center Camera

### 5. Warning Chip
"Coal shortage: high-profit delivery opportunity"

## Visual Style

Ledger table on parchment, clear readable data, small cargo icons, price trend arrows. This must feel like a strategy game panel, not a business dashboard.

## Iteration Prompts (use after first draft)

- "Make it less generic — add subtle railway ledger details, parchment surfaces, brass separators, inked borders. Keep all text highly readable."
- "Make it more Godot-friendly — simplify so it can be implemented in Godot 4 using Control nodes, Panels, StyleBoxFlat, Labels, TextureRects, Buttons, VBox/HBox containers, and simple icons."
- "Improve readability — increase contrast and spacing. Make table values, prices, cargo names readable at 1920×1080."
