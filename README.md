# Rail Empire

An isometric 2D railway tycoon set in colonial India. Build tracks, buy trains, transport cargo between cities, earn revenue, and expand your rail network. Compete against AI rail barons through logistics, not combat.

**Engine:** Godot 4.6+  
**Platform:** Desktop (Windows, macOS, Linux)  
**License:** Proprietary

---

## Quick Start

### Prerequisites
- [Godot 4.6+](https://godotengine.org/) installed
- Git (optional, for version control)

### Running the Game

```bash
# From the project root
godot --path . --editor

# Or headless (for CI/testing)
godot --path . --headless
```

On macOS with Godot.app:
```bash
/Applications/Godot.app/Contents/MacOS/Godot --path . --editor
```

### Project Structure

```
train-game/
├── project.godot          # Godot project configuration
├── assets/                # Art, audio, fonts, effects
│   ├── tiles/             # Terrain tilesets
│   ├── trains/            # Train sprites
│   ├── stations/          # Station building sprites
│   ├── ui/                # UI textures and themes
│   ├── effects/           # Particles, shaders
│   └── fonts/             # Typography
├── data/                  # Game data (Resource files)
│   ├── eras/              # Era definitions
│   ├── factions/          # Faction definitions
│   ├── regions/           # Region maps
│   ├── cities/            # City economies
│   ├── cargo/             # Cargo types
│   ├── trains/            # Train type stats
│   ├── events/            # Event definitions
│   ├── contracts/         # Contract templates
│   └── technologies/      # Auction technology data
├── src/                   # Source code
│   ├── autoload/          # Singletons (GameState, EventBus, EconomyManager)
│   ├── world/             # Map, TileMap, Camera, Region loading
│   ├── tracks/            # TrackGraph, placement, rendering, ownership
│   ├── trains/            # Train entities, movement, cargo, pathfinding
│   ├── economy/           # City economy, pricing, transactions, contracts
│   ├── events/            # Event system, warnings, effects
│   ├── ai/                # AI rival controllers
│   ├── ui/                # HUD, panels, menus, tooltips
│   └── resources/         # Custom Resource class definitions
├── scenes/                # Godot scene files
│   ├── main.tscn          # Entry point
│   ├── world.tscn         # Game world
│   ├── ui/                # UI scenes
│   └── game/              # Gameplay scenes
└── docs/                  # Design documentation
    ├── design.md          # Implementation GDD
    ├── design_bible.md    # Creative vision and tone
    ├── art_style_guide.md # Visual direction
    └── rail_empire_execution_pack.md  # PRDs and sprint plans
```

---

## Development Strategy

**Depth-first, one layer per sprint.**

| Sprint | Phase | Focus |
|--------|-------|-------|
| 00 | Setup | Repo, conventions, backlog |
| 01 | Route Toy | Track + train + profit |
| 02 | Colonial Core | Real tycoon loop |
| 03 | Economic Depth | Supply/demand, contracts |
| 04 | First Rival | British AI competition |
| 05 | Network Control | Ownership, tolls, junctions |
| 06 | Events | Monsoon, strikes, booms |
| 07 | Campaign | Bengal Railway Charter |
| 08 | Factions | 3 playable factions |
| 09 | WW1 | Era transition |
| 10 | Modes + Polish | Scenario, Campaign, Sandbox |

**Hard rule:** Do not add a new era, region, faction, or mode unless the current sprint explicitly requires it.

---

## Coding Conventions

See [CONVENTIONS.md](./CONVENTIONS.md) for naming, signals, scene structure, and GDScript style rules.

---

## Current Sprint

See [BACKLOG.md](./BACKLOG.md) for active sprint tasks and acceptance criteria.

---

## Design Documentation

- [design.md](docs/design.md) — Systems, data models, balance numbers, UI flows
- [design_bible.md](docs/design_bible.md) — Creative pillars, tone, scope boundaries
- [art_style_guide.md](docs/art_style_guide.md) — Visual style, placeholders, AI asset pipeline
- [rail_empire_execution_pack.md](docs/rail_empire_execution_pack.md) — PRDs, epics, stories

---

## Manual Testing

Each sprint ends with manual test steps. See sprint reports in the backlog for current test procedures.

### Quick Smoke Test
1. Launch game → main scene loads without errors
2. Pan camera with WASD → camera moves
3. Zoom with scroll → zoom works
4. Build track between two cities → track appears, cost deducted
5. Buy train → train appears, cost deducted
6. Assign route → train moves
7. Train delivers cargo → treasury increases
8. Save game → JSON file created
9. Load game → state restored

---

## Known Issues

See [BACKLOG.md](./BACKLOG.md) "Known Issues" section.

---

## Roadmap

1. **MVP (Phase 1–2):** Colonial Bengal with player-only economy
2. **Competitive (Phase 3–5):** AI rivals, track ownership, events
3. **Campaign (Phase 6–7):** Full Colonial arc, faction variety
4. **Era Expansion (Phase 8–9):** WW1 transition, game modes
5. **Polish (Phase 10):** Art, audio, accessibility, export builds
