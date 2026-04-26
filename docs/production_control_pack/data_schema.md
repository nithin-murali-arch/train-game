# Rail Empire — Data Schema

All data-driven content lives in Godot `Resource` classes (`.tres` files or loaded at runtime).  
`SaveGameData` is the sole exception: it is a runtime serialization container saved to JSON and does **not** extend `Resource`.

---

## CityData

```gdscript
class_name CityData extends Resource

@export var city_id: String = ""                                ## Unique identifier (snake_case). Not nullable.
@export var display_name: String = ""                           ## Player-visible city name. Not nullable.
@export var region_id: String = ""                              ## Links to RegionData.region_id. Not nullable.
@export var role: String = ""                                   ## Economy role: "port", "industrial", "mining", "agricultural". Not nullable.
@export var grid_position: Vector2i = Vector2i.ZERO             ## Logical tile coordinate on the isometric map. Not nullable.
@export var population: int = 0                                 ## Population count; scales demand in later phases. Not nullable.
@export var produced_cargo: Dictionary = {}                     ## cargo_id -> daily production rate (int tons/day). Optional; empty if no production.
@export var demanded_cargo: Dictionary = {}                     ## cargo_id -> daily consumption rate (int tons/day). Optional; empty if no demand.
@export var starting_stock: Dictionary = {}                     ## cargo_id -> initial stock at game start (int tons). Optional.
@export var max_stock_per_cargo: int = 200                      ## Stockpile cap per cargo type. Not nullable.
@export var terrain_context: Dictionary = {}                    ## Contextual tags, e.g. {"dominant":"plains","river_adjacent":true}. Optional.
@export var special_modifiers: Dictionary = {}                  ## Static modifiers for pricing/events. Optional.
@export var starting_upgrades: Array[String] = []               ## Upgrade IDs present at game start. Optional.
@export var map_icon: Texture2D                                 ## Optional. City marker sprite.
@export var is_starting_city: bool = false                      ## True if the player faction begins here. Not nullable.
@export var is_unlocked: bool = true                            ## False if gated behind campaign progress. Not nullable.
```

---

## CargoData

```gdscript
class_name CargoData extends Resource

@export var cargo_id: String = ""                               ## Unique identifier (snake_case). Not nullable.
@export var display_name: String = ""                           ## Player-visible cargo name. Not nullable.
@export var base_price_per_ton: int = 10                        ## Base sale price before supply/demand. Not nullable.
@export var weight_class: String = "medium"                     ## "light", "medium", "heavy". Affects train eligibility. Not nullable.
@export var tags: PackedStringArray = []                        ## Gameplay tags: "bulk", "manufactured", "food", "luxury", "military". Optional.
@export var era_ids: PackedStringArray = []                     ## Eras in which this cargo spawns. Optional; empty = all eras.
@export var icon: Texture2D                                     ## Optional. UI inventory icon.
@export var is_perishable: bool = false                         ## If true, certain events may destroy stock. Not nullable.
```

---

## TrainData

```gdscript
class_name TrainData extends Resource

@export var train_id: String = ""                               ## Unique identifier (snake_case). Not nullable.
@export var display_name: String = ""                           ## Player-visible train name. Not nullable.
@export var era_id: String = ""                                 ## Era in which this train is available. Not nullable.
@export var purchase_cost: int = 0                              ## Upfront buy price in ₹. Not nullable.
@export var speed_km_per_hour: float = 0.0                      ## Travel speed in game km per hour. Not nullable.
@export var cargo_capacity_tons: int = 0                        ## Maximum cargo load in tons. Not nullable.
@export var maintenance_per_day: int = 0                        ## Daily upkeep deducted from treasury. Not nullable.
@export var reliability: float = 1.0                            ## 0.0–1.0 probability of avoiding breakdown per trip. Not nullable.
@export var allowed_cargo_tags: PackedStringArray = []          ## Whitelist tags; empty = any cargo allowed. Optional.
@export var sprite: Texture2D                                   ## Optional. In-world sprite texture.
@export var description: String = ""                            ## Tooltip / shop description. Optional.
@export var required_technology_id: String = ""                 ## Optional. Tech ID required to unlock purchase; empty = no requirement.
```

---

## RegionData

```gdscript
class_name RegionData extends Resource

@export var region_id: String = ""                              ## Unique identifier (snake_case). Not nullable.
@export var display_name: String = ""                           ## Player-visible region name. Not nullable.
@export var era_id: String = ""                                 ## Era this region belongs to. Not nullable.
@export var map_size: Vector2i = Vector2i(64, 64)              ## Grid dimensions in tiles. Not nullable.
@export var default_terrain: String = "plains"                  ## Base terrain for empty tiles. Not nullable.
@export var terrain_costs: Dictionary = {}                      ## terrain_id -> base cost per km (int). Optional; falls back to global default.
@export var city_ids: PackedStringArray = []                    ## Ordered list of city IDs in this region. Not nullable.
@export var starting_treasury: int = 20000                      ## Default starting money for player. Not nullable.
@export var starting_date: Dictionary = {"year":1857,"month":1,"day":1}  ## In-game start date. Not nullable.
@export var description: String = ""                            ## Flavor text shown in selection. Optional.
@export var unlock_condition: String = ""                       ## Campaign flag required; empty = unlocked. Optional.
```

