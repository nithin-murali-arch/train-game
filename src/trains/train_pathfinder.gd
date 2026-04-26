class_name TrainPathfinder
extends RefCounted


var _graph: TrackGraph


func setup(graph: TrackGraph) -> void:
	_graph = graph


func find_path(start: Vector2i, end: Vector2i) -> TrackPathResult:
	var result := TrackPathResult.new()

	if _graph == null:
		result.error_message = "graph not set"
		return result

	if not _graph.has_node(start):
		result.error_message = "start node not in graph"
		return result

	if not _graph.has_node(end):
		result.error_message = "end node not in graph"
		return result

	return _graph.find_path(start, end)
