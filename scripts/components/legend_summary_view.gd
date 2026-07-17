class_name LegendSummaryView
extends Control

signal play_again_requested
signal main_menu_requested

@onready var title_label: Label = $Background/Margin/Layout/Title
@onready var hero_label: Label = $Background/Margin/Layout/Hero
@onready var portrait: HeroPortraitView = $Background/Margin/Layout/Body/PortraitColumn/Portrait
@onready var stats_label: Label = $Background/Margin/Layout/Body/PortraitColumn/Stats
@onready var traits_label: RichTextLabel = $Background/Margin/Layout/Body/PortraitColumn/Traits
@onready var collection_label: Label = $Background/Margin/Layout/Body/PortraitColumn/CollectionProgress
@onready var epilogue_label: RichTextLabel = $Background/Margin/Layout/Body/StoryColumn/Epilogue
@onready var journey_label: RichTextLabel = $Background/Margin/Layout/Body/StoryColumn/Journey
@onready var play_again_button: Button = $Background/Margin/Layout/Buttons/PlayAgain
@onready var main_menu_button: Button = $Background/Margin/Layout/Buttons/MainMenu


func _ready() -> void:
	play_again_button.pressed.connect(func(): play_again_requested.emit())
	main_menu_button.pressed.connect(func(): main_menu_requested.emit())


func present(summary: Dictionary, hero: Dictionary) -> void:
	title_label.text = str(summary.title)
	hero_label.text = "The Legend of " + str(summary.hero_title)
	portrait.present(hero)
	stats_label.text = (
		"Gold: " + str(summary.gold)
		+ "\nGreed: " + str(summary.greed)
		+ "\nPopularity: " + str(summary.popularity)
	)
	traits_label.text = "[b]Final Traits[/b]\n" + str(summary.traits)
	collection_label.text = str(summary.collection_progress)
	epilogue_label.text = str(summary.epilogue)
	journey_label.text = "[b]Your Journey[/b]\n" + str(summary.journey)
	show()
	play_again_button.grab_focus()
