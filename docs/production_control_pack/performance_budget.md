# Rail Empire — Performance Budget

**Version:** 0.1  
**Engine:** Godot 4.2+  
**Target Platform:** Desktop (Windows, macOS, Linux)  
**MVP Phase:** Colonial Bengal Core (Phase 1)

---

## 1. Frame Rate Target

| Scenario | Target | Minimum Acceptable |
|---|---|---|
| Normal gameplay (1× speed, 6 cities, 10 trains) | **60 FPS** | 60 FPS |
| Stressed gameplay (4× speed, 6 cities, 50 trains) | **60 FPS** | 45 FPS |
| Fast simulation (16× speed, debug only) | 30 FPS | 20 FPS |
| Menu / Pause | 60 FPS | 60 FPS |

**Display:** V-Sync enabled by default. Frame cap at 60 FPS to conserve laptop battery. Uncap option in settings for high-refresh monitors.

---

## 2. Entity Limits (MVP Hard Caps)

| Entity | Max in MVP | Rationale |
|---|---|---|
| Cities | **6** | Kolkata, Dacca, Patna, Murshidabad + 2 future economic-depth cities. Beyond 6, UI panels and economy tick complexity scale non-linearly. |
| Trains | **50** | Phase 1 core loop rarely exceeds 20. 50 is the safety ceiling before pathfinding and interpolation budgets break. |
| Track Segments (edges) | **1,000** | At ~200 segments per dense route, 1,000 covers a fully built Bengal network with redundancy. |
| AI Rivals | **1** | British East India Rail only. Each rival adds parallel route evaluation, pathfinding, and rendering. |
| Active Events | **4** | Hard cap to prevent overlapping event UI spam and compound economy modifier drift. |
| Contracts | **8** | Player + AI combined active contracts. |
| Station Upgrades per City | **3** | Warehouse, Loading Bay, Maintenance Shed. |

---

## 3. Tick Frequencies

| System | Frequency | Max Duration / Frame | Notes |
|---|---|---|---|
| Economy tick | **1× per in-game day** | 2ms | Production, consumption, price update for all cities. |
| Maintenance tick | **1× per in-game day** | 1ms | Train and track condition degradation. |
| Contract deadline tick | **1× per in-game day** | 0.5ms | Countdown and failure check. |
| AI decision cycle | **Every 7 in-game days** | 5ms | Route scoring, expansion desire, train purchase logic. |
| Event roll | **1× per in-game month** | 1ms | Random chance + scheduled events. |
| Save auto-check | **Every 5 real seconds** | 0ms | Non-blocking; only sets a dirty flag. |
| Pathfinding (per train) | **On route assignment or track change** | 3ms | Cached otherwise. See §4. |

**Time Compression Rule:** At 4× speed, all daily ticks run 4× per real second. If the accumulated tick time exceeds 8.33ms (half a frame), ticks are spread across multiple frames with a warning logged.

---

## 4. Pathfinding Budget

### 4.1 Cache Rules

| Cache Type | Key | Invalidated When |
|---|---|---|
| City-to-City path | `(from_city_id, to_city_id)` | Any edge added/removed/damaged between the two nodes; any edge ownership change that blocks private track. |
| Train route path | `train_id` | Train reassigned; any edge in its path changes condition/ownership/access mode. |
| AI route score cache | `(city_a, city_b, cargo_id)` | Economy tick changes prices; new track built; event modifies terrain cost. |

### 4.2 Cache Lifetime
- City-to-city paths: persistent until invalidation.
- Train route paths: persistent for the lifetime of the route assignment.
- AI score cache: cleared at the start of every AI decision cycle (every 7 days).

### 4.3 Algorithm
- Use A* on `TrackGraph` with edge cost = `length_km × terrain_cost × condition_penalty + toll_penalty`.
- Max search nodes: 5,000. If exceeded, log a warning and fall back to greedy best-first.
- Max pathfinding time per query: **3ms**. If exceeded, defer to a background thread (if safe) or spread across 2 frames.

### 4.4 Precomputed Matrix
- At startup, precompute all-pairs shortest paths between the 6 cities using Floyd-Warshall.
- Matrix size: 6×6 = 36 entries. Memory negligible.
- Recompute only when the track graph topology changes (edge add/remove/damage).

---

## 5. Rendering Budget

### 5.1 Draw Call Budget

| Scene Complexity | Max Draw Calls | Notes |
|---|---|---|
| MVP average | **120** | TileMap batches terrain. Trains are individual sprites. |
| MVP stressed | **200** | 50 trains + 6 cities + 1,000 track edges + UI + particles. |
| Hard ceiling | **300** | Above this, investigate batching or LOD. |

