# Rail Empire — design.md

Version: 0.2  
Engine: Godot 4.2+  
Primary target: Desktop first, web later  
Development strategy: depth first, one strategic layer per milestone

---

## 1. Purpose

This is the implementation-facing game design document for Rail Empire. It turns the product vision into concrete systems, data models, gameplay rules, UI flows, initial balance values, and implementation guardrails.

Use this with:

- `design_bible.md` for pillars, tone, canon, and scope boundaries.
- `art_style_guide.md` for visual style, placeholders, AI-assisted assets, and procedural art rules.
- `rail_empire_execution_pack.md` for PRDs, epics, stories, tasks, and sprint prompts.

---

## 2. Product promise

Rail Empire is an isometric 2D railway tycoon set first in Colonial Bengal. The player builds track, buys trains, transports cargo, earns revenue, expands a rail network, and eventually outcompetes rival railway companies through route economics, infrastructure control, and crisis resilience.

The game is not a combat game. Conflict appears through logistics pressure, market competition, track ownership, tolls, contracts, disruption events, and era-specific demand shifts.

---

## 3. Scope contract

The game must become deep before it becomes broad.

### Build order

1. Route Toy
2. Colonial Bengal Core Loop
3. Economic Depth
4. First Rival Pressure
5. Network Control
6. Events and Disruption
7. Colonial Campaign
8. Faction Variety
9. WW1 Expansion
10. Game Modes
11. Art, Audio, and Polish

### Hard rule

Do not add a new era, region, faction, mode, or cargo family unless the current sprint explicitly requests it.

### First playable MVP

The first playable MVP is Colonial Bengal only:

- 1 region: Bengal
- 4 cities: Kolkata, Dacca, Patna, Murshidabad
- 3 cargo types: Coal, Textiles, Grain
- 2 train types: Freight Engine, Mixed Engine
- 1 player faction
- No active rival AI until the First Rival phase
- No WW1 until the WW1 phase
- No Sandbox until the Game Modes phase

---

## 4. Core fantasy

The player should feel like they are turning scattered towns, ports, mines, and farms into a living rail network.

The strongest player moment is:

> “I built this line because I understood the economy better than my rivals.”

The game is about reading the map, reading demand, placing infrastructure, and adapting as the economy changes.

---

## 5. Core loop

### Moment-to-moment loop

1. Inspect a city.
2. Compare supply, demand, prices, and route costs.
3. Place or extend track.
4. Buy or assign a train.
5. Watch the train move and deliver cargo.
6. See revenue, profit, and city stock change.
7. Adjust route or expand.

### Session loop

1. Start with limited capital.
2. Build one profitable route.
3. Reinvest into a second route, better train, station upgrade, or contract.
4. Manage saturation and maintenance.
5. Respond to events or rival pressure.
6. Reach an objective: net worth, market share, contract completion, or network coverage.

### Campaign loop

1. Complete a structured act.
2. Unlock a new objective, map pressure, or system layer.
3. Carry company progress forward.
4. Face a deeper strategic challenge.
5. Eventually survive an era transition.

---

## 6. Design pillars

### 6.1 Route economics first

Every route should have tradeoffs: distance, terrain, construction cost, maintenance, cargo price, demand saturation, train suitability, and future strategic value.

### 6.2 Infrastructure is power

Track is not just pathing. Track is owned infrastructure. Later phases add tolls, private access, bridge bottlenecks, inspections, condition, and monopoly pressure.

### 6.3 Clear systems over hidden complexity

The player should understand why they made or lost money. Tooltips and panels must expose buy price, sell price, train capacity, maintenance, construction cost, last trip profit, and estimated break-even.

### 6.4 Events create counterplay

Events must not be pure punishment. Good events warn the player, create risk, and offer preparation choices.

### 6.5 Era changes repurpose the network

When WW1 eventually arrives, the same Bengal network should feel different. Old routes may become less profitable; coal, military cargo, and requisition become important.

---

# 7. Phase design

## Phase 0 — Route Toy

Goal: prove track + train + money.

Scope:

- 2 cities
- 1 cargo
- 1 train
- 1 player
- No AI
- No events
- No save/load requirement
- Placeholder art only

Required features:

- Camera and map shell
- City markers
- Click-to-build track
- TrackGraph pathfinding
- Train purchase button
- Assign route
- Train moves along route
- Cargo sells at destination
- Treasury updates

Exit criteria: the player can build a track, buy a train, assign it to a route, deliver cargo, and earn money without debug intervention.

## Phase 1 — Colonial Bengal Core Loop

Goal: turn the toy into the first real tycoon loop.

