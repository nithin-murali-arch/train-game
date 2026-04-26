# Rail Empire — Art Style Guide and Asset Pipeline

Version: 0.2  
Companion files: `design.md`, `design_bible.md`, `rail_empire_execution_pack.md`

---

## 1. Purpose

This document defines the visual style, production rules, placeholder strategy, AI-assisted asset workflow, procedural asset policy, and Godot implementation guidance for Rail Empire.

The goal is to make the game coherent without letting art production block gameplay development.

---

## 2. Visual thesis

Rail Empire should look like a readable isometric strategy map brought to life with miniature trains, ledger-like UI, and era-specific mood.

The art should support economic decision-making first. Beauty is secondary to clarity.

---

## 3. Visual pillars

## 3.1 Readability over realism

At gameplay zoom, players must immediately identify:

- Cities
- Track ownership
- Terrain cost
- Train direction
- Cargo/event warnings
- Damaged track
- Active routes
- Rival territory

## 3.2 Board-game isometric, not simulation photorealism

The world should feel like a hand-crafted strategic map. Avoid photorealistic assets that clash with stylized UI.

## 3.3 Era mood through palette and UI, not full redraws

The same terrain and track base can be reused across eras. Era identity comes from:

- Color grading
- UI chrome
- Event cards
- Train variants
- Cargo icons
- Music and sound
- Overlays

## 3.4 AI assists, humans curate

AI-generated assets may be used for concepting and base sprites, but final game assets must be cleaned, scaled, color-matched, and tested in-game.

## 3.5 Procedural where rules matter

Use procedural/in-engine visuals for systems that change often:

- Track previews
- Ownership overlays
- Profit heatmaps
- Route lines
- Event zones
- Debug displays
- Particles

---

## 4. Projection and scale

## 4.1 Projection

Use 2D isometric presentation.

Recommended tile basis:

- Tile ratio: 2:1 diamond
- MVP tile size: 64×32 px
- High-res option: 128×64 px
- Logical grid stored separately from world position

## 4.2 Camera

Camera should support:

- Pan
- Zoom
- Bounds clamp
- Click selection
- Build preview readability at multiple zoom levels

## 4.3 Scale hierarchy

| Element | Relative Scale Rule |
|---|---|
| Terrain tile | Base unit |
| Track | Clearly visible but thinner than roads/city markers |
| Train | Slightly oversized for readability |
| City marker | Larger than literal scale; gameplay icon first |
| Station | Readable hub marker, not realistic full building scale |
| UI icons | Simple silhouettes, no fine detail |

---

## 5. Initial art direction: Colonial Bengal

## 5.1 Mood words

- Sepia
- Humid
- Ledger-like
- Riverine
- Early industrial
- Parchment map
- Brass and coal smoke
- Muted vegetation

## 5.2 Palette intent

Colonial should feel warm, aged, and legible.

Suggested palette roles:

| Use | Color Direction |
|---|---|
| Plains | Muted tan/ochre |
| Forest | Desaturated green |
| River | Faded blue-green |
| Hills | Brown/olive shadows |
| Track | Dark iron + warm wood |
| Player | Clear strong accent color |
| British rival | Red/maroon accent |
| Warning | Amber/red stamp color |
| UI panels | Parchment beige, dark ink text |

Do not over-sepia the map so much that terrain and ownership become hard to distinguish.

---

## 6. Era palette roadmap

| Era | Visual Palette | UI Chrome | Mood |
|---|---|---|---|
| Colonial | Sepia, faded greens, parchment, brass | Victorian ledger, stamped labels | Ambitious, extractive, early industrial |
| WW1 | Desaturated mud, khaki, steel grey | Military maps, telegraph slips | Tense, urgent, rationed |
| WW2 | High contrast, smoke, propaganda tones | Newsreel and poster framing | Dramatic, dangerous |
| Cold War | Concrete grey, muted green, industrial blue | Planning board, blocky modernist UI | Bureaucratic, industrial |
| Modern | Saturated, clean, glassy | Corporate flat UI | Fast, competitive |
| WW3/Current | Harsh neon, emergency red, dark overlays | Holographic warnings | Fragile, crisis-driven |

