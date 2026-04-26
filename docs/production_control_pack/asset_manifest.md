# Rail Empire — Asset Manifest

## Phase 1: Colonial Bengal Core

**Version:** 0.1  
**Engine:** Godot 4.2+  
**Target Era:** Colonial (1850s Bengal)  
**Tile Basis:** 64×32 px (2:1 diamond), 2× pixel density for zoom clarity  
**Total Estimated Assets:** 52 images + 2 particle systems

---

## Legend

| Field | Description |
|---|---|
| **Filename** | snake_case, per `art_style_guide.md` §12 |
| **Size (px)** | Canvas size at 1×; 2× exports are double |
| **Pivot** | Normalized anchor point for Godot sprite placement |
| **Density** | 1× = gameplay zoom, 2× = zoom-in / UI crispness |
| **Layer** | Godot scene layer or usage context |
| **Source** | How the asset is produced |
| **Status** | placeholder (now) or final (target) |
| **Import** | Godot Import settings |
| **Effort** | Estimated production hours (art + cleanup + in-game test) |

---

## 1. Terrain

> Rule: Terrain must be readable, not noisy. Rivers must be immediately obvious. Hills must communicate cost.

| # | Filename | Size | Pivot | Density | Layer | Source | Status | Import | Effort |
|---:|---|---:|---|---:|---|---|---|---:|---:|
| 1.1 | `terrain_plains_colonial_01.png` | 64×32 | (0.5, 0.5) | 2× | TerrainLayer | AI-generated | placeholder | Filter: Nearest, Compress: Lossless, Repeat: disabled | 2h |
| 1.2 | `terrain_plains_colonial_02.png` | 64×32 | (0.5, 0.5) | 2× | TerrainLayer | AI-generated | placeholder | Filter: Nearest, Compress: Lossless | 2h |
| 1.3 | `terrain_plains_colonial_03.png` | 64×32 | (0.5, 0.5) | 2× | TerrainLayer | AI-generated | placeholder | Filter: Nearest, Compress: Lossless | 2h |
| 1.4 | `terrain_forest_colonial_01.png` | 64×32 | (0.5, 0.5) | 2× | TerrainLayer | AI-generated | placeholder | Filter: Nearest, Compress: Lossless | 2h |
| 1.5 | `terrain_forest_colonial_02.png` | 64×32 | (0.5, 0.5) | 2× | TerrainLayer | AI-generated | placeholder | Filter: Nearest, Compress: Lossless | 2h |
| 1.6 | `terrain_forest_colonial_03.png` | 64×32 | (0.5, 0.5) | 2× | TerrainLayer | AI-generated | placeholder | Filter: Nearest, Compress: Lossless | 2h |
| 1.7 | `terrain_hill_colonial_01.png` | 64×32 | (0.5, 0.5) | 2× | TerrainLayer | AI-generated | placeholder | Filter: Nearest, Compress: Lossless | 2h |
| 1.8 | `terrain_hill_colonial_02.png` | 64×32 | (0.5, 0.5) | 2× | TerrainLayer | AI-generated | placeholder | Filter: Nearest, Compress: Lossless | 2h |
| 1.9 | `terrain_hill_colonial_03.png` | 64×32 | (0.5, 0.5) | 2× | TerrainLayer | AI-generated | placeholder | Filter: Nearest, Compress: Lossless | 2h |
| 1.10 | `terrain_river_straight_ns_colonial.png` | 64×32 | (0.5, 0.5) | 2× | TerrainLayer | procedural | placeholder | Filter: Nearest, Compress: Lossless | 0.5h |
| 1.11 | `terrain_river_straight_ew_colonial.png` | 64×32 | (0.5, 0.5) | 2× | TerrainLayer | procedural | placeholder | Filter: Nearest, Compress: Lossless | 0.5h |
| 1.12 | `terrain_river_curve_ne_colonial.png` | 64×32 | (0.5, 0.5) | 2× | TerrainLayer | procedural | placeholder | Filter: Nearest, Compress: Lossless | 0.5h |
| 1.13 | `terrain_river_curve_nw_colonial.png` | 64×32 | (0.5, 0.5) | 2× | TerrainLayer | procedural | placeholder | Filter: Nearest, Compress: Lossless | 0.5h |
| 1.14 | `terrain_river_curve_se_colonial.png` | 64×32 | (0.5, 0.5) | 2× | TerrainLayer | procedural | placeholder | Filter: Nearest, Compress: Lossless | 0.5h |
| 1.15 | `terrain_river_curve_sw_colonial.png` | 64×32 | (0.5, 0.5) | 2× | TerrainLayer | procedural | placeholder | Filter: Nearest, Compress: Lossless | 0.5h |
| 1.16 | `terrain_riverbank_transition_n_colonial.png` | 64×32 | (0.5, 0.5) | 2× | TerrainLayer | procedural | placeholder | Filter: Nearest, Compress: Lossless | 0.5h |
| 1.17 | `terrain_riverbank_transition_s_colonial.png` | 64×32 | (0.5, 0.5) | 2× | TerrainLayer | procedural | placeholder | Filter: Nearest, Compress: Lossless | 0.5h |

