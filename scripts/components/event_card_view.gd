class_name EventCardView
extends AnimatedCardView

@onready var title_label: RichTextLabel = $Margin/Contents/Title
@onready var event_image: TextureRect = $Margin/Contents/Image
@onready var description_label: RichTextLabel = $Margin/Contents/Description
@onready var continue_button: Button = $Margin/Contents/Continue


func present(card: Dictionary) -> void:
	description_label.modulate = Color.WHITE
	continue_button.hide()
	title_label.text = str(card.get("title", "Untitled Event"))
	description_label.text = str(card.get("description", ""))
	_set_image(str(card.get("image", "")))


func present_choice_result(option: Dictionary) -> void:
	var fade_out := create_tween()
	fade_out.set_trans(Tween.TRANS_QUAD)
	fade_out.set_ease(Tween.EASE_IN)
	fade_out.tween_property(description_label, "modulate:a", 0.0, 0.16)
	await fade_out.finished

	description_label.text = _build_result_text(option)
	var fade_in := create_tween()
	fade_in.set_trans(Tween.TRANS_QUAD)
	fade_in.set_ease(Tween.EASE_OUT)
	fade_in.tween_property(description_label, "modulate:a", 1.0, 0.22)
	await fade_in.finished
	continue_button.show()
	continue_button.grab_focus()
	await continue_button.pressed
	continue_button.hide()


func show_empty_state() -> void:
	continue_button.hide()
	title_label.text = "Journey Complete"
	description_label.text = "No more events are available for this hero."
	event_image.texture = null
	event_image.hide()
	show_front_immediately()


func _set_image(image_path: String) -> void:
	if image_path.is_empty():
		event_image.texture = null
		event_image.hide()
		return

	var texture := load(image_path) as Texture2D
	if texture == null:
		event_image.texture = null
		event_image.hide()
		return

	event_image.texture = texture
	event_image.show()


func _build_result_text(option: Dictionary) -> String:
	var authored_result := str(option.get("result", ""))
	if !authored_result.is_empty():
		return authored_result

	var reactions: Array[String] = []
	var effects: Dictionary = option.get("effects", {})
	var gold_change := int(effects.get("gold", 0))
	var greed_change := int(effects.get("greed", 0))
	var popularity_change := int(effects.get("popularity", 0))

	if gold_change > 0:
		reactions.append("Your purse grows noticeably heavier.")
	elif gold_change < 0:
		reactions.append("Your purse feels lighter once the matter is settled.")
	if greed_change > 0:
		reactions.append("Ambition tightens its hold on your legend.")
	elif greed_change < 0:
		reactions.append("The pull of greed loosens within you.")
	if popularity_change > 0:
		reactions.append("Word of the deed begins spreading in your favor.")
	elif popularity_change < 0:
		reactions.append("The story spreads, and not everyone tells it kindly.")

	if reactions.is_empty():
		return "The decision is made, and the road ahead subtly changes with it."
	return " ".join(reactions)
