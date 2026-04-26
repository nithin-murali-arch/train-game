# Rail Empire — Save File Schema

Version: 0.1  
Save format version: `1`  
Engine: Godot 4.2+  
Format: JSON (UTF-8, no BOM)  
Purpose: Exact save file structure, versioning rules, migration strategy, and corruption detection  

---

## 1. Schema Versioning Rules

- The current schema version is **`1`**.
- Every save file **must** contain `"save_version": 1` at the top level.
- The game **must** refuse to load saves with `save_version > current_supported_version`.
- The game **must** attempt migration for saves with `save_version < current_supported_version`.
- Schema version increments only when:
  - A required field is added or removed.
  - The type or semantic meaning of an existing field changes.
  - A top-level section is restructured.
- Adding a new **optional** field to an existing object does **not** require a version bump if the loader uses safe `.get()` access.

---

## 2. Top-Level Structure

```json
{
  "save_version": 1,
  "game_version": "0.2.0",
  "checksum": "sha256:abc123...",
  "created_at": "1857-06-15T10:30:00",
  "play_time_seconds": 3600,
  "session": { ... },
  "factions": { ... },
  "track_graph": { ... },
  "trains": [ ... ],
  "cities": [ ... ],
  "contracts": [ ... ],
  "technologies": [ ... ],
  "events": [ ... ],
  "campaign": { ... },
  "metadata": { ... }
}
```

### 2.1 Required Fields

All of the following must be present and non-null. Missing any is a **corrupt save**.

| Field | Type | Description |
|---|---|---|
| `save_version` | `int` | Schema version. Must be `1`. |
| `game_version` | `string` | Game build version that wrote the save. |
| `checksum` | `string` | SHA-256 checksum of the JSON payload (see §7). |
| `created_at` | `string` | ISO 8601 timestamp of save creation. |
| `play_time_seconds` | `int` | Cumulative real-world play time in seconds. |
| `session` | `object` | Current game session state (date, speed, mode). |
| `factions` | `object` | Treasury, reputation, and per-faction runtime data. |
| `track_graph` | `object` | Rail network: nodes dict and edges dict. |
| `trains` | `array` | List of all train runtime states. |
| `cities` | `array` | List of all city economy runtime states. |

### 2.2 Optional Fields

These may be missing in older saves or empty scenarios. Loaders must provide defaults.

| Field | Type | Default if missing |
|---|---|---|
| `contracts` | `array` | `[]` |
| `technologies` | `array` | `[]` |
| `events` | `array` | `[]` |
| `campaign` | `object` | `null` (treat as freeplay/scenario) |
| `metadata` | `object` | `{}` |

---

## 3. Section Definitions

### 3.1 `session`

```json
{
  "current_date": {
    "day": 15,
    "month": 6,
    "year": 1857,
    "total_days": 0
  },
  "game_speed": 1.0,
  "mode": "campaign",
  "scenario_id": "bengal_railway_charter",
  "era_id": "colonial",
  "seed": 12345,
  "random_state": "base64:..."
}
```

| Field | Type | Required? | Notes |
|---|---|---|---|
| `current_date` | `object` | Yes | `total_days` is the absolute day counter since game start. |
| `game_speed` | `float` | Yes | `0.0`, `1.0`, `2.0`, or `4.0`. |
| `mode` | `string` | Yes | `"campaign"`, `"scenario"`, or `"sandbox"`. |
| `scenario_id` | `string` | Yes | Empty string `""` if not in a scenario. |
| `era_id` | `string` | Yes | `"colonial"` or `"ww1"`. |
| `seed` | `int` | Yes | World generation / event roll seed. |
| `random_state` | `string` | No | Base64-encoded Godot `RandomNumberGenerator` state for deterministic reload. Omit if unsupported. |

### 3.2 `factions`

