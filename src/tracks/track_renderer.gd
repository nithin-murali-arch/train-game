class_name TrackRenderer
extends Node2D


@export var track_color: Color = Color("#3A3028")
@export var track_width: float = 2.5
@export var node_color: Color = Color("#5A4A3A")
@export var node_radius: float = 3.0

var _graph: TrackGraph
var _track_tex: Texture2D


func _ready() -> void:
	_track_tex = _try_load("res://assets/generated/track_segment.png")


func _try_load(path: String) -> Texture2D:
	var tex := load(path) as Texture2D
	return tex


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

		if _track_tex != null:
			var midpoint := from_world.lerp(to_world, 0.5)
			var angle := (to_world - from_world).angle()
			var tex_size := _track_tex.get_size()
			draw_set_transform(midpoint, angle, Vector2.ONE)
			draw_texture(_track_tex, -tex_size / 2.0)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# Draw node dots
	for node_coord in _graph.get_all_nodes():
		var world_pos := WorldMap.grid_to_world(node_coord)
		draw_circle(world_pos, node_radius, node_color)