---

## FactionData

```gdscript
class_name FactionData extends Resource

@export var faction_id: String = ""                             ## Unique identifier (snake_case). Not nullable.
@export var display_name: String = ""                           ## Player-visible company name. Not nullable.
@export var ai_type: String = ""                                ## "player", "british_expansion", "french_luxury", "amdani_cheap". Not nullable.
@export var starting_treasury: int = 20000                      ## Initial capital. Not nullable.
@export var starting_city_id: String = ""                       ## Spawn city. Not nullable.
@export var color: Color = Color.WHITE                          ## Map / UI color. Not nullable.
@export var flag_icon: Texture2D                                ## Optional. Faction selection icon.
@export var reputation: int = 0                                 ## Starting reputation. Not nullable.
@export var construction_cost_modifier: float = 1.0             ## Multiplier for track build cost. Not nullable.
@export var maintenance_cost_modifier: float = 1.0              ## Multiplier for train upkeep. Not nullable.
@export var cargo_revenue_modifier: float = 1.0                 ## Multiplier for cargo sale revenue. Not nullable.
@export var unlock_condition: String = ""                       ## Optional. Campaign gate; empty = unlocked.
@export var is_playable: bool = true                            ## False for tutorial or special AI. Not nullable.
```

---

## ContractData

```gdscript
class_name ContractData extends Resource

@export var contract_id: String = ""                            ## Unique identifier (snake_case). Not nullable.
@export var display_name: String = ""                           ## Player-visible title. Not nullable.
@export var description: String = ""                            ## Journal / tooltip text. Optional.
@export var contract_type: String = "delivery"                  ## "delivery", "connect", "profit", "survive". Not nullable.
@export var cargo_id: String = ""                               ## Required cargo type (delivery only). Optional.
@export var origin_city_id: String = ""                         ## Specific origin (delivery only); empty = any origin. Optional.
@export var destination_city_id: String = ""                    ## Required destination city. Not nullable.
@export var quantity_required: int = 0                          ## Tons to deliver (delivery only). Optional.
@export var deadline_days: int = 0                              ## Days to complete from acceptance. Not nullable.
@export var reward_money: int = 0                               ## Money granted on success. Not nullable.
@export var reward_reputation: int = 0                          ## Reputation granted on success. Not nullable.
@export var failure_penalty_money: int = 0                      ## Money deducted on failure. Not nullable.
@export var failure_penalty_reputation: int = 0                 ## Reputation lost on failure. Not nullable.
@export var era_ids: PackedStringArray = []                     ## Eras in which this contract may appear. Optional.
@export var prerequisites: PackedStringArray = []               ## Contract IDs that must be completed first. Optional.
@export var is_repeatable: bool = false                         ## If true, re-enters pool after completion. Not nullable.
@export var difficulty_tier: int = 1                            ## Affects reward scaling and AI bidding weight. Not nullable.
```

---

## EventData

```gdscript
class_name EventData extends Resource

@export var event_id: String = ""                               ## Unique identifier (snake_case). Not nullable.
@export var display_name: String = ""                           ## Player-visible event title. Not nullable.
@export var description: String = ""                            ## Journal / tooltip text. Optional.
@export var era_ids: PackedStringArray = []                     ## Eras in which this event can fire. Optional.
@export var trigger_type: String = "random"                     ## "random", "scheduled", "threshold", "campaign". Not nullable.
@export var probability_weight: float = 1.0                     ## Relative weight for random trigger rolls. Not nullable.
@export var warning_days: int = 0                               ## Advance notice before effects begin. Not nullable.
@export var duration_days: int = 0                              ## How long effects last; 0 = instantaneous. Not nullable.
@export var min_year: int = 0                                   ## Earliest in-game year this can trigger. Not nullable.
@export var max_year: int = 9999                                ## Latest in-game year this can trigger. Not nullable.
@export var affected_region_id: String = ""                     ## Optional. Restrict to one region; empty = any.
@export var affected_city_id: String = ""                       ## Optional. Restrict to one city; empty = any.
@export var effects: Dictionary = {}                            ## Effect payload (schema varies by event type). Optional.
@export var counterplay_options: Array[Dictionary] = []         ## List of {id, label, cost, effect} choices. Optional.
@export var icon: Texture2D                                     ## Optional. Event UI icon.
```