**Terrain Notes**
- Until the art sprint (Sprint 10), use `TileMapLayer` with `StyleBoxFlat`-derived geometric placeholders: tan diamond for plains, desaturated green diamond for forest, brown shadowed diamond for hills, blue-green translucent diamond for river.
- River tiles are procedural for now: drawn in-engine with `Polygon2D` or `Line2D` so bridge placement is easy to iterate.
- Final river tiles can reuse the same polygon logic baked to PNG.

---

## 2. Track

> Rule: Track is the core interaction object. It must never blend into terrain.

| # | Filename | Size | Pivot | Density | Layer | Source | Status | Import | Effort |
|---:|---|---:|---|---:|---|---|---|---:|---:|
| 2.1 | `track_segment_straight_colonial.png` | 64×8 | (0.5, 0.5) | 2× | TrackLayer | procedural | placeholder | Filter: Nearest, Compress: Lossless | 0.5h |
| 2.2 | `track_segment_diagonal_colonial.png` | 64×8 | (0.5, 0.5) | 2× | TrackLayer | procedural | placeholder | Filter: Nearest, Compress: Lossless | 0.5h |
| 2.3 | `track_preview_valid_colonial.png` | 64×8 | (0.5, 0.5) | 2× | TrackLayer | procedural | placeholder | Filter: Nearest, Compress: Lossless | 0.5h |
| 2.4 | `track_preview_invalid_colonial.png` | 64×8 | (0.5, 0.5) | 2× | TrackLayer | procedural | placeholder | Filter: Nearest, Compress: Lossless | 0.5h |
| 2.5 | `track_bridge_colonial.png` | 64×16 | (0.5, 0.5) | 2× | TrackLayer | AI-generated | placeholder | Filter: Nearest, Compress: Lossless | 3h |
| 2.6 | `track_damaged_overlay_colonial.png` | 64×16 | (0.5, 0.5) | 2× | TrackLayer | procedural | placeholder | Filter: Nearest, Compress: Lossless | 0.5h |
| 2.7 | `track_under_construction_colonial.png` | 64×8 | (0.5, 0.5) | 2× | TrackLayer | procedural | placeholder | Filter: Nearest, Compress: Lossless | 0.5h |

**Track Notes**
- Base track rendering is `Line2D` with a 3px dark iron stroke and 1px warm wood inner stroke. This is procedural and free to iterate.
- Preview valid = bright green `Line2D` with 0.7 alpha dash pattern.
- Preview invalid = red `Line2D` with 0.9 alpha and X marks at collision points.
- Bridge sprite is the first authored track asset because it must read as a distinct structure over water.
- Damaged overlay is a yellow-black striped `Line2D` or cracked sprite modulated with `sin(Time)` pulse.

---

## 3. Station

> Rule: Station markers are gameplay hubs first, architecture second.

