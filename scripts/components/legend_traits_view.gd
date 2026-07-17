class_name LegendTraitsView
extends Control

const LEGEND_TRAIT_CATALOG := preload("res://scripts/traits/legend_trait_catalog.gd")

@onready var traits_label: RichTextLabel = $Margin/Layout/Traits

var _catalog = LEGEND_TRAIT_CATALOG.new()


func present(flags: Array) -> void:
	var formatted_traits := _catalog.format_traits(flags)
	if formatted_traits.is_empty():
		traits_label.text = "Your important decisions will leave their mark here."
	else:
		traits_label.text = formatted_traits