```json
{
  "player": {
    "faction_id": "player",
    "treasury": 20450,
    "reputation": 12,
    "market_share_total": 0.65,
    "color": "#3B82F6"
  },
  "british": {
    "faction_id": "british",
    "treasury": 15200,
    "reputation": 8,
    "market_share_total": 0.35,
    "color": "#EF4444"
  }
}
```

- Key = `faction_id` string.
- Values = faction runtime state objects.
- The `player` key must exist in every save.

| Field | Type | Required? | Notes |
|---|---|---|---|
| `faction_id` | `string` | Yes | Must match the dict key. |
| `treasury` | `int` | Yes | Can be negative only if bankruptcy allowed; normally clamped ≥ 0. |
| `reputation` | `int` | No | Defaults to `0`. |
| `market_share_total` | `float` | No | Defaults to `0.0`. Sum of all factions should be `1.0`. |
| `color` | `string` | No | Hex color for UI and track rendering. |

### 3.3 `track_graph`

```json
{
  "nodes": {
    "12_8": {
      "id": "12_8",
      "grid": { "x": 12, "y": 8 },
      "world": { "x": 192.0, "y": 128.0 },
      "connected_edges": ["edge_12_8_20_8"],
      "city_id": "kolkata",
      "is_junction": false
    }
  },
  "edges": {
    "edge_12_8_20_8": {
      "id": "edge_12_8_20_8",
      "from_node": "12_8",
      "to_node": "20_8",
      "length_km": 45.5,
      "terrain_cost_multiplier": 1.25,
      "owner_faction_id": "player",
      "condition": 0.92,
      "access_mode": "open",
      "toll_per_km": 0.0,
      "is_bridge": false,
      "is_damaged": false
    }
  }
}
```

#### Nodes dict

- Key = node `id` (string, conventionally `"{x}_{y}"` from grid coordinates).
- Value = `TrackNodeState` serialized.

| Field | Type | Required? | Notes |
|---|---|---|---|
| `id` | `string` | Yes | Must match dict key. |
| `grid` | `object` (`x`, `y` as `int`) | Yes | Logical tile coordinate. |
| `world` | `object` (`x`, `y` as `float`) | Yes | Actual `Node2D` position. |
| `connected_edges` | `array` of `string` | Yes | May be empty `[]` for orphan nodes. |
| `city_id` | `string` | No | Empty `""` if not a city anchor. |
| `is_junction` | `bool` | Yes | `true` if 3+ edges connected. |

#### Edges dict

- Key = edge `id` (string, conventionally `"edge_{from}_{to}"`).
- Value = `TrackEdgeState` serialized.

| Field | Type | Required? | Notes |
|---|---|---|---|
| `id` | `string` | Yes | Must match dict key. |
| `from_node` | `string` | Yes | Must reference a valid node id in `nodes`. |
| `to_node` | `string` | Yes | Must reference a valid node id in `nodes`. |
| `length_km` | `float` | Yes | Must be > 0. |
| `terrain_cost_multiplier` | `float` | Yes | Default `1.0`. |
| `owner_faction_id` | `string` | Yes | References key in `factions`. Use `"neutral"` for unowned. |
| `condition` | `float` | Yes | Range `[0.0, 1.0]`. |
| `access_mode` | `string` | Yes | `"open"`, `"private"`, or `"contract"`. |
| `toll_per_km` | `float` | Yes | Default `0.0`. |
| `is_bridge` | `bool` | Yes | |
| `is_damaged` | `bool` | Yes | |

#### Serialization Rules

1. **Bidirectional edges**: If the graph is undirected for pathfinding, store one edge record. The pathfinder treats `from_node` ↔ `to_node` as traversable in both directions.
2. **No orphaned edges**: Every `from_node` and `to_node` must exist in `nodes`. Loader must validate; invalid edges are dropped with a warning.
3. **No duplicate edges**: Loader should merge or overwrite duplicates based on `id`.
4. **Grid consistency**: `world` position must be derivable from `grid` via the same projection used at save time. `world` is authoritative for rendering; `grid` is authoritative for gameplay logic.

### 3.4 `trains`