| # | Filename | Size | Pivot | Density | Layer | Source | Status | Import | Effort |
|---:|---|---:|---|---:|---|---|---|---:|---:|
| 3.1 | `station_marker_base_colonial.png` | 48×48 | (0.5, 1.0) | 2× | CityMarkers | procedural | placeholder | Filter: Nearest, Compress: Lossless | 0.5h |
| 3.2 | `station_tier_1_colonial.png` | 48×48 | (0.5, 1.0) | 2× | CityMarkers | AI-generated | placeholder | Filter: Nearest, Compress: Lossless | 2h |
| 3.3 | `station_tier_2_colonial.png` | 48×48 | (0.5, 1.0) | 2× | CityMarkers | AI-generated | placeholder | Filter: Nearest, Compress: Lossless | 2h |
| 3.4 | `station_tier_3_colonial.png` | 48×48 | (0.5, 1.0) | 2× | CityMarkers | AI-generated | placeholder | Filter: Nearest, Compress: Lossless | 2h |
| 3.5 | `station_tier_4_colonial.png` | 48×48 | (0.5, 1.0) | 2× | CityMarkers | AI-generated | placeholder | Filter: Nearest, Compress: Lossless | 2h |
| 3.6 | `station_upgrade_warehouse_icon.png` | 16×16 | (0.5, 0.5) | 2× | CityMarkers | procedural | placeholder | Filter: Nearest, Compress: Lossless | 0.25h |
| 3.7 | `station_upgrade_loading_bay_icon.png` | 16×16 | (0.5, 0.5) | 2× | CityMarkers | procedural | placeholder | Filter: Nearest, Compress: Lossless | 0.25h |
| 3.8 | `station_upgrade_maintenance_icon.png` | 16×16 | (0.5, 0.5) | 2× | CityMarkers | procedural | placeholder | Filter: Nearest, Compress: Lossless | 0.25h |

**Station Notes**
- Tier 1–4 bases represent station size / city importance. Tier 1 = frontier town, Tier 4 = Kolkata port metropolis.
- Placeholder: colored diamond (`Polygon2D`) with city label `Label` node beneath.
- Upgrade overlays are small icons drawn in-engine or simple geometric sprites. They appear at the top-right corner of the station base.
- Pivot at bottom center so the sprite sits cleanly on the terrain diamond.

---

## 4. Train

> Rule: Slightly oversized for readability. Smoke puff shows movement. Faction tint stripe, not full redraw per faction.

| # | Filename | Size | Pivot | Density | Layer | Source | Status | Import | Effort |
|---:|---|---:|---|---:|---|---|---|---:|---:|
| 4.1 | `train_freight_colonial_ne.png` | 48×32 | (0.5, 0.5) | 2× | TrainLayer | AI-generated | placeholder | Filter: Nearest, Compress: Lossless | 3h |
| 4.2 | `train_freight_colonial_nw.png` | 48×32 | (0.5, 0.5) | 2× | TrainLayer | AI-generated | placeholder | Filter: Nearest, Compress: Lossless | 3h |
| 4.3 | `train_freight_colonial_se.png` | 48×32 | (0.5, 0.5) | 2× | TrainLayer | AI-generated | placeholder | Filter: Nearest, Compress: Lossless | 3h |
| 4.4 | `train_freight_colonial_sw.png` | 48×32 | (0.5, 0.5) | 2× | TrainLayer | AI-generated | placeholder | Filter: Nearest, Compress: Lossless | 3h |
| 4.5 | `train_mixed_colonial_ne.png` | 48×32 | (0.5, 0.5) | 2× | TrainLayer | AI-generated | placeholder | Filter: Nearest, Compress: Lossless | 3h |
| 4.6 | `train_mixed_colonial_nw.png` | 48×32 | (0.5, 0.5) | 2× | TrainLayer | AI-generated | placeholder | Filter: Nearest, Compress: Lossless | 3h |
| 4.7 | `train_mixed_colonial_se.png` | 48×32 | (0.5, 0.5) | 2× | TrainLayer | AI-generated | placeholder | Filter: Nearest, Compress: Lossless | 3h |
| 4.8 | `train_mixed_colonial_sw.png` | 48×32 | (0.5, 0.5) | 2× | TrainLayer | AI-generated | placeholder | Filter: Nearest, Compress: Lossless | 3h |

**Train Notes**
- Minimum 4 diagonal directions for Phase 1. Full 8-direction set is deferred to Sprint 10 art pass.
- Placeholder: colored rectangle with directional triangle nose and `CPUParticles2D` smoke. Freight = dark brown rectangle, Mixed = brass-colored rectangle.
- AI base sprites must be cleaned for isometric angle, palette-matched to colonial sepia/brass, and tested at 48×32 in-game.
- Use `CanvasItem.modulate` or a shader for faction tint stripes so British rivals can reuse the same sprites with a red/maroon overlay.
- Pivot at center so rotation interpolation looks acceptable even with only 4 directions.

---

## 5. Cargo