Scope:

- Bengal region
- Kolkata, Dacca, Patna, Murshidabad
- Coal, Textiles, Grain
- Freight Engine, Mixed Engine
- Player-only economy

Required features:

- Isometric terrain map
- Terrain-based track costs
- City supply and demand
- Daily economy tick
- Dynamic pricing
- Train capacity and maintenance
- Route profitability display
- Basic manual save/load

Exit criteria: the player can play a meaningful short session, expand from one route to multiple routes, and make decisions about cargo, trains, and track investment.

## Phase 2 — Economic Depth

Goal: make the economy fun before adding enemies.

Scope additions:

- 5–6 cities
- 4 cargo types
- 3 train types
- Contracts
- Station upgrades
- Demand saturation
- Technology auctions, player-only first

Exit criteria: the game is interesting without rivals because the economy creates meaningful optimization decisions.

## Phase 3 — First Rival Pressure

Goal: add one visible competitor.

Scope additions:

- British East India Rail AI
- Rival treasury
- Rival tracks and trains
- Market share
- Rival bidding in technology auctions

Exit criteria: the rival creates pressure without feeling random, unfair, or opaque.

## Phase 4 — Network Control

Goal: make owned track strategically valuable.

Scope additions:

- Track ownership
- Tolls
- Private/open/contract access states
- Junction and bridge bottlenecks
- Track condition and maintenance

Exit criteria: the player can win or lose advantage through infrastructure control, not just train count.

## Phase 5 — Events and Disruption

Goal: add fair disruption.

Initial events:

- Monsoon Flood
- Labor Strike
- Port Boom
- Track Inspection

Exit criteria: events make runs feel different and encourage planning without creating arbitrary failure.

## Phase 6 — Colonial Campaign

Goal: make Colonial Bengal feel like a complete game arc.

Campaign: `Bengal Railway Charter`

Acts:

1. First Charter
2. Port Expansion
3. Inland Expansion
4. Monopoly Race
5. Crisis Finale

Exit criteria: Colonial Bengal can stand alone as a satisfying small game.

## Phase 7 — Faction Variety

Goal: make a small number of factions mechanically meaningful.

Initial faction set:

- British East India Rail
- French Compagnie des Indes
- Amdani Rail

Exit criteria: faction choice changes strategy without requiring separate content pipelines.

## Phase 8 — WW1 Expansion

Goal: transform the same Bengal map under wartime pressure.

Scope additions:

- WW1 era data
- Troops, Munitions, Medical Supplies, Coal
- Military contracts
- Government requisition
- Era transition

Exit criteria: the same network feels meaningfully different under wartime logistics.

## Phase 9 — Game Modes

Goal: package proven systems.

Modes:

1. Scenario
2. Campaign
3. Sandbox

Exit criteria: modes reuse the same systems and do not create separate gameplay branches.

## Phase 10 — Art, Audio, and Polish

Goal: make the game coherent, readable, and satisfying.

Required focus:

- Colonial visual pass
- WW1 visual modifications
- Audio feedback
- UI polish
- Accessibility checks
- Export builds

---

# 8. Core systems

## 8.1 Time system

Use an accelerated in-game calendar.

Recommended early defaults:

- 1 real second = 1 game hour at speed 1×
- 24 game hours = 1 game day
- Economy tick = daily
- Maintenance tick = daily
- Contract deadline tick = daily
- Event roll = monthly unless event specifies otherwise

Game speeds:

- Pause
- 1×
- 2×
- 4×

Debug builds may support faster speeds.

---

## 8.2 Map system

Use 2D isometric presentation. Terrain may begin as geometric placeholder shapes. Do not block development on final TileSet art.

Maintain two coordinate spaces:

- Grid coordinate: logical tile or graph coordinate
- World coordinate: actual Node2D position

Never store gameplay state only in pixel positions. Use grid/graph coordinates for save/load and pathfinding.

Minimum MVP terrain:

| Terrain | Track Cost Multiplier | Notes |
|---|---:|---|
| Plains | 1.0 | Default |
| Forest | 1.25 | Mildly expensive |
| River | 2.5 | Requires bridge visual later |
| Hills | 2.0 | Slower/expensive |

Cities are graph anchors and economy nodes. They should be clickable objects with stable IDs.

---

## 8.3 Track system

Track is both path and asset. It must support pathfinding, ownership, tolls, condition, damage, repair, and rendering.

### TrackGraph

Use a custom graph structure. Gameplay state must live in game-owned data.

```gdscript
class_name TrackGraph
var nodes: Dictionary # node_id -> TrackNodeState
var edges: Dictionary # edge_id -> TrackEdgeState
```