```json
[
  {
    "id": "train_001",
    "train_data_id": "freight_engine",
    "owner_faction_id": "player",
    "current_node": "12_8",
    "path_node_ids": ["12_8", "16_8", "20_8"],
    "path_progress": 0.65,
    "cargo_type_id": "coal",
    "cargo_quantity": 200,
    "route_city_ids": ["kolkata", "patna"],
    "route_index": 1,
    "condition": 0.88,
    "last_trip_revenue": 3400,
    "last_trip_cost": 180,
    "last_trip_profit": 3220,
    "state": "traveling",
    "loading_timer": 0.0,
    "maintenance_debt": 0
  }
]
```

| Field | Type | Required? | Notes |
|---|---|---|---|
| `id` | `string` | Yes | Unique train identifier. |
| `train_data_id` | `string` | Yes | Must resolve to a `TrainData` resource in `data/trains/`. |
| `owner_faction_id` | `string` | Yes | Must exist in `factions`. |
| `current_node` | `string` | Yes | Node id where train is currently located or nearest to. |
| `path_node_ids` | `array` of `string` | Yes | Ordered list of node ids for current path. May be empty if idle. |
| `path_progress` | `float` | Yes | Progress along current edge or path segment, `[0.0, 1.0]`. |
| `cargo_type_id` | `string` | No | Empty `""` if no cargo. |
| `cargo_quantity` | `int` | Yes | Default `0`. |
| `route_city_ids` | `array` of `string` | Yes | Repeating city loop. May be empty if unassigned. |
| `route_index` | `int` | Yes | Index into `route_city_ids` for next destination. |
| `condition` | `float` | Yes | Train health `[0.0, 1.0]`. |
| `last_trip_revenue` | `int` | No | Default `0`. |
| `last_trip_cost` | `int` | No | Default `0`. |
| `last_trip_profit` | `int` | No | Default `0`. |
| `state` | `string` | Yes | `"idle"`, `"loading"`, `"traveling"`, `"unloading"`, `"waiting_for_path"`, `"broken_down"`. |
| `loading_timer` | `float` | No | Seconds remaining in current loading/unloading state. Default `0.0`. |
| `maintenance_debt` | `int` | No | Accumulated maintenance not yet deducted. Default `0`. |

#### Loading Rules

- On load, if `state == "traveling"`, recompute the full path from `current_node` to next destination in `route_city_ids` using current `TrackGraph`. If no valid path exists, transition to `"waiting_for_path"`.
- If `train_data_id` is missing from resources, spawn a fallback default train and log an error.

### 3.5 `cities`

```json
[
  {
    "city_id": "kolkata",
    "stock": {
      "coal": 450,
      "textiles": 120,
      "grain": 80
    },
    "demand": {
      "coal": 200,
      "textiles": 50,
      "grain": 150
    },
    "current_prices": {
      "coal": 12,
      "textiles": 38,
      "grain": 18
    },
    "market_share": {
      "player": 0.70,
      "british": 0.30
    },
    "station_upgrades": {
      "warehouse": 1,
      "loading_bay": 0,
      "maintenance_shed": 1
    },
    "production_bonus": 1.0,
    "consumption_bonus": 1.0,
    "is_striking": false
  }
]
```

| Field | Type | Required? | Notes |
|---|---|---|---|
| `city_id` | `string` | Yes | Must resolve to a `CityData` resource. |
| `stock` | `object` (cargo_id → `int`) | Yes | Current cargo stockpile. |
| `demand` | `object` (cargo_id → `int`) | Yes | Daily demand targets. |
| `current_prices` | `object` (cargo_id → `int`) | Yes | Computed prices at save time. |
| `market_share` | `object` (faction_id → `float`) | No | Defaults to `{}`. |
| `station_upgrades` | `object` (upgrade_id → `int`) | No | Level per upgrade. Default `0`. |
| `production_bonus` | `float` | No | Multiplier from events/tech. Default `1.0`. |
| `consumption_bonus` | `float` | No | Multiplier from events/tech. Default `1.0`. |
| `is_striking` | `bool` | No | Labor strike flag. Default `false`. |

