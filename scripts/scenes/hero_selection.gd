extends Control

const HERO_COUNT := 3
const HERO_CHOICE_CARD := preload("res://components/hero_choice_card.tscn")
const GAME_SCENE := "res://scenes/game.tscn"
const MAIN_MENU_SCENE := "res://scenes/main_menu.tscn"
const CARD_DRAW_OFFSET := Vector2(100, 0)
const CARD_START_ROTATIONS := [-6.0, 0.0, 6.0]
const CARD_DRAW_SFX := "res://assets/audio/sounds/cards/Card draw.wav"
const CARD_FLIP_SFX := "res://assets/audio/sounds/cards/Card flip 2.wav"
const HERO_SELECTED_SFX := "res://assets/audio/sounds/ui/positive selection.wav"
const CARD_FLIP_PITCHES := [0.94, 1.0, 1.06]

@export var logger_prefix := "HeroSelection"

@onready var choices_container: HBoxContainer = $Content/Layout/Cards/HeroChoices
@onready var status_label: Label = $Content/Layout/Status
@onready var back_button: Button = $Content/Layout/Header/Back
@onready var fade_rect: ColorRect = $Fade
@onready var fade_player: AnimationPlayer = $Fade/AnimationPlayer
@onready var deal_hint: Label = $Content/Layout/DealHint

var _choice_cards: Array[HeroChoiceCard] = []
var _selection_in_progress := false
var _revealing_cards := false


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
		choice_card.conceal_until_reveal()
		choice_card.set_selection_enabled(false)
		choice_card.hero_selected.connect(_on_hero_selected)
		_choice_cards.append(choice_card)

	await get_tree().process_frame
	_revealing_cards = true
	deal_hint.show()
	var draw_origin := Vector2(choices_container.size.x, 0) + CARD_DRAW_OFFSET
	for index in range(_choice_cards.size()):
		_choice_cards[index].prepare_face_down(
			draw_origin,
			CARD_START_ROTATIONS[index]
		)
	AudioManager.play(CARD_DRAW_SFX, AudioManager.Audio.UI, -12.0)
	for index in range(_choice_cards.size()):
		await _choice_cards[index].draw_to_table(0.44)
		AudioManager.play(
			CARD_FLIP_SFX,
			AudioManager.Audio.UI,
			-16.0,
			CARD_FLIP_PITCHES[index]
		)
		await _choice_cards[index].flip_to_front(0.34)
	_set_choices_enabled(true)
	_revealing_cards = false
	deal_hint.hide()


func _input(event: InputEvent) -> void:
	if !_revealing_cards:
		return
	var should_accelerate := event.is_action_pressed("ui_accept")
	if event is InputEventMouseButton:
		should_accelerate = should_accelerate || (
			event.button_index == MOUSE_BUTTON_LEFT && event.pressed
		)
	if !should_accelerate:
		return
	for choice_card in _choice_cards:
		choice_card.accelerate_animation()
	deal_hint.hide()
	get_viewport().set_input_as_handled()


func _on_hero_selected(hero_id: String) -> void:
	if _selection_in_progress:
		return
	if !HeroLoader.select_hero(hero_id):
		_show_error("That hero could not be selected.")
		return

	AudioManager.play(HERO_SELECTED_SFX, AudioManager.Audio.UI, -10.0)
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
