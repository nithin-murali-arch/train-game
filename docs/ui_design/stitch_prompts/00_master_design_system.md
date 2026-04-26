# Stitch Master Prompt — Rail Empire Design System

Paste this first into Stitch as the project/design direction.

## Project

Design a desktop game UI for **"Rail Empire"**, an isometric 2D railway tycoon set in Colonial Bengal.

The UI should feel like a colonial-era railway ledger mixed with a strategic map interface. It must be readable, not overly decorative. The tone is premium strategy game, not mobile casual.

## Visual Direction

- **Era:** Colonial Bengal, 1850s–1910s.
- **Palette:** warm sepia, parchment beige, muted indigo, dark ink, brass/gold highlights, rail steel grey, muted forest green.
- **Avoid:** neon, cyberpunk, fantasy, modern SaaS styling, or cartoon UI.
- **UI chrome:** ledger paper, stamped documents, railway tickets, brass labels, thin ink borders.
- **Typography feel:** readable serif headings, clean sans body text. Do not overuse ornamental fonts.
- **Layout:** desktop-first 16:9, optimized for 1920×1080.
- **Game camera:** isometric railway map occupies most of the screen.
- **Panels should be collapsible** and information-dense but not cluttered.
- **Important actions must be obvious:** Build Track, Buy Train, Assign Route, Accept Contract, Save.

## Game Context

Rail Empire is a depth-first train economy simulator. The player builds tracks, buys trains, transports cargo, earns money, expands the network, and later competes with rival railway companies. The first build is Colonial Bengal only, focused on Kolkata, Dacca, Patna, and Murshidabad. Cargo types are Coal, Textiles, and Grain. Train types are Freight Engine and Mixed Engine.

## Core UX Principles

1. The player must always understand treasury, date, active route, city prices, and route profitability.
2. Track building must show cost before confirmation.
3. Economy information must be clear: supply, demand, price, trend, and stockpile.
4. Alerts should feel like newspaper/telegraph notices.
5. Do not design for touchscreen first. This is a mouse/keyboard PC strategy game.

## Required Design System Components

Create a cohesive design system with:
- HUD components
- Side panels
- Tooltips
- Buttons
- Modal dialogs
- Notification cards
- Tables
- Graph widgets
- Map overlays
- Icon style
- Empty states
- Error states

## Technical Constraint

This aligns with the product direction: desktop Godot 4, isometric 2D, Colonial Bengal first, core loop around tracks, trains, cargo, money, and expansion.
