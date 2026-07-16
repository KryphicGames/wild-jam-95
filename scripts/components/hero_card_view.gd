class_name HeroCardView
extends TextureRect

@onready var title_label: Label = $Margin/Contents/Title
@onready var gold_label: Label = $Margin/Contents/Stats/Gold
@onready var greed_label: Label = $Margin/Contents/Stats/Greed
@onready var popularity_label: Label = $Margin/Contents/Stats/Popularity


func present(hero: Dictionary, gold: int, greed: int, popularity: int) -> void:
	title_label.text = str(hero.get("title", "Hero"))
	refresh_stats(gold, greed, popularity)


func refresh_stats(gold: int, greed: int, popularity: int) -> void:
	gold_label.text = "Gold: " + str(gold)
	greed_label.text = "Greed: " + str(greed)
	popularity_label.text = "Popularity: " + str(popularity)
