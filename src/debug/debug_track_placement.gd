class_name DebugTrackPlacement
extends Node


func _ready() -> void:
	# Instance the existing Sprint 02 world scene
	var world := preload("res://scenes/world/world.tscn").instantiate()
	add_child(world)

	var world_map: WorldMap = world
	var camera: Camera2D = world_map.get_node("Camera2D")

	# Create TrackGraph
	var graph := TrackGraph.new()

	# Create renderer and add as child of WorldMap (shares world coordinate space)
	var renderer := TrackRenderer.new()
	renderer.setup(graph)
	world.add_child(renderer)

	# Create preview and add as child of WorldMap
	var preview := TrackPlacementPreview.new()
	world.add_child(preview)

	# Create placer
	var placer := TrackPlacer.new()
	placer.map_width = world_map._region.map_width
	placer.map_height = world_map._region.map_height
	placer.setup(graph, camera, preview, renderer)
	add_child(placer)

	print("TRACK PLACEMENT DEBUG SCENE READY")
	print("Controls:")
	print("  Left-click = select start / place edge")
	print("  Right-click = cancel")
	print("  Shift+left-click = remove nearest edge")
	print("  X = remove last placed edge")
	print("  Esc = cancel")