> Rule: Strong silhouette, no text inside icon, same angle and lighting, transparent background.

| # | Filename | Size | Pivot | Density | Layer | Source | Status | Import | Effort |
|---:|---|---:|---|---:|---|---|---|---:|---:|
| 5.1 | `cargo_coal_icon.png` | 32×32 | (0.5, 0.5) | 2× | UI / CargoOverlay | AI-generated | placeholder | Filter: Nearest, Compress: Lossless | 1.5h |
| 5.2 | `cargo_textiles_icon.png` | 32×32 | (0.5, 0.5) | 2× | UI / CargoOverlay | AI-generated | placeholder | Filter: Nearest, Compress: Lossless | 1.5h |
| 5.3 | `cargo_grain_icon.png` | 32×32 | (0.5, 0.5) | 2× | UI / CargoOverlay | AI-generated | placeholder | Filter: Nearest, Compress: Lossless | 1.5h |

**Cargo Notes**
- Placeholder: geometric shapes with cargo initial letter (C, T, G) in `Label` overlay, not baked into texture.
- Final icons must read clearly at 32×32 in ledger tables and train inspection cards.
- Keep palette muted: coal = dark grey/black, textiles = warm cream/terracotta, grain = faded ochre/gold.

---

## 6. UI

> Rule: No image-heavy UI before systems are proven. Parchment panels via `StyleBoxFlat` first.

| # | Filename | Size | Pivot | Density | Layer | Source | Status | Import | Effort |
|---:|---|---:|---|---:|---|---|---|---:|---:|
| 6.1 | `ui_icon_money.png` | 24×24 | (0.5, 0.5) | 2× | CanvasLayer / HUD | procedural | placeholder | Filter: Nearest, Compress: Lossless | 0.25h |
| 6.2 | `ui_icon_warning.png` | 24×24 | (0.5, 0.5) | 2× | CanvasLayer / HUD | procedural | placeholder | Filter: Nearest, Compress: Lossless | 0.25h |
| 6.3 | `ui_panel_colonial_parchment.png` | 64×64 | (0.0, 0.0) | 2× | CanvasLayer | procedural | placeholder | Filter: Nearest, Compress: Lossless, Repeat: enabled (9-slice) | 0.5h |
| 6.4 | `ui_button_speed_pause.png` | 32×32 | (0.5, 0.5) | 2× | CanvasLayer / HUD | procedural | placeholder | Filter: Nearest, Compress: Lossless | 0.25h |
| 6.5 | `ui_button_speed_1x.png` | 32×32 | (0.5, 0.5) | 2× | CanvasLayer / HUD | procedural | placeholder | Filter: Nearest, Compress: Lossless | 0.25h |
| 6.6 | `ui_button_speed_2x.png` | 32×32 | (0.5, 0.5) | 2× | CanvasLayer / HUD | procedural | placeholder | Filter: Nearest, Compress: Lossless | 0.25h |
| 6.7 | `ui_button_speed_4x.png` | 32×32 | (0.5, 0.5) | 2× | CanvasLayer / HUD | procedural | placeholder | Filter: Nearest, Compress: Lossless | 0.25h |
| 6.8 | `ui_cursor_build_track.png` | 32×32 | (0.0, 0.0) | 2× | CanvasLayer | procedural | placeholder | Filter: Nearest, Compress: Lossless | 0.25h |
| 6.9 | `ui_cursor_cancel.png` | 32×32 | (0.0, 0.0) | 2× | CanvasLayer | procedural | placeholder | Filter: Nearest, Compress: Lossless | 0.25h |

**UI Notes**
- `ui_panel_colonial_parchment` is a 9-slice texture for `PanelContainer` and `Panel` nodes. Until art sprint, use `StyleBoxFlat` with beige fill (`#e8dcc5`) and dark brown 2px border (`#3e2723`).
- Speed buttons are simple geometric icons: pause = two vertical bars; 1×, 2×, 4× = numeral in a circle.
- Money and warning icons are procedural shapes: money = circle with ₹ glyph overlay (Label), warning = amber triangle.
- All UI textures are 2× so they remain crisp when the window is scaled.

---

## 7. Effects

> Rule: Effects must not obscure route readability. Use native Godot effects before custom sprite sheets.

