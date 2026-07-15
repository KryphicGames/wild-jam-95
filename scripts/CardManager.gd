extends Node

@export var loggerPrefix = "CardLoader"
var cards: Array = []


func load_cards():
	cards.clear()
	var dir := DirAccess.open("res://cards")
	if dir == null:
		Log.Error("Couldn't open res://cards/", loggerPrefix)
		return
	dir.list_dir_begin()
	while true:
		var file := dir.get_next()
		if file == "":
			break
		if dir.current_is_dir():
			continue
		if !file.ends_with(".json"):
			continue
		var path := "res://cards/" + file
		var text := FileAccess.get_file_as_string(path)
		var json := JSON.new()
		if json.parse(text) != OK:
			Log.Errpr("Invalid JSON: " + path, loggerPrefix)
			continue
		cards.append(json.data)
	dir.list_dir_end()

	Log.Info("Loaded " + str(cards.size()) + " cards.", loggerPrefix)


func get_random_card(game) -> Dictionary:
	var available: Array = []
	for card in cards:
		if can_trigger(game, card):
			available.append(card)
	if available.is_empty():
		return {}
	return available.pick_random()


func can_trigger(game, card: Dictionary) -> bool:
	if !card.has("trigger"):
		return true
	var trigger = card.trigger
	if trigger.has("flags"):
		for flag in trigger.flags:
			if !game.flags.has(flag):
				return false
	if trigger.has("not_flags"):
		for flag in trigger.not_flags:
			if game.flags.has(flag):
				return false
	if trigger.has("stats"):
		for stat in trigger.stats.keys():
			if !game.has_method("get"):
				continue
			var value = game.get(stat)
			if trigger.stats[stat].has("min"):
				if value < trigger.stats[stat].min:
					return false
			if trigger.stats[stat].has("max"):
				if value > trigger.stats[stat].max:
					return false
	return true

func apply_effects(game, effects: Dictionary):
	for key in effects.keys():
		match key:
			"add_flags":
				for flag in effects[key]:
					if !game.flags.has(flag):
						game.flags.append(flag)
			"remove_flags":
				for flag in effects[key]:
					game.flags.erase(flag)
			_:
				game.set(
					key,
					game.get(key) + effects[key]
				)
