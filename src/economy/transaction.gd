class_name Transaction
extends RefCounted


## Sells delivered cargo at fixed base price.
## Returns revenue amount (0 on failure).
static func sell_cargo(
	cargo_id: String,
	quantity: int,
	destination_city: CityRuntimeState,
	treasury: TreasuryState,
	cargo_catalog: Dictionary
) -> int:
	if quantity <= 0:
		return 0

	if not cargo_catalog.has(cargo_id):
		push_error("Transaction: cargo_id '%s' not found in catalog" % cargo_id)
		return 0

	var cargo: CargoData = cargo_catalog[cargo_id] as CargoData
	if cargo == null:
		push_error("Transaction: cargo data for '%s' is null" % cargo_id)
		return 0

	var revenue := int(roundf(float(quantity) * cargo.base_price))
	var ok := treasury.add(revenue)
	if not ok:
		push_error("Transaction: failed to add revenue to treasury")
		return 0

	return revenue


## Sells delivered cargo at dynamic city-specific price.
## Returns a result dictionary with full details.
static func sell_cargo_dynamic(
	cargo_id: String,
	quantity: int,
	destination_city: CityRuntimeState,
	destination_city_data: CityData,
	treasury: TreasuryState,
	cargo_catalog: Dictionary
) -> Dictionary:
	var result := {
		"success": false,
		"cargo_id": cargo_id,
		"quantity": quantity,
		"unit_price": 0.0,
		"revenue": 0,
		"error": "",
	}

	if quantity <= 0:
		result["error"] = "quantity must be positive"
		return result

	if not cargo_catalog.has(cargo_id):
		result["error"] = "cargo_id not found in catalog"
		return result

	var cargo: CargoData = cargo_catalog[cargo_id] as CargoData
	if cargo == null:
		result["error"] = "cargo data is null"
		return result

	var unit_price := MarketPricing.get_sell_price(cargo_id, destination_city, destination_city_data, cargo_catalog)
	if unit_price <= 0.0:
		result["error"] = "price calculation failed"
		return result

	var revenue := int(roundf(float(quantity) * unit_price))
	var ok := treasury.add(revenue)
	if not ok:
		result["error"] = "failed to add revenue to treasury"
		return result

	result["success"] = true
	result["unit_price"] = unit_price
	result["revenue"] = revenue
	return result
