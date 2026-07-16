class_name HeroChoiceCard
extends AnimatedCardView

signal hero_selected(hero_id: String)

const HOVER_LIFT := Vector2(0, -18)
const HOVER_DURATION := 0.12

@onready var portrait: TextureRect = $Margin/Contents/Portrait
@onready var title_label: Label = $Margin/Contents/Title
@onready var description_label: RichTextLabel = $Margin/Contents/Description
@onready var gold_label: Label = $Margin/Contents/Stats/Gold
@onready var greed_label: Label = $Margin/Contents/Stats/Greed
@onready var popularity_label: Label = $Margin/Contents/Stats/Popularity

var _hero_id := ""
var _selection_enabled := false
var _is_hovered := false
var _resting_position := Vector2.ZERO
var _has_resting_position := false
var _hover_tween: Tween


func _ready() -> void:
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	focus_entered.connect(_refresh_lift)
	focus_exited.connect(_refresh_lift)
	_make_descendants_mouse_transparent(self)


func present(hero: Dictionary) -> void:
	_hero_id = str(hero.id)
	title_label.text = str(hero.title)
	description_label.text = str(hero.description)
	gold_label.text = "Gold: " + str(int(hero.starting_stats.gold))
	greed_label.text = "Greed: " + str(int(hero.starting_stats.greed))
	popularity_label.text = "Popularity: " + str(int(hero.starting_stats.popularity))

	var image_path := str(hero.image)
	if image_path.is_empty():
		portrait.hide()
		return

	var texture := load(image_path) as Texture2D
	if texture == null:
		portrait.hide()
		return
	var image_region: Dictionary = hero.get("image_region", {})
	portrait.texture = _create_portrait_texture(texture, image_region)
	portrait.show()


func conceal_until_reveal() -> void:
	front_content.hide()
	card_back.show()


func _create_portrait_texture(texture: Texture2D, image_region: Dictionary) -> Texture2D:
	if image_region.is_empty():
		return texture

	var portrait_texture := AtlasTexture.new()
	portrait_texture.atlas = texture
	portrait_texture.region = Rect2(
		float(image_region.x),
		float(image_region.y),
		float(image_region.width),
		float(image_region.height)
	)
	return portrait_texture


func set_selection_enabled(enabled: bool) -> void:
	_selection_enabled = enabled
	mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND if enabled else Control.CURSOR_ARROW
	)
	if enabled:
		_resting_position = position
		_has_resting_position = true
	_refresh_lift()


func _on_gui_input(event: InputEvent) -> void:
	if !_selection_enabled || _hero_id.is_empty():
		return

	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index != MOUSE_BUTTON_LEFT || !mouse_event.pressed:
			return
		accept_event()
		grab_focus()
		hero_selected.emit(_hero_id)
	elif event.is_action_pressed("ui_accept"):
		accept_event()
		hero_selected.emit(_hero_id)


func _on_mouse_entered() -> void:
	_is_hovered = true
	_refresh_lift()


func _on_mouse_exited() -> void:
	_is_hovered = false
	_refresh_lift()


func _refresh_lift() -> void:
	if !_has_resting_position:
		return
	if _hover_tween != null && _hover_tween.is_valid():
		_hover_tween.kill()

	var should_lift := _selection_enabled && (_is_hovered || has_focus())
	var target_position := _resting_position + HOVER_LIFT if should_lift else _resting_position
	_hover_tween = create_tween()
	_hover_tween.set_trans(Tween.TRANS_QUAD)
	_hover_tween.set_ease(Tween.EASE_OUT)
	_hover_tween.tween_property(self, "position", target_position, HOVER_DURATION)


func _make_descendants_mouse_transparent(node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_make_descendants_mouse_transparent(child)
