extends Node

const ACTIVE_QUEST_FLAG := "active_quest"
const CARD_TYPE_STANDALONE := "standalone"
const CARD_TYPE_QUEST_START := "quest_start"
const CARD_TYPE_QUEST_STEP := "quest_step"
const CARD_TYPE_QUEST_END := "quest_end"
const SUPPORTED_CARD_TYPES := [
	CARD_TYPE_STANDALONE,
	CARD_TYPE_QUEST_START,
	CARD_TYPE_QUEST_STEP,
	CARD_TYPE_QUEST_END
]
const SPENDABLE_EFFECT_KEYS := ["gold"]

@export var loggerPrefix = "CardLoader"
var cards: Array = []
var used_cards: Array = []


func load_cards():
	cards.clear()
	used_cards.clear()
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
			Log.Error("Invalid JSON: " + path, loggerPrefix)
			continue
		if typeof(json.data) != TYPE_DICTIONARY:
			Log.Error("Card file must contain a JSON object: " + path, loggerPrefix)
			continue
		var card: Dictionary = json.data
		if !_has_valid_card_type(card, path):
			continue
		if !_has_valid_callback_variants(card, path):
			continue
		cards.append(card)
	dir.list_dir_end()

	Log.Info("Loaded " + str(cards.size()) + " cards.", loggerPrefix)


func get_random_card(game) -> Dictionary:
	var available := []
	for card in cards:
		if used_cards.has(card.id) && !card.repeatable:
			continue
		if can_trigger(game, card):
			available.append(card)
	if available.is_empty():
		return {}
	var chosen: Dictionary = available.pick_random()
	used_cards.append(chosen.id)
	return _resolve_card_variant(game, chosen)


func can_trigger(game, card: Dictionary) -> bool:
	if !_can_draw_card_type(game, str(card.card_type)):
		return false
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
	if trigger.has("any_flags"):
		var found_matching_flag := false
		for flag in trigger.any_flags:
			if game.flags.has(flag):
				found_matching_flag = true
				break
		if !found_matching_flag:
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


func _resolve_card_variant(game, card: Dictionary) -> Dictionary:
	var resolved_card := card.duplicate(true)
	if !card.has("variants") || typeof(card.variants) != TYPE_DICTIONARY:
		return resolved_card

	for required_flag in card.variants:
		if !game.flags.has(required_flag):
			continue
		var variant: Dictionary = card.variants[required_flag]
		for field in variant:
			resolved_card[field] = variant[field]
		resolved_card.erase("variants")
		return resolved_card
	return resolved_card


func _has_valid_card_type(card: Dictionary, path: String) -> bool:
	if !card.has("card_type") || typeof(card.card_type) != TYPE_STRING:
		Log.Error("Card must define a string card_type: " + path, loggerPrefix)
		return false
	if !SUPPORTED_CARD_TYPES.has(card.card_type):
		Log.Error("Unsupported card_type '" + str(card.card_type) + "' in " + path, loggerPrefix)
		return false
	return true


func _has_valid_callback_variants(card: Dictionary, path: String) -> bool:
	if !card.has("variants"):
		return true
	if typeof(card.variants) != TYPE_DICTIONARY:
		Log.Error("Card variants must be an object: " + path, loggerPrefix)
		return false
	if !card.has("trigger") || !card.trigger.has("any_flags"):
		Log.Error("Card variants require trigger.any_flags: " + path, loggerPrefix)
		return false
	if typeof(card.trigger.any_flags) != TYPE_ARRAY || card.trigger.any_flags.is_empty():
		Log.Error("Card trigger.any_flags must be a non-empty array: " + path, loggerPrefix)
		return false

	for required_flag in card.trigger.any_flags:
		if typeof(required_flag) != TYPE_STRING || required_flag.is_empty():
			Log.Error("Card trigger.any_flags entries must be strings: " + path, loggerPrefix)
			return false
		if !card.variants.has(required_flag):
			Log.Error("Missing card variant for flag '" + required_flag + "': " + path, loggerPrefix)
			return false
		if typeof(card.variants[required_flag]) != TYPE_DICTIONARY:
			Log.Error("Card variant '" + required_flag + "' must be an object: " + path, loggerPrefix)
			return false
	return true


func _can_draw_card_type(game, card_type: String) -> bool:
	var quest_is_active: bool = game.flags.has(ACTIVE_QUEST_FLAG)
	match card_type:
		CARD_TYPE_QUEST_START:
			return !quest_is_active
		CARD_TYPE_QUEST_STEP, CARD_TYPE_QUEST_END:
			return quest_is_active
		_:
			return true


func can_apply_effects(game, effects: Dictionary) -> bool:
	for stat_name in SPENDABLE_EFFECT_KEYS:
		var change := int(effects.get(stat_name, 0))
		if change >= 0:
			continue
		if int(game.get(stat_name)) < abs(change):
			return false
	return true


func can_choose_option(game, option: Dictionary) -> bool:
	if !can_apply_effects(game, option.get("effects", {})):
		return false
	return _meets_option_requirements(game, option.get("requirements", {}))


func get_option_lock_reason(game, option: Dictionary) -> String:
	if !can_apply_effects(game, option.get("effects", {})):
		return "You do not have enough Gold to choose this."
	if !_meets_option_requirements(game, option.get("requirements", {})):
		return str(option.get(
			"locked_reason",
			"Your earlier decisions did not prepare this path."
		))
	return ""


func _meets_option_requirements(game, requirements: Dictionary) -> bool:
	for flag in requirements.get("flags", []):
		if !game.flags.has(flag):
			return false
	for flag in requirements.get("not_flags", []):
		if game.flags.has(flag):
			return false

	var any_flags: Array = requirements.get("any_flags", [])
	if !any_flags.is_empty():
		var matched_flag := false
		for flag in any_flags:
			if game.flags.has(flag):
				matched_flag = true
				break
		if !matched_flag:
			return false

	var stats: Dictionary = requirements.get("stats", {})
	for stat_name in stats:
		var value = game.get(stat_name)
		if stats[stat_name].has("min") && value < stats[stat_name].min:
			return false
		if stats[stat_name].has("max") && value > stats[stat_name].max:
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
