class_name SaveSerializer
extends RefCounted


# ------------------------------------------------------------------------------
# Serialize: runtime state -> SaveGameData
# ------------------------------------------------------------------------------

static func serialize(route_toy: RouteToyPlayable) -> SaveGameData:
	var data := SaveGameData.new()
	data.save_version = SaveGameData.CURRENT_VERSION  # v2

	# Clock
	if route_toy.clock != null:
		data.current_day = route_toy.clock.current_day
		data.current_month = route_toy.clock.current_month
		data.current_year = route_toy.clock.current_year
		data.clock_is_paused = route_toy.clock.is_paused
		data.days_per_real_second = route_toy.clock.days_per_real_second

	# Treasury
	if route_toy.treasury != null:
		data.treasury_balance = route_toy.treasury.balance

	# Cities
	for city_id in route_toy.city_runtime.keys():
		var runtime: CityRuntimeState = route_toy.city_runtime[city_id]
		if runtime == null or runtime.inventory == null:
			continue
		var cargo_dict := {}
		for stack in runtime.inventory.stacks:
			cargo_dict[stack.cargo_id] = stack.quantity
		data.city_stocks[city_id] = cargo_dict

	# TrackGraph
	if route_toy.graph != null:
		for node in route_toy.graph.get_all_nodes():
			data.track_nodes.append({"x": node.x, "y": node.y})
		for edge in route_toy.graph.get_all_edges():
			data.track_edges.append({
				"from": {"x": edge.from_coord.x, "y": edge.from_coord.y},
				"to": {"x": edge.to_coord.x, "y": edge.to_coord.y},
				"owner_faction_id": edge.owner_faction_id,
				"length_km": edge.length_km,
				"condition": edge.condition,
				"toll_per_km": edge.toll_per_km,
				"access_mode": edge.access_mode,
				"is_blocked": edge.is_blocked,
			})

	# Trains (v2 array)
	for t in route_toy.owned_trains:
		if t == null:
			continue
		var t_data := {}
		t_data["train_id"] = t.train_id
		t_data["instance_id"] = t.instance_id
		var grid_coord := _get_train_grid_coord(t, route_toy)
		t_data["grid_coord"] = {"x": grid_coord.x, "y": grid_coord.y}
		var train_cargo: TrainCargo = t.get_train_cargo()
		var cargo_dict := {}
		if train_cargo != null and train_cargo.inventory != null:
			for stack in train_cargo.inventory.stacks:
				cargo_dict[stack.cargo_id] = stack.quantity
		t_data["cargo"] = cargo_dict
		data.trains.append(t_data)

	# Routes (v2 array)
	for i in range(route_toy.active_runners.size()):
		var r: RouteRunner = route_toy.active_runners[i]
		if r == null:
			continue
		var route_dict := {}
		var sched: RouteSchedule = r._schedule
		if sched != null:
			route_dict["schedule"] = {
				"instance_id": sched.instance_id,
				"assigned_train_instance_id": sched.assigned_train_instance_id,
				"route_id": sched.route_id,
				"origin_city_id": sched.origin_city_id,
				"destination_city_id": sched.destination_city_id,
				"cargo_id": sched.cargo_id,
				"loop_enabled": sched.loop_enabled,
				"return_empty": sched.return_empty,
			}
		else:
			route_dict["schedule"] = {}

		var stats: RouteProfitStats = r.get_stats()
		if stats != null:
			route_dict["stats"] = {
				"route_id": stats.route_id,
				"trips_completed": stats.trips_completed,
				"total_revenue": stats.total_revenue,
				"total_operating_cost": stats.total_operating_cost,
				"total_profit": stats.total_profit,
				"total_cargo_delivered": stats.total_cargo_delivered,
				"last_trip_revenue": stats.last_trip_revenue,
				"last_trip_operating_cost": stats.last_trip_operating_cost,
				"last_trip_profit": stats.last_trip_profit,
			}
		else:
			route_dict["stats"] = {}

		route_dict["runner_state"] = r.get_state_name()
		data.routes.append(route_dict)

	return data