---

## TechnologyData

```gdscript
class_name TechnologyData extends Resource

@export var tech_id: String = ""                                ## Unique identifier (snake_case). Not nullable.
@export var display_name: String = ""                           ## Player-visible name. Not nullable.
@export var description: String = ""                            ## Tooltip description. Optional.
@export var era_ids: PackedStringArray = []                     ## Eras in which this tech can appear. Optional.
@export var bonus_type: String = ""                             ## "speed", "bridge_cost", "purchase_cost", "load_speed", "hill_penalty". Not nullable.
@export var bonus_value: float = 0.0                            ## Numeric modifier (percentage or absolute). Not nullable.
@export var patent_duration_years: int = 5                      ## Years of exclusive use for auction winner. Not nullable.
@export var starting_bid: int = 5000                            ## Minimum opening bid at auction. Not nullable.
@export var icon: Texture2D                                     ## Optional. Tech UI icon.
@export var required_tech_id: String = ""                       ## Optional. Prerequisite tech ID; empty = none.
@export var is_unique: bool = true                              ## If false, all factions receive benefit after patent expiry. Not nullable.
```

---

## CampaignActData

```gdscript
class_name CampaignActData extends Resource

@export var act_id: String = ""                                 ## Unique identifier (snake_case). Not nullable.
@export var campaign_id: String = ""                            ## Parent campaign identifier. Not nullable.
@export var display_name: String = ""                           ## Player-visible act title. Not nullable.
@export var description: String = ""                            ## Briefing / journal text. Optional.
@export var act_index: int = 0                                  ## Order within campaign (0-based). Not nullable.
@export var era_id: String = ""                                 ## Era data for this act. Not nullable.
@export var map_region_id: String = ""                          ## Region loaded for this act. Not nullable.
@export var starting_treasury: int = 20000                      ## Player money at act start. Not nullable.
@export var starting_date: Dictionary = {"year":1857,"month":1,"day":1}  ## In-game start date. Not nullable.
@export var intro_text: String = ""                             ## Text shown on act start. Optional.
@export var objectives: Array[Dictionary] = []                  ## List of {id, type, target, quantity, deadline_days}. Optional.
@export var win_conditions: Array[Dictionary] = []              ## Conditions that trigger victory. Optional.
@export var lose_conditions: Array[Dictionary] = []             ## Conditions that trigger defeat. Optional.
@export var unlocked_trains: PackedStringArray = []             ## Train IDs available this act. Optional.
@export var unlocked_cargos: PackedStringArray = []             ## Cargo IDs available this act. Optional.
@export var unlocked_cities: PackedStringArray = []             ## City IDs initially visible. Optional.
@export var next_act_id: String = ""                            ## Act to load on completion; empty = campaign end. Optional.
@export var is_skippable: bool = false                          ## If true, player may skip to next act. Not nullable.
```

---

## SaveGameData

`SaveGameData` is **not** a `Resource`. It is a plain `RefCounted` container that the `SaveManager` serializes to JSON. Fields are plain `var` and are populated at runtime.

```gdscript
class_name SaveGameData extends RefCounted

var save_version: String = "0.1.0"                              ## Save format version for migration. Not nullable.
var campaign_id: String = ""                                    ## Current campaign identifier. Optional.
var act_id: String = ""                                         ## Current act identifier. Optional.
var current_date: Dictionary = {"year":1857,"month":1,"day":1}  ## In-game calendar state. Not nullable.
var game_speed: float = 1.0                                     ## Last active speed multiplier. Not nullable.
var player_faction_id: String = ""                              ## Human player's faction ID. Not nullable.
var faction_treasuries: Dictionary = {}                         ## faction_id -> money (int). Optional.
var faction_reputations: Dictionary = {}                        ## faction_id -> reputation (int). Optional.
var track_graph: Dictionary = {}                                ## {nodes: Dictionary, edges: Dictionary}. Not nullable.
var trains: Array[Dictionary] = []                              ## List of TrainState dictionaries. Optional.
var city_economies: Array[Dictionary] = []                      ## List of CityEconomyState dictionaries. Optional.
var active_contracts: Array[Dictionary] = []                    ## List of ContractState dictionaries. Optional.
var available_contracts: Array[String] = []                     ## ContractData IDs remaining in pool. Optional.
var technologies: Array[Dictionary] = []                        ## {tech_id, owner_faction_id, expiry_date}. Optional.
var active_events: Array[Dictionary] = []                       ## Active EventState dictionaries. Optional.
var event_history: Array[Dictionary] = []                       ## Completed events log. Optional.
var campaign_progress: Dictionary = {}                          ## Flags and counters. Optional.
var statistics: Dictionary = {}                                 ## Lifetime stats (tonnage, revenue, trips). Optional.
```
