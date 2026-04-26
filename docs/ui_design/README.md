# UI Design — Rail Empire

This folder contains two parallel tracks for UI development:

## `stitch_prompts/` — AI-Generated Mockups

Use these prompts with **Stitch MCP + Gemini 3.1 Pro** to generate visual mockups.

### How to use

1. Add Stitch MCP to your Kimi CLI config:
```json
{
  "mcpServers": {
    "stitch": {
      "command": "npx",
      "args": ["-y", "stitch-mcp"],
      "env": {
        "STITCH_API_KEY": "your_key",
        "STITCH_MODEL": "gemini-3.1-pro"
      }
    }
  }
}
```

2. Paste prompts in order:
   - `00_master_design_system.md` (first, sets the design system)
   - `01_main_game_hud.md` through `05_contracts_panel.md` (individual screens)

3. Use the iteration prompts at the bottom of each file to refine.

### Screen Priority (MVP Order)

| Order | Screen | Stitch File |
|-------|--------|-------------|
| 1 | Main Game HUD | `01_main_game_hud.md` |
| 2 | Track Building Flow | `02_track_building.md` |
| 3 | City Panel | `03_city_panel.md` |
| 4 | Train Purchase / Route Assignment | `04_train_purchase_route.md` |
| 5 | Contracts Panel | `05_contracts_panel.md` |

**Do not generate later screens (Auction, Rival Overview, Events, Campaign, Settings, Main Menu) until the first 5 are implemented and tested.**

## `godot_specs/` — Implementation References

These documents translate Stitch mockups into actual Godot 4 Control node hierarchies, StyleBoxFlat configs, and layout structures. Use them to implement the UI without waiting for final art.

### Philosophy

- Build UI with Godot native controls first (StyleBoxFlat, not textures)
- Apply era colors via theme constants
- Replace with AI-generated textures later (Sprint 10)
- All panels must work at 1920×1080 and scale down to 1366×768

## Design System Tokens

| Token | Value | Usage |
|-------|-------|-------|
| `--bg-parchment` | `#F5E6C8` | Panel backgrounds |
| `--bg-sepia-dark` | `#3D2B1F` | Dark panels, headers |
| `--ink-primary` | `#1A1A1A` | Primary text |
| `--ink-secondary` | `#5C4A3A` | Secondary text |
| `--accent-brass` | `#B8860B` | Buttons, highlights |
| `--accent-indigo` | `#4B0082` | Valid/positive states |
| `--accent-rust` | `#8B4513` | Invalid/negative states |
| `--border-ink` | `#2F1B14` | Panel borders |
| `--border-brass` | `#D4AF37` | Accent borders |
| `--cargo-coal` | `#2C2C2C` | Coal icon color |
| `--cargo-textiles` | `#4B6F44` | Textiles icon color |
| `--cargo-grain` | `#D4A843` | Grain icon color |

## Font Stack

| Role | Font | Size (1080p) |
|------|------|-------------|
| Logo/Title | Noto Serif | 32–48px |
| Panel Header | Noto Serif | 24px |
| Body | Noto Sans | 16px |
| Data/Tables | Noto Sans Mono | 14px |
| Tooltips | Noto Sans | 14px |
| Buttons | Noto Sans | 16px bold |

Download from Google Fonts. All fonts support Latin and Devanagari scripts.