Only Colonial and WW1 should receive production treatment before the core game is proven.

---

## 7. Asset categories

## 7.1 Terrain

### MVP approach

Use in-engine geometric tiles or simple TileMap colors.

Terrain must clearly show:

- Plains
- Forest
- Hills
- River

### Final approach

Use modular isometric tiles with simple texture variation.

Required terrain assets for Colonial MVP:

| Asset | Count |
|---|---:|
| Plains tile variants | 3 |
| Forest tile variants | 3 |
| Hill tile variants | 3 |
| River straight/curve variants | 6–8 |
| Riverbank transitions | Optional initially |
| City ground markers | 4 |

Terrain rules:

- Do not make terrain noisy.
- Avoid photorealistic textures.
- Rivers must be highly readable because monsoon and bridge decisions depend on them.
- Hills should communicate cost, not decorative clutter.

---

## 7.2 Track

### MVP approach

Use `Line2D` or custom drawing.

Track states must be readable:

- Preview
- Confirmed
- Selected
- Owned by player
- Owned by rival
- Damaged
- Private/restricted
- Toll route

### Final approach

Use modular overlay sprites or textured Line2D.

Required track visuals:

| Visual | Purpose |
|---|---|
| Straight rail line | Base segment |
| Curved rail line | Later polish |
| Bridge rail | River crossing |
| Junction node | Strategic bottleneck |
| Damaged track overlay | Event/maintenance feedback |
| Under construction preview | Track placement clarity |
| Ownership tint overlay | Faction control |

Track design rule: never let track blend into terrain. Track is the core interaction object.

---

## 7.3 Trains

### MVP approach

Use simple colored rectangles/icons or basic generated sprites.

### Final approach

Use isometric miniature train sprites with faction tinting.

Required Colonial train assets:

| Train | Directional Requirement | Notes |
|---|---|---|
| Freight Engine | At least 4 diagonal directions | Bulk cargo, slow silhouette |
| Mixed Engine | At least 4 diagonal directions | Faster/lighter silhouette |
| Express/Passenger | Later | More polished, narrow profile |

Direction policy:

Minimum acceptable:

- NE
- NW
- SE
- SW

Better later:

- 8 directions or rendered rotation variants

Train readability rules:

- Slightly exaggerate locomotive silhouette.
- Use smoke puff to show movement.
- Use faction accent stripe/tint rather than completely different art per faction.
- Do not rely on tiny labels above trains as the only identifier.

---

## 7.4 Cities and stations

### MVP approach

Use labeled city markers with simple icons.

### Final approach

Use stylized isometric city/station icons.

Required city visuals:

| City Type | Visual Language |
|---|---|
| Port metropolis | Dock/warehouse/flag/large station |
| Mining center | Coal pile, mine headframe, dark accents |
| Industrial city | Mill/warehouse/chimney |
| Agricultural town | Grain store, fields, small station |
| Frontier town | Tea estate/hills later |

Station upgrade overlays:

| Upgrade | Overlay |
|---|---|
| Warehouse | Crates/storage shed |
| Loading Bay | Platform/crane |
| Maintenance Shed | Small depot/wrench icon |

---

## 7.5 Cargo icons

Cargo icons must be simple and readable in UI tables.

Required MVP icons:

| Cargo | Icon Direction |
|---|---|
| Coal | Coal pile or black lump in cart |
| Textiles | Folded cloth bolt |
| Grain | Grain sack or wheat sheaf |
| Tea | Tea crate/leaf later |
| Troops | Helmet/personnel symbol for WW1 |
| Munitions | Crate with warning mark for WW1 |
| Medical Supplies | Medical crate for WW1 |

