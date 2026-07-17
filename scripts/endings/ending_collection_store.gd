class_name EndingCollectionStore
extends RefCounted

const SAVE_PATH := "user://ending_collection.cfg"
const COLLECTION_SECTION := "endings"


func record_ending(ending_id: String) -> void:
	if ending_id.is_empty() || ending_id == "unwritten_legend":
		return
	var config := _load_collection()
	config.set_value(COLLECTION_SECTION, ending_id, true)
	var save_error := config.save(SAVE_PATH)
	if save_error != OK:
		Log.Error(
			"The ending collection could not be saved. Error: " + str(save_error),
			"EndingCollection"
		)


func is_discovered(ending_id: String) -> bool:
	return bool(_load_collection().get_value(COLLECTION_SECTION, ending_id, false))


func get_discovered_ending_ids() -> Array[String]:
	var discovered_ids: Array[String] = []
	var config := _load_collection()
	for ending_id in config.get_section_keys(COLLECTION_SECTION):
		if bool(config.get_value(COLLECTION_SECTION, ending_id, false)):
			discovered_ids.append(str(ending_id))
	return discovered_ids


func get_discovered_count(ending_definitions: Array[Dictionary]) -> int:
	var discovered_ids := get_discovered_ending_ids()
	var discovered_count := 0
	for ending in ending_definitions:
		if discovered_ids.has(str(ending.id)):
			discovered_count += 1
	return discovered_count


func _load_collection() -> ConfigFile:
	var config := ConfigFile.new()
	var load_error := config.load(SAVE_PATH)
	if load_error != OK && load_error != ERR_FILE_NOT_FOUND:
		Log.Warn(
			"The saved ending collection could not be read. Error: " + str(load_error),
			"EndingCollection"
		)
	return config