#### Validation

- All cargo ids in `stock`, `demand`, and `current_prices` must exist in `data/cargo/` resources.
- Negative stock is invalid; clamp to `0` and warn.
- `market_share` values must sum to `1.0` ± `0.01` per city. If not, normalize on load.

### 3.6 `contracts`

```json
[
  {
    "contract_id": "contract_kolkata_coal_001",
    "status": "active",
    "quantity_delivered": 120,
    "days_remaining": 45,
    "owner_faction_id": "player",
    "accepted_date": { "day": 10, "month": 6, "year": 1857, "total_days": 5 }
  }
]
```

| Field | Type | Required? | Notes |
|---|---|---|---|
| `contract_id` | `string` | Yes | References `ContractData` resource. |
| `status` | `string` | Yes | `"available"`, `"active"`, `"completed"`, `"failed"`, `"expired"`. |
| `quantity_delivered` | `int` | Yes | Default `0`. |
| `days_remaining` | `int` | Yes | Computed from `accepted_date + deadline_days - current_date`. |
| `owner_faction_id` | `string` | Yes | Faction that accepted the contract. |
| `accepted_date` | `object` | No | Required if `status != "available"`. Same shape as `session.current_date`. |

### 3.7 `technologies`

```json
[
  {
    "tech_id": "superheater_design",
    "patent_holder_faction_id": "player",
    "patent_expiry_date": { "day": 1, "month": 1, "year": 1862, "total_days": 1826 },
    "is_public_domain": false
  }
]
```

| Field | Type | Required? | Notes |
|---|---|---|---|
| `tech_id` | `string` | Yes | References `TechnologyData` resource. |
| `patent_holder_faction_id` | `string` | No | Empty if unowned or public domain. |
| `patent_expiry_date` | `object` | No | Same shape as `session.current_date`. |
| `is_public_domain` | `bool` | Yes | `true` if expired and available to all. |

### 3.8 `events`

```json
[
  {
    "event_id": "monsoon_flood_001",
    "event_data_id": "monsoon_flood",
    "status": "warning",
    "trigger_date": { "day": 15, "month": 7, "year": 1857, "total_days": 30 },
    "end_date": { "day": 15, "month": 8, "year": 1857, "total_days": 61 },
    "affected_city_ids": ["kolkata", "dacca"],
    "affected_edge_ids": ["edge_12_8_20_8"],
    "counterplay_taken": false,
    "counterplay_cost": 0
  }
]
```

| Field | Type | Required? | Notes |
|---|---|---|---|
| `event_id` | `string` | Yes | Unique instance id. |
| `event_data_id` | `string` | Yes | References `EventData` resource. |
| `status` | `string` | Yes | `"warning"`, `"active"`, `"resolved"`, `"failed"`. |
| `trigger_date` | `object` | Yes | When effects begin. |
| `end_date` | `object` | Yes | When effects end. |
| `affected_city_ids` | `array` of `string` | No | Defaults to `[]`. |
| `affected_edge_ids` | `array` of `string` | No | Defaults to `[]`. |
| `counterplay_taken` | `bool` | No | Default `false`. |
| `counterplay_cost` | `int` | No | Default `0`. |

### 3.9 `campaign`

```json
{
  "campaign_id": "bengal_railway_charter",
  "current_act": 2,
  "act_progress": {
    "act_1": "completed",
    "act_2": "in_progress",
    "act_3": "locked",
    "act_4": "locked",
    "act_5": "locked"
  },
  "objectives": [
    {
      "objective_id": "connect_kolkata_patna",
      "status": "completed",
      "progress": 1.0
    },
    {
      "objective_id": "reach_200k_net_worth",
      "status": "in_progress",
      "progress": 0.45
    }
  ],
  "victory_condition": null,
  "newspaper_history": ["n_001", "n_002"]
}
```

