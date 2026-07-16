class_name HeroPortraitView
extends TextureRect


func present(hero: Dictionary) -> void:
	var image_path := str(hero.get("image", ""))
	if image_path.is_empty():
		clear()
		return

	var source_texture := load(image_path) as Texture2D
	if source_texture == null:
		clear()
		return

	texture = _create_portrait_texture(
		source_texture,
		hero.get("image_region", {})
	)
	show()


func clear() -> void:
	texture = null
	hide()


func _create_portrait_texture(
	source_texture: Texture2D,
	image_region: Dictionary
) -> Texture2D:
	if image_region.is_empty():
		return source_texture

	var portrait_texture := AtlasTexture.new()
	portrait_texture.atlas = source_texture
	portrait_texture.region = Rect2(
		float(image_region.x),
		float(image_region.y),
		float(image_region.width),
		float(image_region.height)
	)
	return portrait_texture