**Batching Strategy:**
- Terrain: `TileMapLayer` batches automatically.
- Track: `Line2D` segments owned by the same faction should share a `CanvasItem.material` where possible.
- Trains: cannot batch easily due to independent transforms; keep under 50.
- UI: `CanvasLayer` draw calls are cheap but avoid excessive nested `PanelContainer` nodes.

### 5.2 Particle Limits

| System | Max Particles | Budget |
|---|---|---|
| Train smoke (all trains) | 400 alive | 2 draw calls (two CPUParticles2D batches) |
| Damaged track sparks | 100 alive | 1 draw call |
| Event overlays | 6 overlays | 6 draw calls (translucent polygons) |

**Optimization:** If smoke particles exceed 400, reduce emission rate or switch to a single `GPUParticles2D` emitter per screen quadrant.

### 5.3 LOD / Zoom Rules

| Zoom Level | Detail |
|---|---|
| > 1.5× | Full sprites, particles active, city labels visible. |
| 0.8× – 1.5× | Full sprites, particles at 50% emission, city labels visible. |
| 0.4× – 0.8× | Train sprites simplified to 16×16 dots, particles off, city labels fade to icons only. |
| < 0.4× | Trains hidden, track lines thinned to 1px, city markers only, ownership tint dominates. |

---

## 6. Memory Budget

### 6.1 Total Asset Memory

| Category | Budget | Notes |
|---|---|---|
| Textures (final + placeholder) | **128 MB** | Majority is terrain tiles and train sprites at 2×. |
| Audio (placeholder / early SFX) | **32 MB** | No audio in Phase 1; budget reserved. |
| Game state (runtime) | **32 MB** | TrackGraph, cities, trains, economy history. |
| UI / Font | **16 MB** | Godot default fonts + a single licensed historical font later. |
| Particle buffers & effects | **8 MB** | CPU particle state. |
| Overhead / Godot | **40 MB** | Engine, renderer, autoloads. |
| **Total** | **256 MB** | Hard cap for Phase 1 MVP. |

### 6.2 Texture Memory Breakdown (estimates at 2× density)

| Asset Group | Count | Avg Size | Total |
|---|---:|---:|---:|
| Terrain tiles (17 variants) | 17 | 128×64 PNG | ~2.8 MB |
| Train sprites (8 dirs × 2 types) | 16 | 96×64 PNG | ~5.5 MB |
| City / station markers | 12 | 96×96 PNG | ~9.2 MB |
| Cargo icons | 3 | 64×64 PNG | ~0.5 MB |
| UI atlas | 1 | 512×256 PNG | ~0.8 MB |
| Track sprites | 4 | 128×32 PNG | ~0.5 MB |
| Effects (placeholder) | 0 | — | 0 MB |
| **Total authored** | | | **~19.3 MB** |

> The 128 MB texture budget leaves ample headroom for unplanned assets, atlasing padding, and mipmaps.

---

## 7. Object Pools

| Object | Pool Size | Pool Node | Notes |
|---|---|---|---|
| `TrainEntity` | 50 | `TrainLayer/TrainPool` | Pre-instantiate 10; grow to 50. Never free, only hide + reset. |
| `SmokeParticles` | 50 | `EffectsLayer/SmokePool` | One per train max. Reused when train is sold / reassigned. |
| `SparkParticles` | 20 | `EffectsLayer/SparkPool` | Reused for damaged edges. |
| `Line2D (track edge)` | 1,000 | `TrackLayer/TrackPool` | Pre-allocate 100; grow in chunks of 100. |
| `CityLabel` | 6 | `CityMarkers/LabelPool` | Static after load. |
| `RouteArrow` | 20 | `UILayer/RouteArrowPool` | Reused for route visualization. |

**Pool Rules:**
- All pooled nodes are created at `_ready()` or on demand and never `queue_free()`’d during normal play.
- On state reset (new game), call `reset()` on each pooled object instead of rebuilding the pool.
- Track pool growth beyond 1,000 triggers a warning and falls back to dynamic allocation (with a logged performance note).

---

## 8. Frame Time Budgets (16.67ms per frame @ 60 FPS)

