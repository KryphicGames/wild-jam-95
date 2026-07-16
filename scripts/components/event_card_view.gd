class_name EventCardView
extends AnimatedCardView

@onready var title_label: RichTextLabel = $Margin/Contents/Title
@onready var event_image: TextureRect = $Margin/Contents/Image
@onready var description_label: RichTextLabel = $Margin/Contents/Description


func present(card: Dictionary) -> void:
	title_label.text = str(card.get("title", "Untitled Event"))
	description_label.text = str(card.get("description", ""))
	_set_image(str(card.get("image", "")))


func show_empty_state() -> void:
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
