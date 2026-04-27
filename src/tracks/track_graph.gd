class_name TrackGraph
extends RefCounted


## node_key -> Vector2i
var _nodes: Dictionary = {}

## node_key -> { neighbor_key -> TrackEdgeData }
var _adjacency: Dictionary = {}


# ============================================================================
# Coordinate key helpers
# ============================================================================

static func _key(coord: Vector2i) -> String:
	return "%d,%d" % [coord.x, coord.y]


static func _from_key(key: String) -> Vector2i:
	var parts := key.split(",")
	return Vector2i(int(parts[0]), int(parts[1]))


# ============================================================================
# Node management
# ============================================================================

func clear() -> void:
	_nodes.clear()
	_adjacency.clear()


func add_node(coord: Vector2i) -> bool:
	var k := _key(coord)
	if _nodes.has(k):
		return false
	_nodes[k] = coord
	_adjacency[k] = {}
	return true


func has_node(coord: Vector2i) -> bool:
	return _nodes.has(_key(coord))


func remove_node(coord: Vector2i) -> bool:
	var k := _key(coord)
	if not _nodes.has(k):
		return false

	# Remove all edges connected to this node
	var neighbors := _get_neighbor_keys(k)
	for nk in neighbors:
		_remove_adjacency_entry(nk, k)

	_adjacency.erase(k)
	_nodes.erase(k)
	return true


func get_node_count() -> int:
	return _nodes.size()


func get_all_nodes() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for k in _nodes.keys():
		result.append(_nodes[k] as Vector2i)
	return result


# ============================================================================
# Edge management
# ============================================================================

func add_edge(
	from_coord: Vector2i,
	to_coord: Vector2i,
	owner_faction_id: String = "player_railway_company",
	condition: float = 1.0,
	toll_per_km: float = 0.0,
	access_mode: String = "private",
	is_blocked: bool = false
) -> bool:
	if from_coord == to_coord:
		return false

	var from_k := _key(from_coord)
	var to_k := _key(to_coord)

	# Idempotent: do not create duplicate
	if _has_adjacency_entry(from_k, to_k):
		return false

	# Auto-add missing nodes
	if not _nodes.has(from_k):
		add_node(from_coord)
	if not _nodes.has(to_k):
		add_node(to_coord)

	var length_km := from_coord.distance_to(to_coord)

	var edge := TrackEdgeData.new()
	edge.from_coord = from_coord
	edge.to_coord = to_coord
	edge.owner_faction_id = owner_faction_id
	edge.length_km = length_km
	edge.condition = condition
	edge.toll_per_km = toll_per_km
	edge.access_mode = access_mode
	edge.is_blocked = is_blocked

	(_adjacency[from_k] as Dictionary)[to_k] = edge
	(_adjacency[to_k] as Dictionary)[from_k] = edge

	return true


func has_edge(from_coord: Vector2i, to_coord: Vector2i) -> bool:
	return _has_adjacency_entry(_key(from_coord), _key(to_coord))


func remove_edge(from_coord: Vector2i, to_coord: Vector2i) -> bool:
	var from_k := _key(from_coord)
	var to_k := _key(to_coord)
	if not _has_adjacency_entry(from_k, to_k):
		return false
	_remove_adjacency_entry(from_k, to_k)
	_remove_adjacency_entry(to_k, from_k)
	return true


func get_edge(from_coord: Vector2i, to_coord: Vector2i) -> TrackEdgeData:
	var from_k := _key(from_coord)
	var to_k := _key(to_coord)
	if not _adjacency.has(from_k):
		return null
	var neighbors: Dictionary = _adjacency[from_k]
	return neighbors.get(to_k, null) as TrackEdgeData


func get_neighbors(coord: Vector2i) -> Array[Vector2i]:
	var k := _key(coord)
	var result: Array[Vector2i] = []
	if not _adjacency.has(k):
		return result
	var neighbors: Dictionary = _adjacency[k]
	for nk in neighbors.keys():
		result.append(_from_key(nk))
	return result