Icon rules:

- No tiny text inside icons.
- Strong silhouette.
- Same angle and lighting.
- Transparent background.
- Match UI palette.

---

## 7.6 UI

### MVP approach

Use Godot `Control` nodes and `StyleBoxFlat`.

No image-heavy UI before the systems are proven.

### Colonial UI style

- Parchment panel background
- Dark brown/ink text
- Thin border lines
- Ledger tables
- Stamp-style warning labels
- Newspaper card for campaign briefs

### WW1 UI style

- Khaki/grey panels
- Telegraph notice cards
- Map grid overlays
- Urgent red/amber military tags

### UI readability rules

- Text contrast must be readable at 100% zoom.
- Numbers align in columns.
- Profit numbers and warnings must be obvious.
- Decorative fonts are allowed only for headings, never dense data.

### Font policy

Use broadly available readable fonts. Do not depend on proprietary fonts. Avoid shipping font files that are not licensed.

---

## 7.7 Effects

Use native Godot effects before custom sprite sheets.

Initial effects:

- Train smoke: `CPUParticles2D`
- Selection pulse: simple modulate/scale animation
- Track build confirmation: short line glow
- Damaged track: smoke/sparks or crack overlay
- Event zone: translucent map overlay

Effects must not obscure route readability.

---

## 7.8 Audio

Audio comes after core loop validation.

### Colonial audio mood

- Soft rail clacks
- Steam whistle
- Low station ambience
- Subtle orchestral/period-inspired ambience
- Ledger stamp/cash register UI ticks

### WW1 audio mood

- Tense drum/telegraph ticks
- Distant rail yard ambience
- Urgent notification sounds

Audio rules:

- UI sounds must be short and not annoying.
- Train sounds should be tied to camera distance if possible.
- Event alerts should be distinct but not alarm spam.

---

# 8. Placeholder strategy

## 8.1 Rule

Use placeholders aggressively until the loop is fun.

A placeholder is acceptable if it is:

- Clear
- Labeled
- Consistent
- Fast to modify
- Good enough for testing decisions

## 8.2 Placeholder visual system

| Gameplay Object | Placeholder |
|---|---|
| City | Diamond marker + label |
| Track | Line2D with owner color |
| Train | Small rectangle/triangle with smoke particle |
| Terrain | Flat colored isometric tiles |
| Cargo | Letter icon or simple vector symbol |
| Event | Panel notification + map tint |
| Station upgrade | Small icon overlay |

## 8.3 When to replace placeholder art

Replace only when:

- The mechanic is validated.
- The asset will be reused widely.
- The placeholder harms readability or player feedback.
- The sprint is explicitly about art/polish.

---

# 9. AI-assisted asset pipeline

## 9.1 Correct use of AI

Use AI for:

- Moodboards
- Concept exploration
- Sprite base candidates
- Cargo icon variants
- Station/building variations
- Event card illustrations
- Marketing/key art later

Do not use raw AI output blindly as final game art.

## 9.2 Common AI asset problems

Expect to fix:

- Wrong isometric angle
- Inconsistent lighting
- Blurry edges
- Bad transparency
- Wrong scale
- Fine details unreadable at game size
- Historical inaccuracies
- Inconsistent palette
- Weird text artifacts

## 9.3 Cleanup pass checklist

Every AI-derived asset must pass:

- Transparent background cleaned
- No fake text or artifacts
- Scale matches asset category
- Lighting matches guide
- Palette adjusted
- Readable at actual in-game size
- Exported to correct folder
- Tested inside Godot scene

## 9.4 Recommended AI workflow

1. Define asset need.
2. Generate 8–20 candidates.
3. Pick best 1–3.
4. Clean in image editor.
5. Resize to target resolution.
6. Apply palette/tint correction.
7. Import into Godot.
8. Test against terrain and UI.
9. Keep source prompt and source image in `/assets/source/`.
10. Put final game-ready asset in `/assets/final/`.