| Field | Type | Required? | Notes |
|---|---|---|---|
| `campaign_id` | `string` | Yes | Empty `""` if freeplay. |
| `current_act` | `int` | Yes | 1-based act index. `0` if not in campaign. |
| `act_progress` | `object` | No | Maps act key → `"locked"`, `"in_progress"`, `"completed"`. |
| `objectives` | `array` | No | Runtime objective states. |
| `victory_condition` | `string` or `null` | No | Populated when campaign ends. |
| `newspaper_history` | `array` of `string` | No | IDs of shown briefings. |

### 3.10 `metadata`

```json
{
  "save_name": "Colonial Run 1",
  "difficulty": "normal",
  "screenshot_path": "user://saves/slot_01.png",
  "region_id": "bengal",
  "mods": []
}
```

Optional. Used by UI for save slot display. Loader ignores unknown keys.

---

## 4. Schema Migration Strategy

### 4.1 Version 1 (Current)

- Baseline. All fields defined above.

### 4.2 Future Versions (Reserved)

When `save_version` increases, implement a dedicated `SaveMigrator` autoload:

```gdscript
# src/autoload/save_migrator.gd (future)
class_name SaveMigrator

static func migrate(data: Dictionary) -> Dictionary:
    var version = data.get("save_version", 0)
    while version < GameState.CURRENT_SAVE_VERSION:
        match version:
            1:
                data = _migrate_1_to_2(data)
            2:
                data = _migrate_2_to_3(data)
            _:
                push_error("Unknown save version: %d" % version)
                break
        version = data.get("save_version", 0)
    return data
```

#### Migration Rules

1. **Additive changes**: If a new required field is added, compute a sensible default from existing data. Example:
   - New field: `train.breakdown_count` → default `0`.
2. **Renamed fields**: Copy old value to new key, then delete old key. Example:
   - `edge.owner_id` renamed to `edge.owner_faction_id`.
3. **Removed fields**: Drop silently. Do not crash.
4. **Restructured arrays → dicts**: Rebuild lookup structure. Example:
   - If `trains` changes from array to dict keyed by `id`, migrate by building dict from array elements.
5. **Validation after migration**: Run the same integrity checks as a fresh save (see §7).

#### Migration Logging

Every migration step must append to `data["metadata"]["migration_log"]`:

```json
{
  "from_version": 1,
  "to_version": 2,
  "timestamp": "2026-04-26T10:16:00Z",
  "changes": ["Added train.breakdown_count", "Renamed edge.owner_id to edge.owner_faction_id"]
}
```

---

## 5. Corruption Detection

### 5.1 Checksum Validation

Before parsing JSON, verify integrity:

1. Read the raw file bytes.
2. Extract the `checksum` field value from JSON (string starting with `sha256:`).
3. Compute SHA-256 of the JSON payload **with the checksum field itself removed or zeroed**.
4. Compare. If mismatch → reject load with error `"Save file corrupted (checksum mismatch)."`

### 5.2 Structural Validation

After JSON parse, validate:

| Check | Action on Failure |
|---|---|
| `save_version` is integer and `> 0` | Reject with `"Invalid save_version"` |
| `session.current_date` has `day`, `month`, `year` | Reject with `"Missing date fields"` |
| `track_graph.nodes` and `edges` are dictionaries | Reject with `"Malformed track_graph"` |
| Every edge `from_node` / `to_node` exists in `nodes` | Warn and drop invalid edges |
| Every `train_data_id` resolves to a resource | Warn and use fallback train |
| `factions` contains `"player"` key | Reject with `"Missing player faction"` |
| No NaN or Infinity in numeric fields | Clamp or reset to default, then warn |

### 5.3 Semantic Validation

| Check | Action on Failure |
|---|---|
| `treasury` is finite integer | Clamp to `0` |
| `track_graph` edges have `length_km > 0` | Set to `1.0` and warn |
| `train.condition` in `[0.0, 1.0]` | Clamp |
| `city.market_share` sums to `1.0` | Normalize |
| Duplicate `train.id` values | Append suffix `_dup_N` to duplicates |

