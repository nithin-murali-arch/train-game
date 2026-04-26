# Rail Empire Architecture Rules

## Description
Use this skill whenever modifying Rail Empire systems.

## Architecture Invariants
- Static Resource `.tres` files are design data only.
- Runtime state must live in runtime objects.
- Use stable lowercase snake_case IDs for top-level resource relationships.
- Do not directly reference top-level `.tres` resources from other top-level `.tres` files.
- TrackGraph uses grid coordinates as source of truth.
- Visual Line2D/Polygon/Sprite nodes are never the source of gameplay truth.
- TrainMovement does not know about cargo, treasury, or pricing.
- TrackGraph does not know about cargo, trains, treasury, or economy.
- MarketPricing calculates prices and does not mutate stock.
- Transaction handles sales and treasury updates.
- RouteRunner coordinates route behavior but is not UI.
- HUD displays state and sends intent; it does not own simulation.

## Preferred Patterns
- RefCounted for data containers (TrackGraph, CityRuntimeState, TreasuryState, SaveGameData).
- Node for scene-tree entities (TrainEntity, RouteRunner, SimulationClock).
- CanvasLayer for HUD scenes.
- Signal-driven updates where possible; polling in `_process` only for values that change frequently.
- Untyped references across scene boundaries to avoid circular dependency parse errors.

## Forbidden Unless Explicitly Requested
- GameState singleton rewrite
- EventBus
- EconomyManager singleton
- SaveLoad autoload
- AI managers
- CampaignManager
- ScenarioManager
- Global service rewrites
- Multiplayer networking