# ------------------------------------------------------------------------------
# Deserialize: SaveGameData -> mutate RouteToyPlayable in-place
# ------------------------------------------------------------------------------

static func deserialize(data: SaveGameData, route_toy: RouteToyPlayable) -> bool:
	if data == null:
		push_error("SaveSerializer: null data")
		return false

	# Pause clock during restore
	if route_toy.clock != null:
		route_toy.clock.pause()

	# Clock
	if route_toy.clock != null:
		route_toy.clock.current_day = data.current_day
		route_toy.clock.current_month = data.current_month
		route_toy.clock.current_year = data.current_year
		route_toy.clock.is_paused = data.clock_is_paused
		route_toy.clock.days_per_real_second = data.days_per_real_second
		route_toy.clock._accumulator = 0.0

	# Treasury
	if route_toy.treasury != null:
		route_toy.treasury.balance = data.treasury_balance

	# Cities
	for city_id in data.city_stocks.keys():
		var runtime: CityRuntimeState = route_toy.city_runtime.get(city_id)
		if runtime == null or runtime.inventory == null:
			continue
		var cargo_dict: Dictionary = data.city_stocks[city_id]
		runtime.inventory.clear()
		for cargo_id in cargo_dict.keys():
			var qty: int = cargo_dict[cargo_id] as int
			if qty > 0:
				runtime.inventory.add_cargo(cargo_id, qty, route_toy.cargo_catalog)

	# TrackGraph
	if route_toy.graph != null:
		route_toy.graph.clear()
		for node_dict in data.track_nodes:
			var x: int = node_dict.get("x", 0) as int
			var y: int = node_dict.get("y", 0) as int
			route_toy.graph.add_node(Vector2i(x, y))
		for edge_dict in data.track_edges:
			var from_x: int = edge_dict["from"].get("x", 0) as int
			var from_y: int = edge_dict["from"].get("y", 0) as int
			var to_x: int = edge_dict["to"].get("x", 0) as int
			var to_y: int = edge_dict["to"].get("y", 0) as int
			route_toy.graph.add_edge(
				Vector2i(from_x, from_y),
				Vector2i(to_x, to_y),
				edge_dict.get("owner_faction_id", "player_railway_company") as String,
				edge_dict.get("condition", 1.0) as float,
				edge_dict.get("toll_per_km", 0.0) as float,
				edge_dict.get("access_mode", "private") as String,
				edge_dict.get("is_blocked", false) as bool,
			)

	# Rebuild renderer from restored graph
	if route_toy.renderer != null:
		route_toy.renderer.setup(route_toy.graph)

	# Clear old trains/runners
	for r in route_toy.active_runners:
		if r != null:
			r.stop_route()
			r.queue_free()
	route_toy.active_runners.clear()

	for t in route_toy.owned_trains:
		if t != null:
			if t.get_parent() != null:
				t.get_parent().remove_child(t)
			t.queue_free()
	route_toy.owned_trains.clear()

	# Deserialize trains — PASS 1: restore all trains, build instance_id map
	var train_data_list: Array[Dictionary] = []
	if data.save_version >= 2:
		train_data_list = data.trains
	# v1 fallback: if no trains array but has legacy train_id
	if train_data_list.is_empty() and not data.train_id.is_empty():
		train_data_list.append({
			"train_id": data.train_id,
			"grid_coord": data.train_grid_coord,
			"cargo": data.train_cargo,
		})

	var max_train_id: int = 0
	var migrated_train_counter: int = 1

	for t_dict in train_data_list:
		var t_id: String = t_dict.get("train_id", "") as String
		if t_id.is_empty():
			continue
		var t_data: TrainData = route_toy._catalog.get_train_by_id(t_id)
		if t_data == null:
			push_warning("SaveSerializer: unknown train_id '%s', skipping" % t_id)
			continue

		var pf := TrainPathfinder.new()
		pf.setup(route_toy.graph)

		var train_scene := preload("res://scenes/trains/train_entity.tscn")
		var t := train_scene.instantiate() as TrainEntity
		t.setup(t_data, pf)
		route_toy.world.add_child(t)

		var train_cargo: TrainCargo = t.get_train_cargo()
		if train_cargo != null:
			train_cargo.setup_from_train_data(t_data, route_toy.cargo_catalog)

		var grid_dict: Dictionary = t_dict.get("grid_coord", {"x": 0, "y": 0}) as Dictionary
		var grid := Vector2i(grid_dict.get("x", 0) as int, grid_dict.get("y", 0) as int)
		# Ensure grid is a valid node on the graph; fall back to origin if not
		if route_toy.graph != null and not route_toy.graph.has_node(grid):
			grid = route_toy.cities_grid.get("patna", Vector2i.ZERO)
		t.reset_to(grid)

		if train_cargo != null and train_cargo.inventory != null:
			train_cargo.inventory.clear()
			var cargo_dict: Dictionary = t_dict.get("cargo", {}) as Dictionary
			for cargo_id in cargo_dict.keys():
				var qty: int = cargo_dict[cargo_id] as int
				if qty > 0:
					train_cargo.load_cargo(cargo_id, qty)

		# Assign or migrate instance_id
		var inst_id: String = t_dict.get("instance_id", "") as String
		if inst_id.is_empty():
			inst_id = "train_migrated_%03d" % migrated_train_counter
			migrated_train_counter += 1
			t_dict["instance_id"] = inst_id
			t_dict["_was_migrated"] = true
		t.instance_id = inst_id
		route_toy.train_by_instance_id[inst_id] = t
		max_train_id = maxi(max_train_id, _extract_id_number(inst_id))

		route_toy.owned_trains.append(t)

	# Update counter so new trains don't collide with loaded ones
	if max_train_id > 0:
		route_toy._next_train_instance_id = max_train_id + 1

	# Deserialize routes — PASS 2: lookup train by assigned_train_instance_id
	var route_data_list: Array[Dictionary] = []
	if data.save_version >= 2:
		route_data_list = data.routes
	# v1 fallback: if no routes array but has legacy route_schedule
	if route_data_list.is_empty() and not data.route_schedule.is_empty():
		route_data_list.append({
			"schedule": data.route_schedule,
			"stats": data.route_stats,
			"runner_state": data.runner_state,
		})

	var max_route_id: int = 0
	var migrated_route_counter: int = 1

	for r_dict in route_data_list:
		var sched_dict: Dictionary = r_dict.get("schedule", {}) as Dictionary
		if sched_dict.is_empty():
			continue

		var origin_id: String = sched_dict.get("origin_city_id", "") as String
		var dest_id: String = sched_dict.get("destination_city_id", "") as String
		var cargo_id: String = sched_dict.get("cargo_id", "") as String

		if origin_id.is_empty() or dest_id.is_empty() or cargo_id.is_empty():
			continue

		if not route_toy.city_runtime.has(origin_id) or not route_toy.city_runtime.has(dest_id):
			push_warning("SaveSerializer: missing city runtime for '%s' or '%s', skipping route" % [origin_id, dest_id])
			continue

		if route_toy.owned_trains.is_empty():
			push_warning("SaveSerializer: no trains to assign route to, skipping route")
			continue

		# Resolve train assignment
		var assigned_train_id: String = sched_dict.get("assigned_train_instance_id", "") as String
		var t: TrainEntity = null
		if not assigned_train_id.is_empty():
			t = route_toy.train_by_instance_id.get(assigned_train_id, null) as TrainEntity
			if t == null:
				push_warning("SaveSerializer: assigned train '%s' not found, skipping route" % assigned_train_id)
				continue
		else:
			# v1 backward compat: fallback to first train with warning
			t = route_toy.owned_trains[0]
			assigned_train_id = t.instance_id
			push_warning("SaveSerializer: route missing assigned_train_instance_id, falling back to first train '%s' (v1 compat)" % assigned_train_id)

		var t_data: TrainData = t.train_data

		var new_schedule := RouteSchedule.new()
		# Assign or migrate instance_id
		var route_inst_id: String = sched_dict.get("instance_id", "") as String
		if route_inst_id.is_empty():
			route_inst_id = "route_migrated_%03d" % migrated_route_counter
			migrated_route_counter += 1
		new_schedule.instance_id = route_inst_id
		new_schedule.assigned_train_instance_id = assigned_train_id
		new_schedule.route_id = sched_dict.get("route_id", "") as String
		new_schedule.origin_city_id = origin_id
		new_schedule.destination_city_id = dest_id
		new_schedule.cargo_id = cargo_id
		new_schedule.loop_enabled = sched_dict.get("loop_enabled", true) as bool
		new_schedule.return_empty = sched_dict.get("return_empty", true) as bool

		var new_runner := RouteRunner.new()
		new_runner.setup(
			new_schedule,
			t,
			t_data,
			route_toy.graph,
			route_toy.city_runtime[origin_id],
			route_toy.city_runtime[dest_id],
			route_toy.city_data_by_id[origin_id],
			route_toy.city_data_by_id[dest_id],
			route_toy.treasury,
			route_toy.cargo_catalog
		)
		route_toy.add_child(new_runner)
		route_toy.active_runners.append(new_runner)
		route_toy.route_by_instance_id[route_inst_id] = new_runner
		max_route_id = maxi(max_route_id, _extract_id_number(route_inst_id))

		# Restore stats
		var stats_dict: Dictionary = r_dict.get("stats", {}) as Dictionary
		var stats: RouteProfitStats = new_runner.get_stats()
		if stats != null and not stats_dict.is_empty():
			stats.route_id = stats_dict.get("route_id", "") as String
			stats.trips_completed = stats_dict.get("trips_completed", 0) as int
			stats.total_revenue = stats_dict.get("total_revenue", 0) as int
			stats.total_operating_cost = stats_dict.get("total_operating_cost", 0) as int
			stats.total_profit = stats_dict.get("total_profit", 0) as int
			stats.total_cargo_delivered = stats_dict.get("total_cargo_delivered", 0) as int
			stats.last_trip_revenue = stats_dict.get("last_trip_revenue", 0) as int
			stats.last_trip_operating_cost = stats_dict.get("last_trip_operating_cost", 0) as int
			stats.last_trip_profit = stats_dict.get("last_trip_profit", 0) as int

		# Safe state restore
		var saved_state: String = r_dict.get("runner_state", "IDLE") as String
		if saved_state == "FAILED":
			new_runner.set_state_by_name("FAILED")
		else:
			new_runner.set_state_by_name("IDLE")

	# Update counter so new routes don't collide with loaded ones
	if max_route_id > 0:
		route_toy._next_route_instance_id = max_route_id + 1

	# Resume clock if it was running
	if route_toy.clock != null and not data.clock_is_paused:
		route_toy.clock.resume()

	return true


# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------

static func _extract_id_number(instance_id: String) -> int:
	# Extracts numeric suffix from strings like "train_001", "route_migrated_007"
	var parts: PackedStringArray = instance_id.split("_")
	if parts.size() >= 2:
		var last: String = parts[parts.size() - 1]
		if last.is_valid_int():
			return last.to_int()
	return 0


static func _get_train_grid_coord(train: TrainEntity, route_toy: RouteToyPlayable) -> Vector2i:
	# Prefer current movement coord if available
	if train._movement != null:
		var current: Vector2i = train._movement.get_current_coord()
		if current != Vector2i.ZERO:
			return current
	# Fallback: use world position to find nearest city grid
	var nearest := Vector2i.ZERO
	var best_dist := INF
	for city_id in route_toy.cities_grid.keys():
		var grid: Vector2i = route_toy.cities_grid[city_id]
		var dist := train.position.distance_to(WorldMap.grid_to_world(grid))
		if dist < best_dist:
			best_dist = dist
			nearest = grid
	return nearest
