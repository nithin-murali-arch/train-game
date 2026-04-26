class_name TrackRenderer
extends Node2D


@export var track_color: Color = Color("#3A3028")
@export var track_width: float = 2.5
@export var node_color: Color = Color("#5A4A3A")
@export var node_radius: float = 3.0

var _graph: TrackGraph


func setup(graph: TrackGraph) -> void:
	_graph = graph


func _draw() -> void:
	if _graph == null:
		return

	# Draw edges
	for edge in _graph.get_all_edges():
		var from_world := WorldMap.grid_to_world(edge.from_coord)
		var to_world := WorldMap.grid_to_world(edge.to_coord)
		draw_line(from_world, to_world, track_color, track_width, true)

	# Draw node dots
	for node_coord in _graph.get_all_nodes():
		var world_pos := WorldMap.grid_to_world(node_coord)
		draw_circle(world_pos, node_radius, node_color)