---

# 10. Procedural and in-engine asset pipeline

## 10.1 Use procedural/in-engine for

- Terrain placeholders
- Track lines
- Track previews
- Profit heatmaps
- Ownership overlays
- Market share overlays
- Event zones
- Smoke particles
- Selection outlines
- Debug graphs

## 10.2 Use authored art for

- Final train sprites
- Final stations
- Final cargo icons
- City landmarks
- Event cards
- Main menu/key art
- UI decorative frames after polish

## 10.3 Hybrid approach

Best production path:

> Placeholder geometry → procedural overlays → AI-assisted concepts → hand cleanup → final atlas.

---

# 11. Asset folder structure

Use this structure:

```text
assets/
├── source/
│   ├── ai_generations/
│   ├── prompts/
│   ├── references/
│   ├── blender/
│   └── aseprite_or_pixel_editor/
├── placeholders/
│   ├── terrain/
│   ├── trains/
│   ├── ui/
│   └── icons/
├── final/
│   ├── atlases/
│   ├── terrain/
│   ├── tracks/
│   ├── trains/
│   ├── cities/
│   ├── cargo_icons/
│   ├── ui/
│   ├── effects/
│   └── event_cards/
└── import_presets/
```

Never dump AI generations directly into `assets/final/`.

---

# 12. Naming conventions

Use lowercase snake case.

Examples:

```text
terrain_plains_colonial_01.png
track_bridge_colonial_damaged.png
train_freight_colonial_ne.png
train_mixed_colonial_sw.png
city_kolkata_marker_colonial.png
cargo_coal_icon.png
ui_panel_colonial_parchment.png
event_card_monsoon_colonial.png
```

Godot resource examples:

```text
coal.tres
kolkata.tres
freight_engine_colonial.tres
british_east_india.tres
monsoon_flood.tres
```

---

# 13. Godot import rules

## 13.1 Pixel/painted style

If using crisp pixel-like sprites:

- Disable filtering.
- Use nearest-neighbor scaling.
- Keep pixel grid consistent.

If using painterly sprites:

- Filtering may be acceptable.
- Test at gameplay zoom.
- Avoid blurry UI icons.

## 13.2 Atlases

Use atlases for:

- Terrain tiles
- Track sprites
- Train directional sprites
- Cargo icons

Do not over-optimize atlases before art is stable.

## 13.3 Transparent assets

All object sprites should use transparent PNG unless a shader/material requires otherwise.

---

# 14. Prompt templates

## 14.1 Terrain tile prompt

```text
Isometric 2D hand-painted terrain tile for a railway tycoon game set in 1850s Bengal, India. Muted warm colonial-era palette, readable game asset, 2:1 isometric diamond tile, soft shadows, no buildings, no text, no characters, seamless edges, transparent background if possible.
```

## 14.2 Steam locomotive prompt

```text
Early steam locomotive for an isometric 2D railway tycoon game, 1850s colonial India setting, compact readable silhouette, hand-painted game sprite style, muted sepia and brass palette, side-isometric view, transparent background, no text, no people, clean edges.
```

## 14.3 Station prompt

```text
Small 1850s Bengal railway station, isometric 2D game asset, hand-painted style, red brick and lime plaster, tiled roof, small platform, colonial Indian railway architecture influence, warm muted colors, transparent background, no text, no people, readable at small size.
```

## 14.4 Cargo icon prompt

```text
Small readable UI icon of [CARGO] for a railway tycoon economy game, simple silhouette, hand-painted 2D style, muted colonial palette, transparent background, no text, clean edges, readable at 32x32 pixels.
```

## 14.5 Newspaper event card prompt

```text
Vintage newspaper-style illustration for a railway tycoon event card, 1850s Bengal, theme: [EVENT], sepia ink illustration, simple composition, no readable text, no gore, no caricature, suitable for strategy game UI.
```

---

# 15. First playable art bible

