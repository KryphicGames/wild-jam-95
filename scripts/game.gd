extends Control

const HERO_SELECTION_SCENE := "res://scenes/hero_selection.tscn"

@export var loggerPrefix = "Game"

@export var gold := 100
@export var greed := 0
@export var popularity := 50

@export var flags: Array = []

@export var current_hero: Dictionary = {}
@export var current_card: Dictionary = {}


func _ready():
	randomize()
	if !_initialize_hero():
		return
	CardLoader.load_cards()
	next_card()


func _initialize_hero() -> bool:
	current_hero = HeroLoader.get_selected_hero()
	if current_hero.is_empty():
		Log.Error("The game cannot begin without a selected hero.", loggerPrefix)
		get_tree().call_deferred("change_scene_to_file", HERO_SELECTION_SCENE)
		return false

	gold = int(current_hero.starting_stats.gold)
	greed = int(current_hero.starting_stats.greed)
	popularity = int(current_hero.starting_stats.popularity)
	flags = current_hero.starting_flags.duplicate(true)
	Log.Info("Starting game as " + str(current_hero.title) + ".", loggerPrefix)
	return true


func next_card():
	current_card = CardLoader.get_random_card(self)
	if current_card.is_empty():
		Log.Warn("No available cards.", loggerPrefix)
		return
	Log.Info("", loggerPrefix)
	Log.Info("===== NEW CARD =====", loggerPrefix)
	Log.Info(current_card.title, loggerPrefix)
	Log.Info(current_card.description, loggerPrefix)
	for option in current_card.options:
		Log.Info(option.id + " -> " + option.title, loggerPrefix)


func choose(option_id: String):
	for option in current_card.options:
		if option.id != option_id:
			continue
		CardLoader.apply_effects(self, option.effects)
		Log.Info("", loggerPrefix)
		Log.Info("Gold:" + str(gold), loggerPrefix)
		Log.Info("Greed:" + str(greed), loggerPrefix)
		Log.Info("Popularity:" + str(popularity), loggerPrefix)
		Log.Info("Flags:" + str(flags), loggerPrefix)
		next_card()
		return