func get_edge_count() -> int:
	var count := 0
	var seen := {}
	for node_k in _adjacency.keys():
		var neighbors: Dictionary = _adjacency[node_k]
		for neighbor_k in neighbors.keys():
			var pair: String = node_k + "|" + neighbor_k
			var reverse: String = neighbor_k + "|" + node_k
			if seen.has(reverse):
				continue
			seen[pair] = true
			count += 1
	return count


func get_all_edges() -> Array[TrackEdgeData]:
	var result: Array[TrackEdgeData] = []
	var seen := {}
	for node_k in _adjacency.keys():
		var neighbors: Dictionary = _adjacency[node_k]
		for neighbor_k in neighbors.keys():
			var pair: String = node_k + "|" + neighbor_k
			var reverse: String = neighbor_k + "|" + node_k
			if seen.has(reverse):
				continue
			seen[pair] = true
			result.append(neighbors[neighbor_k] as TrackEdgeData)
	return result


# ============================================================================
# Pathfinding (A*)
# ============================================================================

func find_path(from_coord: Vector2i, to_coord: Vector2i, faction_id: String = "") -> TrackPathResult:
	var result := TrackPathResult.new()

	# Self-path
	if from_coord == to_coord:
		if not has_node(from_coord):
			result.error_message = "start node missing"
			return result
		result.success = true
		result.coords = [from_coord]
		result.total_length_km = 0.0
		result.total_cost = 0.0
		return result

	var start_k := _key(from_coord)
	var goal_k := _key(to_coord)

	if not _nodes.has(start_k):
		result.error_message = "start node missing"
		return result
	if not _nodes.has(goal_k):
		result.error_message = "end node missing"
		return result

	# A* structures
	var open_set: Array[String] = [start_k]
	var came_from: Dictionary = {}
	var g_score: Dictionary = { start_k: 0.0 }
	var f_score: Dictionary = { start_k: _heuristic(from_coord, to_coord) }

	while not open_set.is_empty():
		# Find node in open_set with lowest f_score
		var current_k := open_set[0]
		var current_f: float = f_score.get(current_k, INF)
		for k in open_set:
			var f: float = f_score.get(k, INF)
			if f < current_f:
				current_f = f
				current_k = k

		if current_k == goal_k:
			_reconstruct_path(result, came_from, current_k, from_coord)
			return result

		open_set.erase(current_k)

		var current_coord: Vector2i = _nodes[current_k]
		var neighbors: Dictionary = _adjacency[current_k]

		for neighbor_k in neighbors.keys():
			var edge: TrackEdgeData = neighbors[neighbor_k] as TrackEdgeData

			# Skip blocked or destroyed edges
			if edge.is_blocked or edge.condition <= 0.0:
				continue

			# Skip edges the faction cannot use
			if not faction_id.is_empty():
				if edge.access_mode == "private" and edge.owner_faction_id != faction_id:
					continue
				if edge.access_mode == "restricted":
					continue

			var edge_cost := edge.length_km / maxf(edge.condition, 0.1)
			var tentative_g: float = (g_score.get(current_k, INF) as float) + edge_cost

			if tentative_g < g_score.get(neighbor_k, INF):
				came_from[neighbor_k] = current_k
				g_score[neighbor_k] = tentative_g
				var neighbor_coord: Vector2i = _nodes[neighbor_k]
				f_score[neighbor_k] = tentative_g + _heuristic(neighbor_coord, to_coord)
				if not open_set.has(neighbor_k):
					open_set.append(neighbor_k)

	result.error_message = "no path exists"
	return result


static func _heuristic(a: Vector2i, b: Vector2i) -> float:
	return a.distance_to(b)


