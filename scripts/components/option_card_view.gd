class_name OptionCardView
extends AnimatedCardView

signal option_selected(option_id: String)

const STAT_DISPLAY_NAMES := {
	"gold": "Gold",
	"greed": "Greed",
	"popularity": "Popularity"
}

@onready var title_label: Label = $Margin/Contents/Title
@onready var option_image: TextureRect = $Margin/Contents/Image
@onready var description_label: RichTextLabel = $Margin/Contents/Description
@onready var effects_label: Label = $Margin/Contents/Effects
@onready var select_button: Button = $Margin/Contents/Select

var _option_id := ""
var _is_available := false
var _input_enabled := false


func _ready() -> void:
	select_button.pressed.connect(_on_select_pressed)


func present(option: Dictionary, is_available: bool) -> void:
	_option_id = str(option.get("id", ""))
	_is_available = is_available
	_input_enabled = false
	title_label.text = str(option.get("title", "Untitled Choice"))
	description_label.text = str(option.get("description", ""))
	effects_label.text = _format_effects(option.get("effects", {}))
	_set_image(str(option.get("image", "")))
	tooltip_text = "" if _is_available else "You do not have enough of one or more stats to choose this."
	_update_button_state()
	show()


func clear_option() -> void:
	_option_id = ""
	_is_available = false
	_input_enabled = false
	effects_label.text = ""
	option_image.texture = null
	self_modulate = Color.WHITE
	tooltip_text = ""
	_update_button_state()
	hide()


func set_input_enabled(enabled: bool) -> void:
	_input_enabled = enabled
	_update_button_state()


func _on_select_pressed() -> void:
	if _option_id.is_empty() || select_button.disabled:
		return
	option_selected.emit(_option_id)


func _update_button_state() -> void:
	select_button.disabled = !_input_enabled || !_is_available || _option_id.is_empty()


func _get_front_modulate() -> Color:
	return Color.WHITE if _is_available else Color(0.5, 0.5, 0.5, 1.0)


func _format_effects(effects: Dictionary) -> String:
	var summaries: Array[String] = []
	for stat_name in STAT_DISPLAY_NAMES:
		var change := int(effects.get(stat_name, 0))
		if change > 0:
			summaries.append(
				"Gain " + str(change) + " " + str(STAT_DISPLAY_NAMES[stat_name])
			)
		elif change < 0:
			summaries.append(
				"Lose " + str(abs(change)) + " " + str(STAT_DISPLAY_NAMES[stat_name])
			)

	if summaries.is_empty():
		return "No stat change"
	return "\n".join(summaries)


func _set_image(image_path: String) -> void:
	if image_path.is_empty():
		option_image.texture = null
		option_image.hide()
		return

	var texture := load(image_path) as Texture2D
	if texture == null:
		option_image.texture = null
		option_image.hide()
		return

	option_image.texture = texture
	option_image.show()
