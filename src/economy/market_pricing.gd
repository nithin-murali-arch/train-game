class_name MarketPricing
extends RefCounted


## Calculates city-specific sale price for a cargo using runtime stock.
## Price is based on shortage/oversupply relative to target_stock.
## multiplier = clamp(1.0 + shortage_ratio * elasticity, 0.5, 2.0)
static func get_sell_price(
	cargo_id: String,
	city_runtime: CityRuntimeState,
	city_data: CityData,
	cargo_catalog: Dictionary
) -> float:
	if not cargo_catalog.has(cargo_id):
		return 0.0

	var cargo: CargoData = cargo_catalog[cargo_id] as CargoData
	if cargo == null:
		return 0.0

	var base_price: float = cargo.base_price
	var current_stock: int = city_runtime.get_quantity(cargo_id)

	var profile: CityCargoProfileData = _find_profile(city_data, cargo_id)
	if profile == null:
		return base_price

	var target_stock: int = maxi(profile.target_stock, 1)
	var elasticity: float = profile.price_elasticity
	var shortage_ratio: float = float(target_stock - current_stock) / float(target_stock)
	var raw_multiplier: float = 1.0 + (shortage_ratio * elasticity)
	var multiplier: float = clampf(raw_multiplier, 0.5, 2.0)

	return base_price * multiplier


static func _find_profile(city_data: CityData, cargo_id: String) -> CityCargoProfileData:
	for profile in city_data.cargo_profiles:
		if profile != null and profile.cargo_id == cargo_id:
			return profile
	return null
