class_name HeroChoiceCard
extends PanelContainer

signal hero_selected(hero_id: String)

@onready var portrait: TextureRect = $Margin/Contents/Portrait
@onready var title_label: Label = $Margin/Contents/Title
@onready var description_label: RichTextLabel = $Margin/Contents/Description
@onready var gold_label: Label = $Margin/Contents/Stats/Gold
@onready var greed_label: Label = $Margin/Contents/Stats/Greed
@onready var popularity_label: Label = $Margin/Contents/Stats/Popularity
@onready var select_button: Button = $Margin/Contents/Select

var hero_id := ""


func _ready() -> void:
	select_button.pressed.connect(_on_select_pressed)


func present(hero: Dictionary) -> void:
	hero_id = str(hero.id)
	title_label.text = str(hero.title)
	description_label.text = str(hero.description)
	gold_label.text = "Gold: " + str(hero.starting_stats.gold)
	greed_label.text = "Greed: " + str(hero.starting_stats.greed)
	popularity_label.text = "Popularity: " + str(hero.starting_stats.popularity)

	var image_path := str(hero.image)
	if image_path.is_empty():
		portrait.hide()
		return

	var texture := load(image_path) as Texture2D
	if texture == null:
		portrait.hide()
		return
	portrait.texture = texture
	portrait.show()


func set_selection_enabled(enabled: bool) -> void:
	select_button.disabled = !enabled


func _on_select_pressed() -> void:
	if hero_id.is_empty():
		return
	hero_selected.emit(hero_id)
