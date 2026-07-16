class_name SelectableAnimatedCardView
extends AnimatedCardView

signal selection_requested

const HOVER_LIFT := Vector2(0, -18)
const HOVER_DURATION := 0.12

var _selection_enabled := false
var _is_hovered := false
var _resting_position := Vector2.ZERO
var _has_resting_position := false
var _hover_tween: Tween


func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	focus_entered.connect(_refresh_lift)
	focus_exited.connect(_refresh_lift)
	_make_descendants_mouse_transparent(self)


func prepare_face_down(
	draw_origin: Vector2,
	starting_rotation_degrees: float = 0.0
) -> void:
	_stop_hover_tween()
	if _has_resting_position:
		position = _resting_position
	_has_resting_position = false
	super(draw_origin, starting_rotation_degrees)


func set_selection_enabled(enabled: bool) -> void:
	_selection_enabled = enabled
	focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE
	mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND if enabled else Control.CURSOR_ARROW
	)
	if !enabled && has_focus():
		release_focus()
	if enabled:
		_resting_position = position
		_has_resting_position = true
	_refresh_lift()


func is_selection_enabled() -> bool:
	return _selection_enabled


func _on_gui_input(event: InputEvent) -> void:
	if !_selection_enabled:
		return

	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index != MOUSE_BUTTON_LEFT || !mouse_event.pressed:
			return
		accept_event()
		grab_focus()
		selection_requested.emit()
	elif event.is_action_pressed("ui_accept"):
		accept_event()
		selection_requested.emit()


func _on_mouse_entered() -> void:
	_is_hovered = true
	_refresh_lift()


func _on_mouse_exited() -> void:
	_is_hovered = false
	_refresh_lift()


func _refresh_lift() -> void:
	if !_has_resting_position:
		return
	_stop_hover_tween()

	var should_lift := _selection_enabled && (_is_hovered || has_focus())
	var target_position := _resting_position + HOVER_LIFT if should_lift else _resting_position
	_hover_tween = create_tween()
	_hover_tween.set_trans(Tween.TRANS_QUAD)
	_hover_tween.set_ease(Tween.EASE_OUT)
	_hover_tween.tween_property(self, "position", target_position, HOVER_DURATION)


func _stop_hover_tween() -> void:
	if _hover_tween != null && _hover_tween.is_valid():
		_hover_tween.kill()
	_hover_tween = null


func _make_descendants_mouse_transparent(node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_make_descendants_mouse_transparent(child)