### TrackNodeState

```gdscript
{
  "id": "x_y",
  "grid": Vector2i,
  "world": Vector2,
  "connected_edges": PackedStringArray,
  "city_id": String,
  "is_junction": bool
}
```

### TrackEdgeState

```gdscript
{
  "id": String,
  "from_node": String,
  "to_node": String,
  "length_km": float,
  "terrain_cost_multiplier": float,
  "owner_faction_id": String,
  "condition": float,
  "access_mode": "open",
  "toll_per_km": float,
  "is_bridge": bool,
  "is_damaged": bool
}
```

Pathfinding cost:

```text
cost = length_km × terrain_cost_multiplier × condition_penalty + toll_penalty_if_non_owner
```

Private track should be excluded unless the moving train owns the edge or has access.

### Track placement MVP

1. Player selects city or grid node start.
2. Player selects destination.
3. System previews route as straight segment or simple snapped path.
4. System computes cost.
5. Player confirms.
6. Treasury is charged.
7. TrackGraph nodes and edges are created.

Do not implement complex rail geometry before the loop is fun.

---

## 8.4 Train system

Trains are scheduled economic actors, not physics vehicles.

Use `Node2D` interpolation along graph path points. Avoid `CharacterBody2D` unless collision becomes necessary.

### TrainData

```gdscript
class_name TrainData extends Resource
@export var id: String
@export var display_name: String
@export var era_id: String
@export var purchase_cost: int
@export var speed_km_per_hour: float
@export var cargo_capacity_tons: int
@export var maintenance_per_day: int
@export var reliability: float
@export var allowed_cargo_tags: PackedStringArray
@export var sprite: Texture2D
```

### TrainState

```gdscript
{
  "id": String,
  "train_data_id": String,
  "owner_faction_id": String,
  "current_node": String,
  "path_node_ids": PackedStringArray,
  "path_progress": float,
  "cargo_type_id": String,
  "cargo_quantity": int,
  "route_city_ids": PackedStringArray,
  "route_index": int,
  "condition": float,
  "last_trip_revenue": int,
  "last_trip_cost": int,
  "last_trip_profit": int
}
```

Movement states:

- Idle
- Loading
- Traveling
- Unloading
- WaitingForPath
- BrokenDown

Early loading rule: train loads the highest-profit available cargo for its assigned route. Later, player can choose cargo priority manually.

---

## 8.5 Cargo system

### CargoData

```gdscript
class_name CargoData extends Resource
@export var id: String
@export var display_name: String
@export var base_price_per_ton: int
@export var tags: PackedStringArray
@export var era_ids: PackedStringArray
@export var icon: Texture2D
```

Colonial MVP cargo:

| Cargo | Type | Base Price | Gameplay Role |
|---|---|---:|---|
| Coal | Bulk | ₹15/ton | Low value, high volume, stable demand |
| Textiles | Manufactured | ₹35/ton | Medium value, industrial trade |
| Grain | Food | ₹20/ton | Stable, event-sensitive |

Use either Tea or Indigo first in Economic Depth, not both.

---

## 8.6 City economy system

### CityData

```gdscript
class_name CityData extends Resource
@export var id: String
@export var display_name: String
@export var role: String
@export var grid_position: Vector2i
@export var population: int
@export var produced_cargo: Dictionary
@export var demanded_cargo: Dictionary
@export var starting_stock: Dictionary
@export var terrain_context: Dictionary
@export var special_modifiers: Dictionary
```

### CityEconomyState

```gdscript
{
  "city_id": String,
  "stock": Dictionary,
  "demand": Dictionary,
  "current_prices": Dictionary,
  "market_share": Dictionary,
  "station_upgrades": Dictionary
}
```

Daily tick:

1. Produce cargo into stock.
2. Consume demanded cargo from stock.
3. Update prices.
4. Update saturation warnings.
5. Update active contract progress if relevant.

Pricing formula:

```text
price = base_price × (1 + (demand - supply) / (demand + supply + 1))
price = clamp(price, base_price × 0.5, base_price × 2.0)
```

Do not let price divide by zero or explode.

---

## 8.7 Transaction system

On arrival:

1. Train reaches destination city.
2. If carrying cargo, sell cargo at destination price.
3. Add revenue to owner treasury.
4. Add cargo to city stock if the city consumes/stores it.
5. Update market share for delivered tonnage.
6. Record trip revenue.
7. Load next cargo if available.
8. Continue route.

MVP simplification: cargo can be considered free at origin and revenue-only at destination. In Phase 1, add buy price or origin opportunity cost only if the loop needs it.

