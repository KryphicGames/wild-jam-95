extends Control

const MAIN_MENU_SCENE := "res://scenes/main_menu.tscn"

@onready var progress_label: Label = $Content/Layout/Progress
@onready var endings_label: RichTextLabel = $Content/Layout/Endings
@onready var back_button: Button = $Content/Layout/Back
@onready var fade_rect: ColorRect = $Fade
@onready var fade_player: AnimationPlayer = $Fade/AnimationPlayer

var _legend_builder := LegendBuilder.new()
var _ending_collection := EndingCollectionStore.new()


func _ready() -> void:
	fade_rect.show()
	fade_player.play("fade-in")
	back_button.pressed.connect(_on_back_pressed)
	_present_collection()


func _present_collection() -> void:
	var definitions := _legend_builder.get_ending_definitions()
	var discovered_ids := _ending_collection.get_discovered_ending_ids()
	var discovered_count := 0
	for ending in definitions:
		if discovered_ids.has(str(ending.id)):
			discovered_count += 1
	progress_label.text = (
		str(discovered_count) + " of " + str(definitions.size()) + " legends discovered"
	)
	var entries: Array[String] = []
	for ending in definitions:
		if discovered_ids.has(str(ending.id)):
			entries.append("[b]" + str(ending.title) + "[/b]\nRecorded in your chronicle")
		else:
			entries.append("[color=#7a6b58][b]Undiscovered Legend[/b]\nThe choices leading here remain unknown.[/color]")
	endings_label.text = "\n\n".join(entries)


func _on_back_pressed() -> void:
	back_button.disabled = true
	fade_rect.show()
	fade_player.play("fade-out")
	await fade_player.animation_finished
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