### 5.4 Graceful Degradation

- If a non-critical subsystem fails validation (e.g., one corrupt event), drop that subsystem and continue loading.
- If a critical subsystem fails (track graph, player faction, session date), abort load and return to main menu with error dialog.
- Never auto-overwrite a save that failed validation.

---

## 6. Example Complete Save File

Below is a realistic but **minimal** save file for a mid-Sprint 02 game state. It demonstrates all required fields and a subset of optional fields.

```json
{
  "save_version": 1,
  "game_version": "0.2.0",
  "checksum": "sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
  "created_at": "1857-06-15T10:30:00",
  "play_time_seconds": 3600,
  "session": {
    "current_date": {
      "day": 15,
      "month": 6,
      "year": 1857,
      "total_days": 45
    },
    "game_speed": 1.0,
    "mode": "scenario",
    "scenario_id": "bengal_intro",
    "era_id": "colonial",
    "seed": 12345,
    "random_state": ""
  },
  "factions": {
    "player": {
      "faction_id": "player",
      "treasury": 12450,
      "reputation": 5,
      "market_share_total": 1.0,
      "color": "#3B82F6"
    }
  },
  "track_graph": {
    "nodes": {
      "12_8": {
        "id": "12_8",
        "grid": { "x": 12, "y": 8 },
        "world": { "x": 192.0, "y": 128.0 },
        "connected_edges": ["edge_12_8_20_8", "edge_12_8_12_16"],
        "city_id": "kolkata",
        "is_junction": true
      },
      "20_8": {
        "id": "20_8",
        "grid": { "x": 20, "y": 8 },
        "world": { "x": 320.0, "y": 128.0 },
        "connected_edges": ["edge_12_8_20_8"],
        "city_id": "patna",
        "is_junction": false
      },
      "12_16": {
        "id": "12_16",
        "grid": { "x": 12, "y": 16 },
        "world": { "x": 192.0, "y": 256.0 },
        "connected_edges": ["edge_12_8_12_16"],
        "city_id": "murshidabad",
        "is_junction": false
      }
    },
    "edges": {
      "edge_12_8_20_8": {
        "id": "edge_12_8_20_8",
        "from_node": "12_8",
        "to_node": "20_8",
        "length_km": 120.0,
        "terrain_cost_multiplier": 1.0,
        "owner_faction_id": "player",
        "condition": 1.0,
        "access_mode": "open",
        "toll_per_km": 0.0,
        "is_bridge": false,
        "is_damaged": false
      },
      "edge_12_8_12_16": {
        "id": "edge_12_8_12_16",
        "from_node": "12_8",
        "to_node": "12_16",
        "length_km": 85.0,
        "terrain_cost_multiplier": 1.25,
        "owner_faction_id": "player",
        "condition": 0.98,
        "access_mode": "open",
        "toll_per_km": 0.0,
        "is_bridge": false,
        "is_damaged": false
      }
    }
  },
  "trains": [
    {
      "id": "train_001",
      "train_data_id": "freight_engine",
      "owner_faction_id": "player",
      "current_node": "12_8",
      "path_node_ids": ["12_8", "20_8"],
      "path_progress": 0.0,
      "cargo_type_id": "coal",
      "cargo_quantity": 200,
      "route_city_ids": ["kolkata", "patna"],
      "route_index": 1,
      "condition": 0.95,
      "last_trip_revenue": 2800,
      "last_trip_cost": 120,
      "last_trip_profit": 2680,
      "state": "loading",
      "loading_timer": 2.5,
      "maintenance_debt": 0
    },
    {
      "id": "train_002",
      "train_data_id": "mixed_engine",
      "owner_faction_id": "player",
      "current_node": "12_16",
      "path_node_ids": ["12_16", "12_8"],
      "path_progress": 0.3,
      "cargo_type_id": "grain",
      "cargo_quantity": 80,
      "route_city_ids": ["murshidabad", "kolkata"],
      "route_index": 0,
      "condition": 0.97,
      "last_trip_revenue": 1600,
      "last_trip_cost": 80,
      "last_trip_profit": 1520,
      "state": "traveling",
      "loading_timer": 0.0,
      "maintenance_debt": 0
    }
  ],
  "cities": [
    {
      "city_id": "kolkata",
      "stock": { "coal": 320, "textiles": 85, "grain": 40 },
      "demand": { "coal": 150, "textiles": 60, "grain": 120 },
      "current_prices": { "coal": 18, "textiles": 42, "grain": 22 },
      "market_share": { "player": 1.0 },
      "station_upgrades": { "warehouse": 0, "loading_bay": 0, "maintenance_shed": 0 },
      "production_bonus": 1.0,
      "consumption_bonus": 1.0,
      "is_striking": false
    },
    {
      "city_id": "patna",
      "stock": { "coal": 650, "textiles": 10, "grain": 30 },
      "demand": { "coal": 80, "textiles": 90, "grain": 60 },
      "current_prices": { "coal": 10, "textiles": 48, "grain": 25 },
      "market_share": { "player": 1.0 },
      "station_upgrades": { "warehouse": 0, "loading_bay": 0, "maintenance_shed": 0 },
      "production_bonus": 1.0,
      "consumption_bonus": 1.0,
      "is_striking": false
    },
    {
      "city_id": "murshidabad",
      "stock": { "coal": 50, "textiles": 20, "grain": 400 },
      "demand": { "coal": 60, "textiles": 40, "grain": 80 },
      "current_prices": { "coal": 20, "textiles": 38, "grain": 14 },
      "market_share": { "player": 1.0 },
      "station_upgrades": { "warehouse": 0, "loading_bay": 0, "maintenance_shed": 0 },
      "production_bonus": 1.0,
      "consumption_bonus": 1.0,
      "is_striking": false
    }
  ],
  "contracts": [
    {
      "contract_id": "contract_kolkata_coal_001",
      "status": "active",
      "quantity_delivered": 80,
      "days_remaining": 38,
      "owner_faction_id": "player",
      "accepted_date": { "day": 10, "month": 6, "year": 1857, "total_days": 40 }
    }
  ],
  "technologies": [],
  "events": [],
  "campaign": null,
  "metadata": {
    "save_name": "Bengal Run 1",
    "difficulty": "normal",
    "screenshot_path": "",
    "region_id": "bengal",
    "mods": []
  }
}
```

