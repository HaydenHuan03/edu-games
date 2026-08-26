extends Node

var values = {}

func _ready():
	load_env("res://scripts/api/.env")

func load_env(path: String):
	if not FileAccess.file_exists(path):
		push_error("env not found, path: " + path)
		return

	var file = FileAccess.open(path, FileAccess.READ)
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line == "" or line.begins_with("#"):
			continue
		var parts = line.split("=", false, 1)
		if parts.size() == 2:
			var key = parts[0].strip_edges()
			var value = parts[1].strip_edges().trim_prefix('"').trim_suffix('"')
			values[key] = value
	file.close()

func get_value(key: String) -> String:
	return values.get(key, "")