Profit display:

```text
last_trip_profit = revenue - maintenance_allocated - tolls_paid - loading_costs
```

---

## 8.8 Route profitability system

Before building or assigning a route, show expected economics.

Estimated revenue:

```text
estimated_revenue = min(train_capacity, origin_stock) × destination_price
```

Estimated trip cost:

```text
estimated_cost = proportional_maintenance + tolls + optional_loading_cost
```

Break-even:

```text
break_even_trips = construction_cost / max(estimated_net_profit_per_trip, 1)
```

Required displays:

- Construction cost
- Expected cargo carried
- Expected destination price
- Expected revenue
- Maintenance estimate
- Toll estimate
- Estimated net profit
- Break-even trips

---

## 8.9 Station upgrades

| Upgrade | Effect | Design Purpose |
|---|---|---|
| Warehouse | Higher cargo storage | Supports stockpiling and contracts |
| Loading Bay | Faster loading/unloading | Improves high-traffic stations |
| Maintenance Shed | Lower train maintenance / repairs | Supports hub strategy |

Rules:

- Upgrades are city/station scoped.
- Upgrades cost money.
- Upgrades may add daily upkeep.
- Upgrades should have visible map indicators.

---

## 8.10 Contract system

### ContractData

```gdscript
class_name ContractData extends Resource
@export var id: String
@export var display_name: String
@export var cargo_id: String
@export var destination_city_id: String
@export var quantity_required: int
@export var deadline_days: int
@export var reward: int
@export var reputation_reward: int
@export var failure_penalty: int
@export var era_ids: PackedStringArray
```

### ContractState

```gdscript
{
  "contract_id": String,
  "status": "available",
  "quantity_delivered": int,
  "days_remaining": int,
  "owner_faction_id": String
}
```

First contracts:

- Deliver 200 Coal to Kolkata by Month 3.
- Deliver 150 Grain to Dacca during shortage.
- Connect Kolkata and Murshidabad within 60 days.

---

## 8.11 Technology auction system

No tech tree in early design. Technologies appear randomly or on a schedule.

Patent rule: winner gets exclusive benefit for a fixed duration. After expiry, all factions receive the benefit for free.

Auction triggers:

- Scheduled every 2 years
- 15% yearly random chance

Initial technologies:

| Technology | Bonus | Patent Duration |
|---|---|---:|
| Superheater Design | +10% train speed | 5 years |
| Riveted Bridges | -20% bridge cost | 5 years |
| Standardized Parts | -10% train purchase cost | 4 years |
| Hydraulic Cranes | +20% load speed | 4 years |
| Rack-and-Pinion | Reduced hill penalty | 6 years |

---

## 8.12 AI system

Start with British East India Rail only.

AI states:

1. Analyze
2. Expand
3. Operate
4. React

Route score:

```text
route_score = expected_profit_per_trip × demand_stability × faction_preference - construction_cost_penalty - rival_control_penalty
```

AI fairness rule: AI must use the same economy rules as player. Difficulty modifiers can come later, but not while debugging core behavior.

---

## 8.13 Track ownership and tolls

Access modes:

| Mode | Meaning |
|---|---|
| Open | Other factions may use track and pay toll |
| Private | Other factions cannot path through the track |
| Contract | Access allowed through scenario/campaign rule |

Toll payment:

```text
toll = edge.length_km × edge.toll_per_km
```

If one faction owns all operational rail access into a city, display Monopoly status. Consider +10% price leverage or contract priority, but avoid making monopoly impossible to break.

---

## 8.14 Maintenance and condition

Track condition ranges from 0.0 to 1.0.

- 1.0 = perfect
- 0.5 = poor, speed penalty
- 0.0 = unusable/destroyed

Daily degradation:

```text
degradation = base_rate × terrain_modifier × traffic_modifier × event_modifier
```

Early implementation can use a simple daily flat rate.

---

## 8.15 Event system

### EventData

```gdscript
class_name EventData extends Resource
@export var id: String
@export var display_name: String
@export var description: String
@export var era_ids: PackedStringArray
@export var trigger_type: String
@export var warning_days: int
@export var duration_days: int
@export var effects: Dictionary
```

First event rules:

| Event | Warning | Effect | Counterplay |
|---|---|---|---|
| Monsoon Flood | 30 days | River track damage risk | Bridge upgrades, repair budget |
| Labor Strike | 0–7 days | Slower loading in one city | Pay settlement or wait |
| Port Boom | Immediate | Export prices rise | Redirect trains |
| Track Inspection | Scheduled | Fines poor track | Repair before inspection |

---

## 8.16 Save/load system

