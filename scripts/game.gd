extends Control

const HERO_SELECTION_SCENE := "res://scenes/hero_selection.tscn"
const MAIN_MENU_SCENE := "res://scenes/main_menu.tscn"
const CARD_TYPE_QUEST_END := "quest_end"
const CARD_DRAW_SFX := "res://assets/audio/sounds/cards/Card draw.wav"
const CARD_FLIP_SFX := "res://assets/audio/sounds/cards/Card Flip 1.wav"
const CHOICE_SFX := "res://assets/audio/sounds/ui/Choice selection.wav"
const FINALE_SFX := "res://assets/audio/sounds/outcomes/success_victory.wav"
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
@onready var legend_summary_view: LegendSummaryView = $LegendSummary
@onready var legend_traits_view: LegendTraitsView = $LegendTraits
@onready var deal_hint: Label = $DealHint

var _dealing_cards := false
var _deal_animation_in_progress := false
var _choice_history: Array[Dictionary] = []
var _legend_builder := LegendBuilder.new()
var _ending_collection := EndingCollectionStore.new()


func _ready():
	randomize()
	fade_rect.show()
	fade_player.play("fade-in")
	_connect_option_cards()
	legend_summary_view.play_again_requested.connect(_on_play_again_requested)
	legend_summary_view.main_menu_requested.connect(_on_main_menu_requested)
	if !_initialize_hero():
		return
	hero_card_view.present(current_hero, gold, greed, popularity)
	legend_traits_view.present(flags)
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
	_deal_animation_in_progress = true
	deal_hint.show()
	current_card = CardLoader.get_random_card(self)
	if current_card.is_empty():
		Log.Warn("No available cards.", loggerPrefix)
		event_card_view.show_empty_state()
		_clear_options()
		_dealing_cards = false
		_deal_animation_in_progress = false
		deal_hint.hide()
		return

	event_card_view.present(current_card)
	event_card_view.prepare_face_down(EVENT_DRAW_ORIGIN, 5.0)
	AudioManager.play(CARD_DRAW_SFX, AudioManager.Audio.UI, -12.0)
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
		var is_available := CardLoader.can_choose_option(self, option)
		var locked_reason := CardLoader.get_option_lock_reason(self, option)
		option_card_views[index].present(option, is_available, locked_reason)
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

	await event_card_view.draw_to_table(0.58)
	AudioManager.play(CARD_FLIP_SFX, AudioManager.Audio.UI, -10.0)
	await event_card_view.flip_to_front(0.38)
	for index in range(min(options.size(), option_card_views.size())):
		await option_card_views[index].draw_and_flip(0.38, 0.28)

	_set_option_input_enabled(true)
	_dealing_cards = false
	_deal_animation_in_progress = false
	deal_hint.hide()


func _input(event: InputEvent) -> void:
	if !_deal_animation_in_progress || legend_summary_view.visible:
		return
	var should_accelerate := event.is_action_pressed("ui_accept")
	if event is InputEventMouseButton:
		should_accelerate = should_accelerate || (
			event.button_index == MOUSE_BUTTON_LEFT && event.pressed
		)
	if !should_accelerate:
		return
	event_card_view.accelerate_animation()
	for option_card_view in option_card_views:
		option_card_view.accelerate_animation()
	deal_hint.hide()
	get_viewport().set_input_as_handled()


func choose(option_id: String) -> bool:
	if current_card.is_empty():
		return false

	var options: Array = current_card.get("options", [])
	for option_index in range(options.size()):
		var option: Dictionary = options[option_index]
		if option.id != option_id:
			continue
		if !CardLoader.can_choose_option(self, option):
			Log.Warn(
				"The player cannot choose option '" + option_id + "'.",
				loggerPrefix
			)
			_set_option_input_enabled(true)
			_dealing_cards = false
			return false
		var completed_finale := str(current_card.get("card_type", "")) == CARD_TYPE_QUEST_END
		_choice_history.append({
			"card_title": str(current_card.get("title", "Unknown Event")),
			"option_title": str(option.get("title", "Unknown Choice"))
		})
		AudioManager.play(CHOICE_SFX, AudioManager.Audio.UI, -12.0)
		CardLoader.apply_effects(self, option.effects)
		hero_card_view.refresh_stats(gold, greed, popularity)
		legend_traits_view.present(flags)
		for option_card_view in option_card_views:
			option_card_view.begin_dismiss()
		Log.Info("", loggerPrefix)
		Log.Info("Gold:" + str(gold), loggerPrefix)
		Log.Info("Greed:" + str(greed), loggerPrefix)
		Log.Info("Popularity:" + str(popularity), loggerPrefix)
		Log.Info("Flags:" + str(flags), loggerPrefix)
		await event_card_view.present_choice_result(option)
		if completed_finale:
			await get_tree().create_timer(0.3).timeout
			AudioManager.play(FINALE_SFX, AudioManager.Audio.UI, -8.0)
			_show_legend_summary()
			_dealing_cards = false
		else:
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


func _show_legend_summary() -> void:
	var summary := _legend_builder.build_summary(
		current_hero,
		gold,
		greed,
		popularity,
		flags,
		_choice_history
	)
	_ending_collection.record_ending(str(summary.ending_id))
	var ending_definitions := _legend_builder.get_ending_definitions()
	summary["collection_progress"] = (
		"Legends Discovered: "
		+ str(_ending_collection.get_discovered_count(ending_definitions))
		+ " / " + str(ending_definitions.size())
	)
	legend_summary_view.present(summary, current_hero)


func _on_play_again_requested() -> void:
	HeroLoader.clear_selection()
	get_tree().change_scene_to_file(HERO_SELECTION_SCENE)


func _on_main_menu_requested() -> void:
	HeroLoader.clear_selection()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