func _reconstruct_path(result: TrackPathResult, came_from: Dictionary, current_k: String, start_coord: Vector2i) -> void:
	var path_keys: Array[String] = [current_k]
	while came_from.has(current_k):
		current_k = came_from[current_k]
		path_keys.append(current_k)
	path_keys.reverse()

	var total_length := 0.0
	var total_cost := 0.0
	var coords: Array[Vector2i] = []

	for k in path_keys:
		coords.append(_from_key(k))

	for i in range(path_keys.size() - 1):
		var edge := get_edge(_from_key(path_keys[i]), _from_key(path_keys[i + 1]))
		if edge != null:
			total_length += edge.length_km
			total_cost += edge.length_km / maxf(edge.condition, 0.1)

	result.success = true
	result.coords = coords
	result.total_length_km = total_length
	result.total_cost = total_cost


# ============================================================================
# Path helpers
# ============================================================================

func get_edges_between(coords: Array[Vector2i]) -> Array[TrackEdgeData]:
	var result: Array[TrackEdgeData] = []
	for i in range(coords.size() - 1):
		var edge := get_edge(coords[i], coords[i + 1])
		if edge != null:
			result.append(edge)
	return result


func calculate_path_toll(path_coords: Array[Vector2i], faction_id: String) -> int:
	var total_toll := 0.0
	var edges := get_edges_between(path_coords)
	for edge in edges:
		if edge.owner_faction_id != faction_id and edge.access_mode == "open":
			total_toll += edge.length_km * edge.toll_per_km
	return int(total_toll)


# ============================================================================
# Validation
# ============================================================================

func validate() -> Array[String]:
	var errors: Array[String] = []

	# Check for self-loop edges
	for node_k in _adjacency.keys():
		var neighbors: Dictionary = _adjacency[node_k]
		if neighbors.has(node_k):
			errors.append("self-loop at %s" % node_k)

	# Check reverse counterpart exists for every adjacency entry
	for node_k in _adjacency.keys():
		var neighbors: Dictionary = _adjacency[node_k]
		for neighbor_k in neighbors.keys():
			if not _has_adjacency_entry(neighbor_k, node_k):
				errors.append("missing reverse edge: %s -> %s" % [node_k, neighbor_k])

	# Check edge metadata validates
	for edge in get_all_edges():
		var edge_errors := edge.validate()
		for err in edge_errors:
			errors.append("edge[%s|%s]: %s" % [_key(edge.from_coord), _key(edge.to_coord), err])

	# Check for orphaned adjacency entries (edges to removed nodes)
	for node_k in _adjacency.keys():
		if not _nodes.has(node_k):
			errors.append("orphaned adjacency for missing node %s" % node_k)
			continue
		var neighbors: Dictionary = _adjacency[node_k]
		for neighbor_k in neighbors.keys():
			if not _nodes.has(neighbor_k):
				errors.append("orphaned edge: %s -> %s (missing node)" % [node_k, neighbor_k])

	# Edge count consistency
	var counted := get_edge_count()
	var adjacency_entries := 0
	for node_k in _adjacency.keys():
		adjacency_entries += (_adjacency[node_k] as Dictionary).size()
	if adjacency_entries != counted * 2:
		errors.append("edge count inconsistent: %d unique vs %d adjacency entries" % [counted, adjacency_entries])

	return errors


# ============================================================================
# Internal helpers
# ============================================================================

func _has_adjacency_entry(from_k: String, to_k: String) -> bool:
	if not _adjacency.has(from_k):
		return false
	var neighbors: Dictionary = _adjacency[from_k]
	return neighbors.has(to_k)


func _remove_adjacency_entry(from_k: String, to_k: String) -> void:
	if not _adjacency.has(from_k):
		return
	var neighbors: Dictionary = _adjacency[from_k]
	neighbors.erase(to_k)


func _get_neighbor_keys(node_k: String) -> Array[String]:
	if not _adjacency.has(node_k):
		return []
	var neighbors: Dictionary = _adjacency[node_k]
	var result: Array[String] = []
	for nk in neighbors.keys():
		result.append(nk)
	return result
