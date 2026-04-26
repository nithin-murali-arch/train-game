class_name SaveLoadService
extends RefCounted


const SAVE_DIR := "user://saves"
const SAVE_FILE := "route_toy_save.json"


static func save_game(route_toy: RouteToyPlayable) -> bool:
	var data := SaveSerializer.serialize(route_toy)
	var json_str := data.to_json_string()

	var dir := DirAccess.open("user://")
	if dir == null:
		push_error("SaveLoadService: cannot open user directory")
		return false

	if not dir.dir_exists("saves"):
		var err := dir.make_dir("saves")
		if err != OK:
			push_error("SaveLoadService: cannot create saves directory")
			return false

	var path := SAVE_DIR.path_join(SAVE_FILE)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("SaveLoadService: cannot open file for writing: %s" % path)
		return false

	file.store_string(json_str)
	file.close()
	print("Game saved to %s" % path)
	return true


static func load_game(route_toy: RouteToyPlayable) -> bool:
	var path := SAVE_DIR.path_join(SAVE_FILE)
	if not FileAccess.file_exists(path):
		push_warning("SaveLoadService: no save file at %s" % path)
		return false

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("SaveLoadService: cannot open file for reading: %s" % path)
		return false

	var json_str := file.get_as_text()
	file.close()

	var data := SaveGameData.from_json_string(json_str)
	if data == null:
		push_error("SaveLoadService: failed to parse save data")
		return false

	# Support v1 and v2 saves
	if data.save_version > SaveGameData.CURRENT_VERSION:
		push_error("SaveLoadService: save version %d is newer than supported %d" % [data.save_version, SaveGameData.CURRENT_VERSION])
		return false
	if data.save_version < 1:
		push_error("SaveLoadService: invalid save version %d" % data.save_version)
		return false

	var ok := SaveSerializer.deserialize(data, route_toy)
	if ok:
		print("Game loaded from %s" % path)
	return ok


static func has_save() -> bool:
	var path := SAVE_DIR.path_join(SAVE_FILE)
	return FileAccess.file_exists(path)


static func delete_save() -> bool:
	var path := SAVE_DIR.path_join(SAVE_FILE)
	if FileAccess.file_exists(path):
		var err := DirAccess.remove_absolute(path)
		return err == OK
	return true
