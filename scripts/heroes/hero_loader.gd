extends Node

const HERO_DIRECTORY := "res://heroes"
const REQUIRED_FIELDS := [
	"id",
	"title",
	"description",
	"image",
	"starting_stats",
	"starting_flags"
]
const REQUIRED_STATS := ["gold", "greed", "popularity"]

@export var logger_prefix := "HeroLoader"

var heroes: Array[Dictionary] = []
var selected_hero: Dictionary = {}

var _random := RandomNumberGenerator.new()
var _drawn_heroes: Array[Dictionary] = []


func _ready() -> void:
	_random.randomize()


func load_heroes() -> bool:
	heroes.clear()
	_drawn_heroes.clear()

	var directory := DirAccess.open(HERO_DIRECTORY)
	if directory == null:
		Log.Error("Couldn't open " + HERO_DIRECTORY + "/", logger_prefix)
		return false

	var file_names: Array[String] = []
	directory.list_dir_begin()
	while true:
		var file_name := directory.get_next()
		if file_name.is_empty():
			break
		if directory.current_is_dir() || !file_name.ends_with(".json"):
			continue
		file_names.append(file_name)
	directory.list_dir_end()
	file_names.sort()

	var loaded_ids: Dictionary = {}
	for file_name in file_names:
		var path := HERO_DIRECTORY + "/" + file_name
		var hero := _load_hero(path)
		if hero.is_empty():
			continue

		var hero_id: String = hero.id
		if loaded_ids.has(hero_id):
			Log.Error("Duplicate hero id '" + hero_id + "' in " + path, logger_prefix)
			continue

		loaded_ids[hero_id] = true
		heroes.append(hero)

	Log.Info("Loaded " + str(heroes.size()) + " heroes.", logger_prefix)
	return !heroes.is_empty()


func draw_random_heroes(count: int = 3) -> Array[Dictionary]:
	var drawn_heroes: Array[Dictionary] = []
	_drawn_heroes.clear()
	if count <= 0:
		Log.Error("Hero draw count must be greater than zero.", logger_prefix)
		return drawn_heroes
	if heroes.size() < count:
		Log.Error(
			"Cannot draw " + str(count) + " unique heroes; only "
			+ str(heroes.size()) + " valid heroes are loaded.",
			logger_prefix
		)
		return drawn_heroes

	var candidates: Array[Dictionary] = []
	for hero in heroes:
		candidates.append(hero.duplicate(true))
	for index in range(candidates.size() - 1, 0, -1):
		var swap_index := _random.randi_range(0, index)
		var candidate := candidates[index]
		candidates[index] = candidates[swap_index]
		candidates[swap_index] = candidate

	for index in range(count):
		var hero: Dictionary = candidates[index].duplicate(true)
		_drawn_heroes.append(hero)
		drawn_heroes.append(hero.duplicate(true))
	return drawn_heroes


func select_hero(hero_id: String) -> bool:
	if !selected_hero.is_empty():
		Log.Warn("A hero has already been selected for this run.", logger_prefix)
		return false

	for hero in _drawn_heroes:
		if hero.id != hero_id:
			continue
		selected_hero = hero.duplicate(true)
		Log.Info("Selected hero: " + str(selected_hero.title), logger_prefix)
		return true

	Log.Error("Cannot select hero id '" + hero_id + "' because it was not drawn.", logger_prefix)
	return false


func get_selected_hero() -> Dictionary:
	return selected_hero.duplicate(true)


func clear_selection() -> void:
	selected_hero.clear()
	_drawn_heroes.clear()


func _load_hero(path: String) -> Dictionary:
	var text := FileAccess.get_file_as_string(path)
	var json := JSON.new()
	if json.parse(text) != OK:
		Log.Error(
			"Invalid JSON in " + path + " at line " + str(json.get_error_line())
			+ ": " + json.get_error_message(),
			logger_prefix
		)
		return {}
	if typeof(json.data) != TYPE_DICTIONARY:
		Log.Error("Hero file must contain a JSON object: " + path, logger_prefix)
		return {}

	var hero: Dictionary = json.data
	if !_is_valid_hero(hero, path):
		return {}
	return hero.duplicate(true)


func _is_valid_hero(hero: Dictionary, path: String) -> bool:
	for field in REQUIRED_FIELDS:
		if !hero.has(field):
			Log.Error("Missing hero field '" + field + "' in " + path, logger_prefix)
			return false

	if typeof(hero.id) != TYPE_STRING || hero.id.strip_edges().is_empty():
		Log.Error("Hero id must be a non-empty string in " + path, logger_prefix)
		return false
	var valid_id_characters := "abcdefghijklmnopqrstuvwxyz0123456789_"
	for character in hero.id:
		if !valid_id_characters.contains(character):
			Log.Error(
				"Hero id may only contain lowercase letters, numbers, and underscores in " + path,
				logger_prefix
			)
			return false
	if typeof(hero.title) != TYPE_STRING || hero.title.strip_edges().is_empty():
		Log.Error("Hero title must be a non-empty string in " + path, logger_prefix)
		return false
	if typeof(hero.description) != TYPE_STRING || hero.description.strip_edges().is_empty():
		Log.Error("Hero description must be a non-empty string in " + path, logger_prefix)
		return false
	if typeof(hero.image) != TYPE_STRING:
		Log.Error("Hero image must be a string in " + path, logger_prefix)
		return false
	if !hero.image.is_empty() && !ResourceLoader.exists(hero.image):
		Log.Error("Hero image does not exist: " + str(hero.image), logger_prefix)
		return false

	if typeof(hero.starting_stats) != TYPE_DICTIONARY:
		Log.Error("Hero starting_stats must be an object in " + path, logger_prefix)
		return false
	for stat in REQUIRED_STATS:
		if !hero.starting_stats.has(stat):
			Log.Error("Missing starting stat '" + stat + "' in " + path, logger_prefix)
			return false
		var value = hero.starting_stats[stat]
		if typeof(value) != TYPE_INT && typeof(value) != TYPE_FLOAT:
			Log.Error("Starting stat '" + stat + "' must be numeric in " + path, logger_prefix)
			return false

	if typeof(hero.starting_flags) != TYPE_ARRAY:
		Log.Error("Hero starting_flags must be an array in " + path, logger_prefix)
		return false
	for flag in hero.starting_flags:
		if typeof(flag) != TYPE_STRING || flag.strip_edges().is_empty():
			Log.Error("Hero flags must be non-empty strings in " + path, logger_prefix)
			return false

	return true