## 15.1 Required placeholder assets

Kimi can generate these in-engine without external art:

- Colored isometric terrain shapes
- City diamonds with labels
- Track Line2D segments
- Train placeholder rectangles/triangles
- Smoke particles
- Parchment-like UI panels using StyleBoxFlat
- Cargo labels/icons as text or simple vector shapes

## 15.2 Required final-ish MVP assets

Only after the core loop works:

| Asset | Priority |
|---|---|
| Coal icon | High |
| Textiles icon | High |
| Grain icon | High |
| Freight engine sprite | High |
| Mixed engine sprite | High |
| Kolkata city marker | Medium |
| Patna city marker | Medium |
| Dacca city marker | Medium |
| Murshidabad city marker | Medium |
| Basic station | Medium |
| Terrain tile set | Medium |
| Track texture | Medium |

Total: around 15–25 image assets for the first visually coherent build.

---

# 16. UI screen style guide

## 16.1 HUD

- Compact top bar.
- Treasury always visible.
- Date always visible.
- Speed buttons grouped.
- Active objective shown clearly.
- Event ticker should not block map.

## 16.2 City panel

Style: ledger table.

Must display:

- City name
- Role
- Produced goods
- Demanded goods
- Stock
- Price
- Saturation status
- Market share later

## 16.3 Train panel

Style: inspection card.

Must display:

- Train type/name
- Route
- Cargo
- Capacity
- Condition
- Last trip profit

## 16.4 Event panel

Style: newspaper/telegram.

Must display:

- Event title
- Duration or deadline
- Affected location
- Effect
- Counterplay options

---

# 17. Map readability overlays

Overlays are essential and should be built early.

Required overlays:

| Overlay | Purpose |
|---|---|
| Build preview | Shows intended track and cost |
| Ownership | Shows faction control by color |
| Profit estimate | Shows route opportunity |
| Event risk | Shows monsoon/flood/strike affected area |
| Track condition | Shows damaged/poor segments |
| Market share | Shows city control later |

Overlay rule: only one major strategic overlay should be active at a time unless debug mode is on.

---

# 18. Do and don't list

## Do

- Use clear silhouettes.
- Test every asset at gameplay zoom.
- Use faction tinting to reduce asset count.
- Keep terrain quiet and track readable.
- Use UI tables for economic information.
- Store prompts and source images.
- Keep final assets curated.

## Don't

- Make the map visually noisy.
- Use raw AI images without cleanup.
- Add text inside generated images.
- Hide important numbers behind decorative UI.
- Create full art sets for eras not yet implemented.
- Build huge sprite libraries before validating gameplay.
- Use photorealistic art mixed with flat UI.

---

# 19. Art sprint acceptance criteria

An art sprint is successful if:

- The game is more readable than before.
- Assets match scale, angle, lighting, and palette.
- UI data remains easy to read.
- The art does not break gameplay scenes.
- Placeholder replacements are committed in an organized folder structure.
- Asset prompts/sources are saved.
- The sprint does not add unrelated gameplay scope.

---

# 20. Kimi art implementation instructions

When Kimi is asked to implement art/style tasks:

1. Use this guide as the visual source of truth.
2. Prefer Godot-native placeholder visuals unless external assets already exist.
3. Do not generate or require external images unless the sprint explicitly asks.
4. Use `StyleBoxFlat`, `Label`, `PanelContainer`, `Line2D`, `Polygon2D`, and particles for early presentation.
5. Keep all asset paths stable and named in snake case.
6. Do not create final art for unimplemented eras.
7. End with screenshots or manual visual test steps if possible.

---

## 21. Final style summary

Rail Empire should look like a clean isometric railway board game layered with period railway ledgers, clear economic tables, and miniature moving trains. The map should be pleasant but not noisy. The UI should feel historical but read like a modern strategy game. AI art is welcome as a production accelerator, but gameplay clarity and consistency decide what ships.