Use JSON for early builds.

Required saved state:

- Current phase/scenario/campaign ID
- Current date and speed
- Player and rival treasuries
- Reputation
- TrackGraph nodes and edges
- Trains and schedules
- City economy states
- Contracts
- Technologies and patent timers
- Events
- Campaign act progress

Save design rule: all runtime gameplay state must be serializable without relying on scene node paths.

---

# 9. Canonical MVP content

## 9.1 Cities

| City | Role | Produces | Demands | Notes |
|---|---|---|---|---|
| Kolkata | Port metropolis | Textiles | Coal, Grain | Main high-demand hub |
| Dacca | Industrial city | Textiles | Coal, Grain | Input/output trade |
| Patna | Mining center | Coal | Textiles, Grain | Bulk cargo origin |
| Murshidabad | Agricultural town | Grain | Textiles, Coal | Stable low-margin route |

## 9.2 Trains

| Train | Cost | Capacity | Speed | Maintenance | Role |
|---|---:|---:|---:|---:|---|
| Freight Engine | ₹5,000 | 200 tons | 2 km/tick | ₹50/day | Bulk cargo |
| Mixed Engine | ₹10,000 | 100 tons | 4 km/tick | ₹80/day | Faster flexible service |

## 9.3 Initial player state

Suggested:

- Treasury: ₹20,000
- Starting city: Kolkata
- Starting date: 1857 or scenario-specific
- No tracks
- No trains
- Tutorial objective: Connect Kolkata and Patna

---

# 10. UI requirements

## 10.1 HUD

Show:

- Treasury
- Date
- Game speed
- Current objective
- Active event ticker
- Selected tool

## 10.2 Build menu

Include:

- Track tool
- Cancel tool
- Train purchase button
- Station upgrade button later

## 10.3 City panel

Show:

- City name and role
- Produced cargo
- Demanded cargo
- Stock levels
- Current prices
- Market share later
- Station upgrades later
- Contracts tied to city later

## 10.4 Train panel

Show:

- Train name/type
- Owner
- Current route
- Cargo
- Capacity
- Speed
- Condition
- Last trip revenue/cost/profit

## 10.5 Route preview panel

Show:

- Route endpoints
- Track construction cost
- Estimated cargo revenue
- Estimated maintenance/toll cost
- Break-even estimate

---

# 11. Balance principles

- Early game: one sensible route should make money, but the player should not afford everything.
- Mid game: growth should create operational problems: saturation, maintenance, loading delays, and capital allocation.
- Rival phase: rivals should pressure high-value routes and bottlenecks, not spam random track.
- Events: preparation should matter more than luck.

---

# 12. Testing checklists

## Route Toy

- Can start game scene.
- Can pan and zoom map.
- Cities are visible and clickable.
- Can build track between two cities.
- Treasury decreases after construction.
- Can buy train.
- Can assign route.
- Train moves along track.
- Train delivers cargo.
- Treasury increases.
- Last trip profit is visible.

## Colonial MVP

- Terrain costs affect construction.
- City prices update daily.
- Train maintenance deducts daily.
- Oversupply lowers price.
- Route profitability estimate is plausible.
- Save/load restores tracks, trains, treasury, city stock, and date.

## AI

- AI selects a profitable route.
- AI builds track it can afford.
- AI buys train.
- AI delivers cargo under same rules.
- Market share updates.
- Player can visually distinguish AI network.

## Events

- Event warning appears.
- Event effects are applied.
- Player has at least one counterplay option.
- Event ends cleanly.
- Save/load preserves active event state.

---

# 13. Kimi implementation boundaries

1. Implement the current sprint only.
2. Do not add features from later phases because the structure is ready.
3. Use placeholder visuals until the art sprint.
4. Keep all data-driven content in Resource classes or serializable dictionaries.
5. Do not hardcode world data inside UI scripts.
6. Prefer readable, testable GDScript.
7. End every sprint with manual test steps.
8. If a system is not fun, simplify it rather than adding more content.

---

# 14. Glossary

| Term | Meaning |
|---|---|
| City | Economy node that produces/demands cargo |
| Cargo | Good transported by train |
| TrackGraph | Logical rail network used for pathfinding and ownership |
| Segment | Edge between two track nodes |
| Route | Repeating city sequence assigned to a train |
| Contract | Time-limited delivery objective |
| Faction | Player or AI company identity |
| Era | Data-driven time period that changes trains, cargo, events, and UI flavor |
| Market Share | Percentage of delivered cargo controlled by faction |
| Toll | Fee paid to use another faction's track |
| Condition | Health/quality value for track or train |