| # | Filename / System | Size | Pivot | Density | Layer | Source | Status | Import | Effort |
|---:|---|---:|---|---:|---|---|---|---:|---:|
| 7.1 | `particle_smoke_train.tres` | N/A | (0.5, 0.5) | N/A | EffectsLayer | procedural | placeholder | N/A | 0.5h |
| 7.2 | `particle_spark_damaged.tres` | N/A | (0.5, 0.5) | N/A | EffectsLayer | procedural | placeholder | N/A | 0.5h |

**Effects Notes**
- **Train smoke:** `CPUParticles2D` attached to each `TrainEntity`. Settings: emission angle 90° (up), gravity `(0, -20)`, initial velocity `20`, scale `2→6`, color fade from `#5c5c5c` to transparent, lifetime `1.2s`, emission rate `8/sec` while moving.
- **Damaged track sparks:** `CPUParticles2D` on damaged edges. Settings: gravity `(0, 40)`, initial velocity `30`, color `#ffaa00` → transparent, lifetime `0.4s`, emission rate `4/sec` intermittent.
- No texture assets required for Phase 1; both effects are code-driven.
- If CPU particles become a bottleneck at 50 trains, batch into a single `GPUParticles2D` emitter per camera zone (deferred to polish sprint).

---

## 8. City Markers (Final)

| # | Filename | Size | Pivot | Density | Layer | Source | Status | Import | Effort |
|---:|---|---:|---|---:|---|---|---|---:|---:|
| 8.1 | `city_kolkata_marker_colonial.png` | 48×48 | (0.5, 1.0) | 2× | CityMarkers | AI-generated | placeholder | Filter: Nearest, Compress: Lossless | 2.5h |
| 8.2 | `city_dacca_marker_colonial.png` | 48×48 | (0.5, 1.0) | 2× | CityMarkers | AI-generated | placeholder | Filter: Nearest, Compress: Lossless | 2.5h |
| 8.3 | `city_patna_marker_colonial.png` | 48×48 | (0.5, 1.0) | 2× | CityMarkers | AI-generated | placeholder | Filter: Nearest, Compress: Lossless | 2.5h |
| 8.4 | `city_murshidabad_marker_colonial.png` | 48×48 | (0.5, 1.0) | 2× | CityMarkers | AI-generated | placeholder | Filter: Nearest, Compress: Lossless | 2.5h |

**City Marker Notes**
- Placeholder: `Polygon2D` diamond per city role color + `Label` with city name.
- Final markers should suggest role at a glance: Kolkata = dock/warehouse silhouette, Patna = mine headframe, Dacca = mill chimney, Murshidabad = grain store.
- Pivot at bottom center so the marker anchors cleanly to its grid tile.

---

## 9. Summary

| Category | Count | Placeholder | Final | Est. Effort |
|---|---:|---:|---:|---:|
| Terrain | 17 | 17 | 0 | 12.5h |
| Track | 7 | 6 | 0 | 6h |
| Station | 8 | 8 | 0 | 9h |
| Train | 8 | 8 | 0 | 24h |
| Cargo | 3 | 3 | 0 | 4.5h |
| UI | 9 | 9 | 0 | 2.5h |
| Effects | 2 systems | 2 | 0 | 1h |
| City Markers | 4 | 4 | 0 | 10h |
| **Total** | **58** | **57** | **0** | **~69.5h** |

### Production Order (Priority)

1. **Week 1:** Terrain placeholders (procedural), Track procedural rendering, UI StyleBoxFlat, Train rectangles, City diamonds.
2. **Week 2:** Cargo icons (AI + cleanup), Train sprites (AI + cleanup for 4 diagonals).
3. **Week 3:** City markers (AI + cleanup), Bridge sprite, Station tiers.
4. **Week 4:** Integration test, atlas packing, palette consistency pass.

### Atlas Plan (for final assets only)

| Atlas | Contents | Target Size |
|---|---|---|
| `atlas_terrain_colonial.png` | All 17 terrain tiles | 512×256 |
| `atlas_trains_colonial.png` | 8 train directional sprites | 256×128 |
| `atlas_cargo_icons.png` | 3 cargo + 3 upgrade icons | 128×64 |
| `atlas_ui_common.png` | Panel 9-slice + HUD icons + speed buttons | 256×128 |
| `atlas_cities_colonial.png` | 4 city markers + 4 station tiers | 256×128 |

Do not build atlases until assets are gameplay-validated and unlikely to change.
