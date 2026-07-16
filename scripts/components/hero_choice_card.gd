class_name HeroChoiceCard
extends SelectableAnimatedCardView

signal hero_selected(hero_id: String)

@onready var portrait: HeroPortraitView = $Margin/Contents/Portrait
@onready var title_label: Label = $Margin/Contents/Title
@onready var description_label: RichTextLabel = $Margin/Contents/Description
@onready var gold_label: Label = $Margin/Contents/Stats/Gold
@onready var greed_label: Label = $Margin/Contents/Stats/Greed
@onready var popularity_label: Label = $Margin/Contents/Stats/Popularity

var _hero_id := ""


func _ready() -> void:
	super()
	selection_requested.connect(_on_selection_requested)


func present(hero: Dictionary) -> void:
	_hero_id = str(hero.id)
	title_label.text = str(hero.title)
	description_label.text = str(hero.description)
	gold_label.text = "Gold: " + str(int(hero.starting_stats.gold))
	greed_label.text = "Greed: " + str(int(hero.starting_stats.greed))
	popularity_label.text = "Popularity: " + str(int(hero.starting_stats.popularity))
	portrait.present(hero)


func conceal_until_reveal() -> void:
	front_content.hide()
	card_back.show()


func _on_selection_requested() -> void:
	if _hero_id.is_empty():
		return
	hero_selected.emit(_hero_id)