| System | Budget | Typical | Worst Case |
|---|---|---|---|
| **Rendering** | **8.0 ms** | 4.0 ms | 8.0 ms |
| **Train interpolation & movement** | **2.0 ms** | 0.5 ms | 2.0 ms |
| **Economy & maintenance tick** | **2.0 ms** | 0.2 ms | 2.0 ms |
| **Pathfinding (cached)** | **1.0 ms** | 0.0 ms | 1.0 ms |
| **AI logic** | **1.5 ms** | 0.0 ms | 1.5 ms |
| **Input & UI update** | **1.0 ms** | 0.3 ms | 1.0 ms |
| **Particle update** | **0.5 ms** | 0.2 ms | 0.5 ms |
| **Reserve / GC / jitter** | **0.67 ms** | — | — |
| **Total** | **16.67 ms** | ~5.2 ms | ~16.0 ms |

**Over-budget Protocol:**
If a frame exceeds 16.67ms for 3 consecutive frames, the game:
1. Logs a warning with the offending system.
2. If the offender is pathfinding, enables frame-slicing for the next 10 queries.
3. If the offender is rendering, forces zoom-LOD to the next simpler tier.
4. If the offender is AI, defers the decision to the next frame.

---

## 9. Save / Load Performance

| Operation | Target Time | Max Time | Notes |
|---|---|---|---|
| Save to JSON | **200 ms** | **500 ms** | Serialize state, write to `user://saves/`. Async where possible. |
| Load from JSON | **200 ms** | **500 ms** | Parse JSON, reconstruct TrackGraph, respawn trains from pool, restore city economies. |
| Auto-save | **300 ms** | **500 ms** | Runs in background; shows a small spinner if it exceeds 250ms. |

**Save Optimization:**
- Do not serialize node paths. Serialize IDs and dictionaries only.
- Compress large arrays (track node lists) if they exceed 10 KB.
- Use `FileAccess` async mode if available in the target Godot version; otherwise defer to `_process()` frame-slicing.

---

## 10. Stress Test Scenarios

Run these scenarios in debug builds with `DebugManager` telemetry logging frame time, memory, and tick duration.

### 10.1 Train Spam Test
- **Setup:** Start with ₹1,000,000. Build a dense grid connecting all 6 cities.
- **Action:** Spawn 50 trains and assign them all to the longest possible route.
- **Pass Criteria:** 60 FPS at 1× speed, 45 FPS at 4× speed. No pathfinding query > 3ms.

### 10.2 Track Maze Test
- **Setup:** Build 1,000 track segments in a maze-like pattern with many redundant junctions.
- **Action:** Assign 10 trains to random routes across the maze.
- **Pass Criteria:** Frame time < 16.67ms. A* search nodes < 5,000 per query.

### 10.3 Economic Churn Test
- **Setup:** 6 cities, max production/consumption rates.
- **Action:** Run at 16× speed for 1 in-game year.
- **Pass Criteria:** Daily tick never exceeds 2ms. Prices remain stable (no runaway floats). Memory does not grow across the test.

### 10.4 AI Pressure Test
- **Setup:** Player has a modest network; AI has equal capital.
- **Action:** Force AI decision cycle every frame instead of every 7 days.
- **Pass Criteria:** AI decision < 5ms per cycle. No duplicate track edges created.

### 10.5 Memory Leak Test
- **Setup:** Start game, build max entities.
- **Action:** Save, load, repeat 20 times. Fast-forward 10 in-game years.
- **Pass Criteria:** Memory usage after load #20 is within 10% of memory usage after load #1. No orphaned nodes in remote scene tree.

### 10.6 Event Storm Test
- **Setup:** Trigger all 4 event types simultaneously via debug console.
- **Action:** Run for 30 in-game days at 4× speed.
- **Pass Criteria:** No frame drops > 10%. Event effects apply correctly. No overlapping UI panels.

---

## 11. Profiling Checklist

Before each milestone release, profile the following:

- [ ] Run all 6 stress tests and record results in `tests/performance/stress_results.md`.
- [ ] Check `Debugger > Monitors` in Godot editor: Objects, Nodes, Orphan Nodes, VRAM.
- [ ] Verify draw call count with **Rendering > View Frame Time** overlay.
- [ ] Verify no memory growth over a 30-minute play session.
- [ ] Confirm save/load times on a mid-range HDD (not just SSD).
- [ ] Test on minimum spec target: 4-core CPU, integrated GPU, 8 GB RAM.

---

## 12. Exception Handling

If a performance target cannot be met without major architectural changes:

1. Document the exact shortfall and reproduction steps.
2. Propose a scoped reduction (e.g., lower max trains from 50 to 30, or reduce particle count).
3. Do **not** silently degrade quality. Update this document and notify the design lead.
