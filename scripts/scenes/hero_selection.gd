extends Control

const HERO_COUNT := 3
const HERO_CHOICE_CARD := preload("res://components/hero_choice_card.tscn")
const GAME_SCENE := "res://scenes/game.tscn"
const MAIN_MENU_SCENE := "res://scenes/main_menu.tscn"

@export var logger_prefix := "HeroSelection"

@onready var choices_container: HBoxContainer = $Content/Layout/Cards/HeroChoices
@onready var status_label: Label = $Content/Layout/Status
@onready var back_button: Button = $Content/Layout/Header/Back
@onready var fade_rect: ColorRect = $Fade
@onready var fade_player: AnimationPlayer = $Fade/AnimationPlayer

var _choice_cards: Array[HeroChoiceCard] = []
var _selection_in_progress := false


func _ready() -> void:
	fade_rect.show()
	fade_player.play("fade-in")
	back_button.pressed.connect(_on_back_pressed)
	HeroLoader.clear_selection()

	if !HeroLoader.load_heroes():
		_show_error("No valid heroes could be loaded.")
		return

	var drawn_heroes := HeroLoader.draw_random_heroes(HERO_COUNT)
	if drawn_heroes.size() != HERO_COUNT:
		_show_error("At least three valid heroes are required to begin.")
		return

	for hero in drawn_heroes:
		var choice_card := HERO_CHOICE_CARD.instantiate() as HeroChoiceCard
		choices_container.add_child(choice_card)
		choice_card.present(hero)
		choice_card.hero_selected.connect(_on_hero_selected)
		_choice_cards.append(choice_card)


func _on_hero_selected(hero_id: String) -> void:
	if _selection_in_progress:
		return
	if !HeroLoader.select_hero(hero_id):
		_show_error("That hero could not be selected.")
		return

	_selection_in_progress = true
	_set_choices_enabled(false)
	back_button.disabled = true
	fade_rect.show()
	fade_player.play("fade-out")
	await fade_player.animation_finished
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_back_pressed() -> void:
	if _selection_in_progress:
		return
	_selection_in_progress = true
	HeroLoader.clear_selection()
	_set_choices_enabled(false)
	back_button.disabled = true
	fade_rect.show()
	fade_player.play("fade-out")
	await fade_player.animation_finished
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


func _set_choices_enabled(enabled: bool) -> void:
	for choice_card in _choice_cards:
		choice_card.set_selection_enabled(enabled)


func _show_error(message: String) -> void:
	Log.Error(message, logger_prefix)
	status_label.text = message
	status_label.show()
