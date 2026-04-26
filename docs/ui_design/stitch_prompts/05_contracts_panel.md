# Stitch Prompt — Screen 5: Contracts Panel

## Context
Paste the master design system prompt first, then paste this.

## Prompt

Design the Contracts Panel for Rail Empire.

**Canvas:** 1920×1080.

**UI style:** colonial government contract ledger with stamped papers.

## Required Sections

**Top:**
- Title: Contracts
- Filters: Available, Active, Completed, Failed

**Available contracts list:**

1. **Coal for the Port**
   - Deliver 200 tons of Coal to Kolkata
   - Deadline: 60 days
   - Reward: ₹5,000
   - Reputation: +10
   - Penalty: ₹1,000 and -15 reputation
   - Button: Accept

2. **Grain Relief**
   - Deliver 150 tons of Grain to Murshidabad
   - Deadline: 45 days
   - Reward: ₹3,500
   - Reputation: +15
   - Button: Accept

3. **Textile Export Order**
   - Deliver 100 tons of Textiles to Kolkata
   - Deadline: 30 days
   - Reward: ₹4,000
   - Reputation: +8
   - Button: Accept

**Right-side detail panel:**
Show selected contract with destination city map marker, cargo icon, deadline countdown, expected difficulty, and suggested route.

## Design Goal

Contracts should feel like strategic objectives, not quests from an RPG.

## Iteration Prompts (use after first draft)

- "Make it less generic — add subtle railway ledger details, parchment surfaces, brass separators, inked borders, stamped documents."
- "Make it more Godot-friendly — simplify so it can be implemented in Godot 4 using Control nodes, Panels, StyleBoxFlat, Labels, TextureRects, Buttons, VBox/HBox containers, and simple icons."
- "Improve readability — increase contrast and spacing. Make deadlines, rewards, and penalties readable."