---

## 7. Save/Load Implementation Checklist

- [ ] `GameState.to_dict()` produces a dictionary matching this schema.
- [ ] `GameState.from_dict(data)` validates version and checksum before applying state.
- [ ] `TrackGraph.to_dict()` serializes `nodes` and `edges` exactly as specified.
- [ ] `TrackGraph.from_dict(data)` validates all edge references and drops orphans with warnings.
- [ ] `TrainManager.to_dict()` serializes every train state in the `trains` array.
- [ ] `TrainManager.from_dict(data)` respawns train nodes and reassigns paths.
- [ ] `EconomyManager.to_dict()` serializes `cities` array.
- [ ] `EconomyManager.from_dict(data)` restores city economies and re-links to `CityData` resources.
- [ ] `ContractManager`, `TechnologyAuctionManager`, and `EventManager` all implement `to_dict()` / `from_dict()`.
- [ ] Save file written to `user://saves/slot_N.json` (or OS-appropriate path).
- [ ] Save file name includes timestamp or player-provided name.
- [ ] Load menu lists valid saves only (parsable JSON, valid checksum, supported version).
- [ ] Failed loads show a user-facing error dialog, not a console crash.
- [ ] Auto-save slot exists and is overwritten (max 3 rotating slots).

---

## 8. Schema Change Log

| Date | Version | Change | Author |
|---|---|---|---|
| 2026-04-26 | 1 | Initial schema for Colonial Bengal MVP | Production Control |
