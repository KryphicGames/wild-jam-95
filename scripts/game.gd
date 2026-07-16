extends Control

const HERO_SELECTION_SCENE := "res://scenes/hero_selection.tscn"
const EVENT_DRAW_ORIGIN := Vector2(1030, 70)
const OPTION_DRAW_ORIGIN := Vector2(1030, 520)
const OPTION_START_ROTATIONS := [-8.0, -2.0, 6.0]

@export var loggerPrefix = "Game"

@export var gold := 100
@export var greed := 0
@export var popularity := 50

@export var flags: Array = []

@export var current_hero: Dictionary = {}
@export var current_card: Dictionary = {}

@onready var hero_card_view: HeroCardView = $HeroCard
@onready var event_card_view: EventCardView = $EventCard
@onready var option_card_views: Array[OptionCardView] = [
	$LeftOption as OptionCardView,
	$MiddleOption as OptionCardView,
	$RightOption as OptionCardView
]
@onready var fade_rect: ColorRect = $Fade
@onready var fade_player: AnimationPlayer = $Fade/AnimationPlayer

var _dealing_cards := false


func _ready():
	randomize()
	fade_rect.show()
	fade_player.play("fade-in")
	_connect_option_cards()
	if !_initialize_hero():
		return
	hero_card_view.present(current_hero, gold, greed, popularity)
	CardLoader.load_cards()
	await next_card()


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


func next_card() -> void:
	_dealing_cards = true
	current_card = CardLoader.get_random_card(self)
	if current_card.is_empty():
		Log.Warn("No available cards.", loggerPrefix)
		event_card_view.show_empty_state()
		_clear_options()
		_dealing_cards = false
		return

	event_card_view.present(current_card)
	event_card_view.prepare_face_down(EVENT_DRAW_ORIGIN, 5.0)
	var options: Array = current_card.get("options", [])
	if options.size() != option_card_views.size():
		Log.Warn(
			"Event '" + str(current_card.get("id", "unknown")) + "' has "
			+ str(options.size()) + " options; the game displays "
			+ str(option_card_views.size()) + ".",
			loggerPrefix
		)
	for index in range(option_card_views.size()):
		if index >= options.size():
			option_card_views[index].clear_option()
			continue
		var option: Dictionary = options[index]
		var is_available := CardLoader.can_apply_effects(
			self,
			option.get("effects", {})
		)
		option_card_views[index].present(option, is_available)
		option_card_views[index].set_input_enabled(false)
		option_card_views[index].prepare_face_down(
			OPTION_DRAW_ORIGIN,
			OPTION_START_ROTATIONS[index]
		)

	Log.Info("", loggerPrefix)
	Log.Info("===== NEW CARD =====", loggerPrefix)
	Log.Info(current_card.title, loggerPrefix)
	Log.Info(current_card.get("description", ""), loggerPrefix)
	for option in options:
		Log.Info(option.id + " -> " + option.title, loggerPrefix)

	await event_card_view.draw_and_flip(0.48, 0.28)
	for index in range(min(options.size(), option_card_views.size())):
		await option_card_views[index].draw_and_flip(0.32, 0.24)

	_set_option_input_enabled(true)
	_dealing_cards = false


func choose(option_id: String) -> bool:
	if current_card.is_empty():
		return false

	for option in current_card.get("options", []):
		if option.id != option_id:
			continue
		if !CardLoader.can_apply_effects(self, option.effects):
			Log.Warn(
				"The player cannot afford option '" + option_id + "'.",
				loggerPrefix
			)
			_set_option_input_enabled(true)
			_dealing_cards = false
			return false
		CardLoader.apply_effects(self, option.effects)
		hero_card_view.refresh_stats(gold, greed, popularity)
		Log.Info("", loggerPrefix)
		Log.Info("Gold:" + str(gold), loggerPrefix)
		Log.Info("Greed:" + str(greed), loggerPrefix)
		Log.Info("Popularity:" + str(popularity), loggerPrefix)
		Log.Info("Flags:" + str(flags), loggerPrefix)
		await next_card()
		return true

	Log.Warn("Unknown option id '" + option_id + "'.", loggerPrefix)
	_set_option_input_enabled(true)
	_dealing_cards = false
	return false


func _connect_option_cards() -> void:
	for option_card_view in option_card_views:
		option_card_view.option_selected.connect(_on_option_selected)


func _on_option_selected(option_id: String) -> void:
	if _dealing_cards:
		return
	_dealing_cards = true
	_set_option_input_enabled(false)
	await choose(option_id)


func _set_option_input_enabled(enabled: bool) -> void:
	for option_card_view in option_card_views:
		option_card_view.set_input_enabled(enabled)


func _clear_options() -> void:
	for option_card_view in option_card_views:
		option_card_view.clear_option()
