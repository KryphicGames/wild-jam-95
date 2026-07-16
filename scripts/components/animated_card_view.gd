class_name AnimatedCardView
extends TextureRect

@onready var front_content: Control = $Margin
@onready var card_back: Control = $CardBack

var _table_position := Vector2.ZERO
var _active_tween: Tween


func prepare_face_down(draw_origin: Vector2, starting_rotation_degrees: float = 0.0) -> void:
	_stop_active_tween()
	_table_position = position
	pivot_offset = size * 0.5
	position = draw_origin
	rotation = deg_to_rad(starting_rotation_degrees)
	scale = Vector2(0.72, 0.72)
	self_modulate = Color.WHITE
	front_content.hide()
	card_back.show()
	show()


func draw_to_table(duration: float = 0.45) -> void:
	_stop_active_tween()
	_active_tween = create_tween()
	_active_tween.set_trans(Tween.TRANS_QUAD)
	_active_tween.set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(self, "position", _table_position, duration)
	_active_tween.parallel().tween_property(self, "rotation", 0.0, duration)
	_active_tween.parallel().tween_property(self, "scale", Vector2.ONE, duration)
	await _active_tween.finished
	_active_tween = null


func flip_to_front(duration: float = 0.3) -> void:
	_stop_active_tween()
	var half_duration := duration * 0.5

	_active_tween = create_tween()
	_active_tween.set_trans(Tween.TRANS_QUAD)
	_active_tween.set_ease(Tween.EASE_IN)
	_active_tween.tween_property(self, "scale", Vector2(0.0, 1.0), half_duration)
	await _active_tween.finished

	card_back.hide()
	front_content.show()
	self_modulate = _get_front_modulate()

	_active_tween = create_tween()
	_active_tween.set_trans(Tween.TRANS_QUAD)
	_active_tween.set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(self, "scale", Vector2.ONE, half_duration)
	await _active_tween.finished
	_active_tween = null


func draw_and_flip(
	draw_duration: float = 0.45,
	flip_duration: float = 0.3
) -> void:
	await draw_to_table(draw_duration)
	await flip_to_front(flip_duration)


func show_front_immediately() -> void:
	_stop_active_tween()
	position = _table_position if _table_position != Vector2.ZERO else position
	rotation = 0.0
	scale = Vector2.ONE
	card_back.hide()
	front_content.show()
	self_modulate = _get_front_modulate()
	show()


func _stop_active_tween() -> void:
	if _active_tween != null && _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = null


func _get_front_modulate() -> Color:
	return Color.WHITE
