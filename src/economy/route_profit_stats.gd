class_name RouteProfitStats
extends RefCounted


var route_id: String = ""
var trips_completed: int = 0
var total_revenue: int = 0
var total_operating_cost: int = 0
var total_profit: int = 0
var total_cargo_delivered: int = 0

var last_trip_quantity: int = 0
var last_trip_revenue: int = 0
var last_trip_operating_cost: int = 0
var last_trip_profit: int = 0


func record_trip(quantity: int, revenue: int, operating_cost: int) -> void:
	trips_completed += 1
	total_cargo_delivered += quantity
	total_revenue += revenue
	total_operating_cost += operating_cost
	total_profit += revenue - operating_cost

	last_trip_quantity = quantity
	last_trip_revenue = revenue
	last_trip_operating_cost = operating_cost
	last_trip_profit = revenue - operating_cost


func reset() -> void:
	trips_completed = 0
	total_revenue = 0
	total_operating_cost = 0
	total_profit = 0
	total_cargo_delivered = 0
	last_trip_quantity = 0
	last_trip_revenue = 0
	last_trip_operating_cost = 0
	last_trip_profit = 0
